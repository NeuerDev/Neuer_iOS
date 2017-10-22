//
//  GatewayComponentInfoLb.h
//  NEUer
//
//  Created by lanya on 2017/10/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GatewayComponentInfoLb : UILabel

/**
 输入字体颜色和大小初始化label
 */
- (instancetype)initWithTextColor:(UIColor *)color font:(UIFont *)font;

/**
 默认字体方法
 */
- (instancetype)init;

@end
