//
//  YHttpClient.h
//  YHttpClient
//
//  Created by chun on 2017/7/21.
//  Copyright © 2017年 chun. All rights reserved.
//

#import "YBaseHttp.h"
@interface YBaseHttp() <NSURLConnectionDataDelegate>
@property (nonatomic,copy)completionHandler handlerBlock;

@property(copy)NSMutableData *receivedData;
@property(nonatomic,strong)NSError *error;
@property(nonatomic,strong)NSURLResponse *response;
@property(nonatomic,assign)NSUInteger status_code;
@property(nonatomic,assign)HTTP_CLIENT_MODE internalMode;
@end

@implementation YBaseHttp

+(id)sharedInstance{
    return [[self alloc]init];
}

-(HTTP_CLIENT_MODE)httpMode
{
    return _internalMode;
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse *__strong*)response
                             error:(NSError *__strong*)error
{

    _receivedData=[[NSMutableData alloc]init];
    _internalMode = HTTP_CLIENT_MODE_SYNC;
    
    _error = *error;
    _response = *response;
    
    NSURLConnection*con=[NSURLConnection connectionWithRequest:request delegate:self];
    [con start];
    
    CFRunLoopRun();

    *response = _response ;
    *error = _error;
    
    return _receivedData;
}
-(void)sendAsyncRequest:(NSURLRequest*)request with:(completionHandler)block
{
    
    if(nil == request) return;
 
     _receivedData=[[NSMutableData alloc]init];
    _internalMode = HTTP_CLIENT_MODE_ASYNC;
    _handlerBlock = block;
    
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest: request delegate:self];
    [conn start];
    
}


#pragma ----------------  delegate ---------------------------

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
{
    return YES;
}
-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount]== 0) {
        NSURLCredential* cre = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:cre forAuthenticationChallenge:challenge];
    }
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = response;
    NSHTTPURLResponse * resp = (NSHTTPURLResponse*)response;
    _status_code = resp.statusCode;
    if (_status_code != 200) {
        
        _error = [NSError errorWithDomain:@"NSURLErrorDomain " code:_status_code userInfo: resp.allHeaderFields];
    }

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_status_code == 200) {
        [_receivedData appendData:data];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

    _error = error;
    if (_internalMode == HTTP_CLIENT_MODE_SYNC) {
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
    else{
        if (_handlerBlock) {
            _handlerBlock(_response, _receivedData, _error);
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (_internalMode == HTTP_CLIENT_MODE_SYNC) {
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
    else{
        if (_handlerBlock) {
            _handlerBlock(_response, _receivedData, _error);
        }
    }
}
@end
