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

/**
 返回在wifi条件下的设备ip地址
 */
+ (NSString *)getDeviceIPAddressesOnWifi;

/**
 获取当前present出来的最顶层的视图,用来获取LoginViewController
 */
+ (UIViewController *)getPresentedViewController;


/**
 截取字符串
 @param originString 用于被截取的字符串
 @param startString 开始的字符串
 @param endString 结束的字符串
 */
+ (NSString *)subStringFromString:(NSString *)originString startString:(NSString *)startString endString:(NSString *)endString;

/**
 距离今天间距有 days 的日期
 */
+ (NSString *)dateOfTimeIntervalFromToday:(NSInteger)days;

/**
 获取当前时间 HH:mm格式
 */
+ (NSString *)timeOfNow;
@end
