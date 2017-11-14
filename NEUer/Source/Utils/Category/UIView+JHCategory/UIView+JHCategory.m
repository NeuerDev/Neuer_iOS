//
//  UIView+JHCategory.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "UIView+JHCategory.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIView (JHCategory)

- (void)roundCorners:(UIRectCorner)corner radii:(CGSize)radii {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:radii];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setBorderWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat width = scale > 0.0 ? 1.0 / scale : 1.0;
    
    self.layer.borderWidth = width;
    if (!color) {
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    } else {
        self.layer.borderColor = color.CGColor;
    }
    
    self.layer.cornerRadius = cornerRadius;
}

@end
