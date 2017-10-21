//
//  GatewayComponentInfoLb.m
//  NEUer
//
//  Created by lanya on 2017/10/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewayComponentInfoLb.h"

@implementation GatewayComponentInfoLb

- (instancetype)init {
    return [self initWithTextColor:[UIColor grayColor] font:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle3]];
}

- (instancetype)initWithTextColor:(UIColor *)color font:(UIFont *)font {
    if (self = [super init]) {
        self.textColor = color;
        self.textAlignment = NSTextAlignmentCenter;
        self.font = font;
        self.numberOfLines = 0;
    }
    return self;
}

@end
