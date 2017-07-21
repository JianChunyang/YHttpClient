//
//  YHttpClient.h
//  YHttpClient
//
//  Created by chun on 2017/7/21.
//  Copyright © 2017年 chun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cookies : NSObject
+(NSString*)getCsrftoken;
+(NSString*)getCookie:(NSString*)key;
+(void)clearCookiesWithUrl:(NSURL*)url;
+(void)clearCookiesWithPath:(NSString*)path;
+(void)clearAllCookies;
@end
