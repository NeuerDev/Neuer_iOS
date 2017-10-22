//
//  JHTool.h
//  ZhiFeiUser
//
//  Created by 307A on 2016/12/22.
//  Copyright © 2016年 徐嘉宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JHTool : NSObject

/**
 *
 * 用于转化#ffffff颜色字符串到UIColor对象
 * @params hexString #ffffff颜色字符串
 * 返回UIColor对象
 */
+ (UIColor *)colorWithHexStr:(NSString *)hexString;

/**
 *
 * 用于转化#ffffff颜色到UIImage对象
 * @params color #ffffff颜色字符串
 * 返回UIImage对象
 */
+ (UIImage *)imageFromColor:(UIColor *)color;

/**
 *
 * 正则验证电话号码是否可用
 * @params phoneNum 电话号码
 * YES/NO
 */
+ (BOOL)isPhoneNumAvailable:(NSString *)phoneNum;

/**
 *
 * 获取文件夹大小
 * @params folderPath 文件夹路径
 **/
+ (float)folderSizeAtPath:(NSString*)folderPath;

/**
 *  根据颜色生成一张图片
 *  @param color 提供的颜色
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  MD5加密
 *  @param str 要加密的字符串
 */
+ (NSString *)md5:(NSString *)str;

/**
 *  获取当前显示的 UIViewController
 *  @return 当前显示的 UIViewController
 */
+ (UIViewController *)getCurrentVC;

/**
 *  获取 View 的 UIImage
 *  @param shareView 用于生成图片的 View
 *  @return UIImage
 */
+ (UIImage *)createImageWithView:(UIView *)shareView;

/**
 *  获取用户友好的时间描述
 *  @return 时间描述
 */
+ (NSString *)fancyStringFromDate:(NSDate *)date;
@end

