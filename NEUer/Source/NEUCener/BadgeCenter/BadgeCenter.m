//
//  BadgeCenter.m
//  NEUer
//
//  Created by lanya on 2017/11/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "BadgeCenter.h"

static BadgeCenter *_singletonCenter = nil;

@implementation BadgeCenter
{
    NSNumber *_badge;
}


+ (instancetype)defaultCenter {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletonCenter = [super init];
    });
    return _singletonCenter;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletonCenter = [super allocWithZone:zone];
    });
    return _singletonCenter;
}

+ (instancetype)copyWithZone:(struct _NSZone *)zone{
    return _singletonCenter;
}

+ (instancetype)mutableCopyWithZone:(struct _NSZone *)zone{
    return _singletonCenter;
}

- (void)updateBadges {
    NSInteger badge = _badge.integerValue;
    badge += 1;
    _badge = @(badge);
}

- (void)clearBadges {
    _badge = @(0);
}

- (NSNumber *)badges {
    return _badge;
}

@end
