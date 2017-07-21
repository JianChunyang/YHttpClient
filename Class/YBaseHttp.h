//
//  YHttpClient.h
//  YHttpClient
//
//  Created by chun on 2017/7/21.
//  Copyright © 2017年 chun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completionHandler)(NSURLResponse *response, id receivedData, NSError *error);

typedef enum :NSUInteger {
    HTTP_CLIENT_MODE_SYNC = 1,
    HTTP_CLIENT_MODE_ASYNC = 2,
} HTTP_CLIENT_MODE;

@interface YBaseHttp : NSObject

@property(nonatomic,readonly)HTTP_CLIENT_MODE httpMode;

+(id)sharedInstance;

-(void)sendAsyncRequest:(NSURLRequest*)request with:(completionHandler)block;

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse *__strong*)response
                             error:(NSError *__strong*)error;

@end
