//
//  UIView+LYCategory.m
//  NEUer
//
//  Created by lanya on 2017/10/13.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "UIView+LYCategory.h"

@implementation UIView (LYCategory)

- (void)roundAt:(UIRectCorner)rectCorner withRadius:(CGFloat)radius {
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.path = bezierPath.CGPath;
    self.layer.mask = mask;
}

@end
