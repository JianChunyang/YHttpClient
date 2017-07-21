//
//  YHttpClient.h
//  YHttpClient
//
//  Created by chun on 2017/7/21.
//  Copyright © 2017年 chun. All rights reserved.
//

#import "Cookies.h"

@implementation Cookies

+(NSString*)getCsrftoken
{
    return [self getCookie:@"csrftoken"];
}
+(NSString*)getCookie:(NSString*)key
{
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies] ) {
        NSString *name = [cookie valueForKey:@"name"];
        if ([name isEqualToString: key]) {
            return [cookie valueForKey:@"value"];
        }
    }
    return nil;
}
+(void)clearCookiesWithUrl:(NSURL*)url
{
    if (nil == url) {
        return;
    }
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [NSArray arrayWithArray:[cookieJar cookiesForURL:url]];
    
    for (id obj in cookies) {
        [cookieJar deleteCookie:obj];
    }
}
+(void)clearCookiesWithPath:(NSString*)path
{
    if (nil == path) {
        return;
    }
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [NSArray arrayWithArray:[cookieJar cookies]];

    for (id obj in cookies) {
        if ([[obj valueForKey:@"path"] isEqualToString:path]) {
            [cookieJar deleteCookie:obj];
        }
    }
}

+(void)clearAllCookies{
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *_tmpArray = [NSArray arrayWithArray:[cookieJar cookies]];
    for (id obj in _tmpArray) {
        [cookieJar deleteCookie:obj];
    }
}

@end
