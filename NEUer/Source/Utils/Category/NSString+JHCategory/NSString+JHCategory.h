//
//  NSString+JHCategory.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JHCategory)

+ (NSString *)stringFromGBKData:(NSData *)data;

- (NSString *)URLEncode;
- (NSString *)URLDecode;

- (NSString *)md5;
@end
