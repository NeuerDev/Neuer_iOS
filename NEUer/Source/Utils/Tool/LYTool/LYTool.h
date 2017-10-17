//
//  LYTool.h
//  NEUer
//
//  Created by lanya on 2017/10/15.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYTool : NSObject

/**
 输入秒数获得时分秒形式的时间
 */
+ (NSString *)getMMSSFromSS:(NSString *)totalTime;

/**
 输入字符串和字体大小自动计算label高度
 */
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font;

@end
