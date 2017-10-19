//
//  UIView+LYCategory.h
//  NEUer
//
//  Created by lanya on 2017/10/13.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LYCategory)

/**
 给UIView添加圆角
 */
- (void)roundAt:(UIRectCorner)rectCorner withRadius:(CGFloat)radius;


/**
 设置文字动画
 */
- (void)setText:(NSString *)text;

@end
