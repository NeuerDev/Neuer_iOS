//
//  UIColor+JHCategory.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define random(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
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

+ (UIColor *)randomColor;

@end
