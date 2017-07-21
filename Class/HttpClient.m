//
//  HttpClient.m
//  YHttpClient
//
//  Created by chun on 2017/7/21.
//  Copyright © 2017年 chun. All rights reserved.
//

#import "HttpClient.h"
#import "Cookies.h"
#import "Converter.h"
#import "RSACrypto.h"
#import "YBaseHttp.h"

@interface HttpClient ()


@property (assign)NSString *domain;
@property (nonatomic, assign)NSString *path;

@property (nonatomic, copy)finishedOnSuccess successBlock;
@property (nonatomic, copy)failWithError errorBlock;

@end

@implementation HttpClient

+(id)sharedInstance{
    return [[self alloc]init];
}


-(id)initWithDomain:(NSString*)domain
{
    self  = [self init];
    if (self) {
        _domain = domain;
    }
    
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _contentType = KMimeTypeJSON;
        _timeout = 30;
    }
    
    //读取保存的cookies，用于自动验证
    [HttpClient readCookies2HTTPRequest];
    
    return self;
}




-(HTTP_CLIENT_RESPONSE_TYPE)responseType
{
    NSString *mimeType = [[self mimeType] lowercaseString];
    
    if ([mimeType isEqualToString: KMimeTypeJSON]) {
        return HTTP_CLIENT_RESPONSE_TYPE_JSON;
    }
    else if ([mimeType isEqualToString:KMimeTypeHTML]){
        return HTTP_CLIENT_RESPONSE_TYPE_HTML;
    }
    else if ([mimeType isEqualToString:KMimeTypeTEXT]){
        return HTTP_CLIENT_RESPONSE_TYPE_TEXT;
    }
    else{
        return HTTP_CLIENT_RESPONSE_TYPE_UNKNOWN;
    }
}
-(NSUInteger)statusCode
{
    NSHTTPURLResponse * r = (NSHTTPURLResponse*)_response;
    return [r statusCode];
}
-(NSString*)textEncodingName
{
    return [_response textEncodingName];
}
-(NSString*)mimeType
{
    return [_response MIMEType];
}

-(NSArray*)cookies
{
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies];
}


+(void)saveCookies2Userdefaults:(NSArray *)cookies{
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: cookies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey: KUserDefaultCookiesKey];
    
}

+(BOOL)readCookies2HTTPRequest{
    
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey: KUserDefaultCookiesKey];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
        return  YES;
    }
    
    return  NO;
}


+(BOOL)successWithNSDictionary:(id)data
{
    return   [data isKindOfClass:[NSDictionary class]] && [[[data valueForKey:@"code"] lowercaseString]isEqualToString:@"0"];
}

+(BOOL)failureWithNSDictionary:(id)data
{
    return   ![data isKindOfClass:[NSDictionary class]] && [[[data valueForKey:@"code"] lowercaseString]isEqualToString:@"0"];
}

#pragma ---------------  public method  as asynchronous ---------------

-(void)getWithPath:(NSString*)path andParams:(NSDictionary *)params
  withSuccessBlock:(finishedOnSuccess)successBlock
    withErrorBlock:(failWithError)errorBlock
{
    
    NSURLRequest *request = [self readRequest:path andParams:params andMethod:@"GET"];
    [self executeAsyncHttpHandler:request withSuccessBlock:successBlock withErrorBlock:errorBlock];
    
}

-(void)postWithPath:(NSString*)path andData:(id)data
   withSuccessBlock:(finishedOnSuccess)successBlock
     withErrorBlock:(failWithError)errorBlock
{
    
    NSURLRequest *request = [self writeRequest:path andData: data andMethod:@"POST"];
    [self executeAsyncHttpHandler:request withSuccessBlock:successBlock withErrorBlock:errorBlock];
    
}
-(void)putWithPath:(NSString*)path andData:(id)data
  withSuccessBlock:(finishedOnSuccess)successBlock
    withErrorBlock:(failWithError)errorBlock
{
    
    NSURLRequest *request = [self writeRequest:path andData: data andMethod:@"PUT"];
    [self executeAsyncHttpHandler:request withSuccessBlock:successBlock withErrorBlock:errorBlock];
}
-(void)deleteWithPath:(NSString*)path andData:(id)data
     withSuccessBlock:(finishedOnSuccess)successBlock
       withErrorBlock:(failWithError)errorBlock
{
    
    NSURLRequest *request = [self writeRequest:path andData: data andMethod:@"DELETE"];
    [self executeAsyncHttpHandler:request withSuccessBlock:successBlock withErrorBlock:errorBlock];
}

-(void)executeAsyncHttpHandler:(NSURLRequest*)request
              withSuccessBlock:(finishedOnSuccess)successBlock
                withErrorBlock:(failWithError)errorBlock
{
    if (nil == request) {
        if (nil == _error) {
            [self setError:[NSError errorWithDomain:@"request is nil" code:-255 userInfo:@{@"object":self}]];
        }
        errorBlock(nil, _error);
        return ;
    }
    
    _successBlock = successBlock;
    _errorBlock = errorBlock;
    
    YBaseHttp *handler = [YBaseHttp sharedInstance];
    
    
    [handler sendAsyncRequest:request with:^(NSURLResponse *response, id receivedData, NSError *error) {
        if (error) {
            if(nil != errorBlock){
                errorBlock(response, error);
            }
        }
        else{
            if(nil != self.completeCallback){
                self.completeCallback(request, response, receivedData);
            }
            if(nil != successBlock){
                successBlock(response, receivedData);
            }
        }
    }];
    
    
}

#pragma ----------------------- synchronous mode -------------------------

-(id)getWithPath:(NSString*)path andParams:(NSDictionary*)params
{
    
    NSURLRequest *request = [self readRequest:path andParams:params andMethod:@"GET"];
    return [self exceuteSyncHttpRequest: request];
}
-(id)postWithPath:(NSString*)path andData:(id)data
{
    
    NSURLRequest *request = [self writeRequest:path andData: data andMethod:@"POST"];
    return [self exceuteSyncHttpRequest: request];
}
-(id)putWithPath:(NSString*)path andData:(id)data
{
    
    NSURLRequest *request = [self writeRequest:path andData: data andMethod:@"PUT"];
    return [self exceuteSyncHttpRequest: request];
}

-(id)deleteWithPath:(NSString*)path andData:(id)data
{
    
    NSURLRequest *request = [self writeRequest: path andData: data andMethod:@"DELETE"];
    return [self exceuteSyncHttpRequest: request];
}

#pragma private methods

-(id)exceuteSyncHttpRequest:(NSURLRequest*)request
{
    if (nil == request){
        if (nil == _error) {
            [self setError:[NSError errorWithDomain:@"request is nil" code:-255 userInfo:@{@"object":self}]];
        }
        
        return nil;
    }
    
    
    id data = [[YBaseHttp sharedInstance] sendSynchronousRequest:request
                                               returningResponse:&_response
                                                           error:&_error];
    
    
    if(nil != self.completeCallback){
        self.completeCallback(request, _response, data);
    }
    
    return data;
}


-(void)addHeader:(NSString*)header value:(NSString*)value
{
    
    [self setHeaders:@{header :value}];
    
}


-(NSMutableURLRequest *)setRequestWithPath:(NSString*)urlString
{
    
    
    if (_domain) {
        urlString = [NSString stringWithFormat:@"%@%@", _domain, urlString];
    }
    
    NSString* encodedString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest *request =  [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:encodedString]
                                                                cachePolicy:_cachePolicy timeoutInterval:_timeout];
    [request addValue: _contentType forHTTPHeaderField:@"Content-Type"];
    
    
    if (self.headers) {
        for (NSString *key in [self.headers allKeys]) {
            [request addValue: [self.headers valueForKey:key] forHTTPHeaderField:key];
        }
    }
    _contentType = KMimeTypeJSON;
    
    
    
    if(nil != self.beforeCallback){
        self.beforeCallback(request);
    }
    
    return request;
}

-(NSURLRequest*)readRequest:(NSString*)path andParams:(NSDictionary*)params andMethod:(NSString*)method
{
    
    if(nil == path || nil == method)return nil;
    
    
    NSMutableString *urlString = [[NSMutableString alloc]initWithString:path];
    if (params) {
        [urlString appendFormat:@"?%@",[self urlEncode:params]];
    }
    
    NSMutableURLRequest *request = [self setRequestWithPath:urlString];
    [request setHTTPMethod: method];
    
    
    return request;
}

-(NSURLRequest*)writeRequest:(NSString*)path andData:(id)data andMethod:(NSString*)method
{
    
    if(nil == path || nil == method)return nil;
    
    
    NSMutableURLRequest *request = [self setRequestWithPath:path];
    
    
    [request setHTTPMethod: method];
    if([_contentType isEqualToString: KMimeTypeJSON]){
        if (data) {
            NSString *ss = [Converter toUTF8JSONString:data];
            NSData *body = [ss dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:body];
        }
    }
    else{
        @throw @"Unsupported type, only for application/json";
    }
    
    
    return  request;
    
}

-(NSString*)urlEncode:(NSDictionary*)params
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (NSString *key in [params allKeys]) {
        NSString *value = [params valueForKey:key];
        [array addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
    }
    return [array componentsJoinedByString:@"&"];
}



@end
