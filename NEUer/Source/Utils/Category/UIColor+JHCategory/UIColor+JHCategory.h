//
//  UIColor+JHCategory.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (JHCategory)
+ (UIColor *)colorWithHexStr:(NSString *)hexString;

+ (UIColor *)beautyRed;

+ (UIColor *)beautyOrange;

+ (UIColor *)beautyYellow;

+ (UIColor *)beautyGreen;

+ (UIColor *)beautyTealBlue;

+ (UIColor *)beautyBlue;

+ (UIColor *)beautyPurple;

+ (UIColor *)beautyPink;

- (UIImage *)image;

- (UIImage *)imageWithSize:(CGSize)size;

- (UIColor *)compressRangeColor;
@end
