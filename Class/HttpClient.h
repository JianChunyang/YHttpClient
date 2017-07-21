//
//  HttpClient.h
//  YHttpClient
//
//  Created by chun on 2017/7/21.
//  Copyright © 2017年 chun. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface HttpClient : NSObject
//
//@end

#import <Foundation/Foundation.h>

#define KMimeType  NSString*
#define KMimeTypeJSON @"application/json"
#define KMimeTypeHTML @"text/html"
#define KMimeTypeTEXT @"text/plain"
#define KMimeTypeMltiFormData @"multipart/form-data"
#define KMimeTypeUrlEncForm @"application/x-www-form-urlencoded"

#define KUserDefaultCookiesKey @"cookiesKey"


typedef enum : NSUInteger {
    HTTP_CLIENT_RESPONSE_TYPE_UNKNOWN,
    HTTP_CLIENT_RESPONSE_TYPE_JSON,
    HTTP_CLIENT_RESPONSE_TYPE_HTML,
    HTTP_CLIENT_RESPONSE_TYPE_TEXT,
}HTTP_CLIENT_RESPONSE_TYPE;

typedef void (^finishedOnSuccess)(NSURLResponse *response, id data);
typedef void (^failWithError)(NSURLResponse *response, NSError *error);

typedef void (^beforeSendCallback)(NSMutableURLRequest *request);
typedef void (^completeRequestCallback)(NSURLRequest *request, NSURLResponse *response, id data);

/*
 
 HTTP数据读写API，本API只负用于从本服务器后台传输数据使用，支持异步和同步方式，
 以block调用的方式极为异步模式, 本接口理论上只返回json格式的数据，调用api直接返回的数据为NSData类型
 可以用过response内的content-type字段对返回数据类型进行判断，
 
 如果用到其它第三方网络服务请使用系统原生的API实现或者AFNetworking
 */

@interface HttpClient : NSObject



//判断数据是词典，http请求成功数据指令执行成功 {state: success}
+(BOOL)successWithNSDictionary:(id)data;
//判断数据是词典，http请求成功，但是数据操作失败 {state: success}
+(BOOL)failureWithNSDictionary:(id)data;



/*
 单例模式，在请求的方法内path要传全url
 e.g:http://api.idelos.cn/path/
 */
+(id)sharedInstance;

/*
 普通实例模式，需要使用域名初始化，结束不带/
 e.g: http://api.idelos.cn
 */
-(id)initWithDomain:(NSString*)domain;


//当前系统存储的cookies
@property (nonatomic,readonly)NSArray *cookies;


//存储kookies到Userdefaults，一般在登录成功之后调用，框架每次调用会自动将数据取出附加到HTTP请求
/*
 * 方法
 
 +(void)saveCookies2Userdefaults:(NSArray *)cookies{
 NSData *data = [NSKeyedArchiver archivedDataWithRootObject: cookies];
 [[NSUserDefaults standardUserDefaults] setObject:data forKey: KUserDefaultCookiesKey];
 }
 
 *
 */
+(void)saveCookies2Userdefaults:(NSArray *)cookies;



//请求发送前执行的回调语句块
@property(nonatomic,copy)beforeSendCallback beforeCallback;


//请求完成后执行的回调语句块
@property(nonatomic,copy)completeRequestCallback completeCallback;


/*
 下列参数只对单次请求有效，请求开始执行立即恢复为默认值，生存周期针对单个request，而非实例对象
 @error
 @response
 @timeout
 @headers
 @contentType
 @cachePolicy
 */
//同步模式下有效
@property (nonatomic, strong)NSError *error;
@property (nonatomic, strong)NSURLResponse *response;


//Connection timeout, default(30 seconds)
@property (nonatomic,assign)NSUInteger timeout;

/*
 Headers （无默认值）,一般无需理会，除非有特殊需求
 示例值：@{ @"content-type" : @"application/json"}
 */
@property(nonatomic,strong)NSDictionary *headers;


//请求的文档类型，默认为 Application/json,
@property (strong)KMimeType contentType;

//http的缓存策略，默认为 NSURLRequestUseProtocolCachePolicy
@property (nonatomic, assign)NSURLRequestCachePolicy cachePolicy;

@property (readonly)HTTP_CLIENT_RESPONSE_TYPE responseType;
@property (readonly)NSUInteger statusCode;
@property (readonly, copy) NSString *textEncodingName;
@property (readonly, copy) KMimeType mimeType;


//该方法可以生成request，但不执行。
-(NSMutableURLRequest *)setRequestWithPath:(NSString*)path;


#pragma -------- 数据读写接口 同步模式 ------------

-(id)getWithPath:(NSString*)path andParams:(NSDictionary*)params;

-(id)postWithPath:(NSString*)path andData:(id)data;
-(id)putWithPath:(NSString*)path andData:(id)data;
-(id)deleteWithPath:(NSString*)path andData:(id)data;


#pragma  --------------- 以block的方式实现 ,默认使用加密 异步模式 ---------------

-(void)getWithPath:(NSString*)path andParams:(NSDictionary *)Params
  withSuccessBlock:(finishedOnSuccess)successBlock
    withErrorBlock:(failWithError)errorBlock;

-(void)postWithPath:(NSString*)path andData:(id)data
   withSuccessBlock:(finishedOnSuccess)successBlock
     withErrorBlock:(failWithError)errorBlock;

-(void)putWithPath:(NSString*)path andData:(id)data
  withSuccessBlock:(finishedOnSuccess)successBlock
    withErrorBlock:(failWithError)errorBlock;

-(void)deleteWithPath:(NSString*)path andData:(id)data
     withSuccessBlock:(finishedOnSuccess)successBlock
       withErrorBlock:(failWithError)errorBlock;


@end
