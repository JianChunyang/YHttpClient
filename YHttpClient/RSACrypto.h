//
//  YHttpClient.h
//  YHttpClient
//
//  Created by chun on 2017/7/21.
//  Copyright © 2017年 chun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSACrypto : NSObject
+(NSString *)encryptDataToBase64:(NSData*)data;
+(NSArray *)encryptStringToNSArray:(NSString *)stringToEncrypt;
+(BOOL)rsaVerifyString:(NSString*)stringToVerify withSignature:(NSString*)signature;
@end
