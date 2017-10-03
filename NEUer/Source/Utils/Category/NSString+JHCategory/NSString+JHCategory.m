//
//  NSString+JHCategory.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NSString+JHCategory.h"
#import<CommonCrypto/CommonDigest.h>

@implementation NSString (JHCategory)

+ (NSString *)stringFromGBKData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    if (!string) {
        string = @"";
    }
    return string;
}

- (NSString *)URLDecode {
    return [self stringByRemovingPercentEncoding];
}

- (NSString *)URLEncode {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

+ (NSString *)md5EncryptWithString:(NSString *)encryptionKey {
    return [NSString stringWithFormat:@"%@%@", encryptionKey, self].md5;
}

@end
