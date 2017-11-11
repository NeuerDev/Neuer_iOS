//
//  BadgeCenter.h
//  NEUer
//
//  Created by lanya on 2017/11/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BadgeCenter : NSObject

+ (instancetype)defaultCenter;
- (void)clearBadges;
- (void)updateBadges;
- (NSNumber *)badges;

@end
