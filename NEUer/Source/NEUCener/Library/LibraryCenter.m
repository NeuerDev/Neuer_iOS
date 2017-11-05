//
//  LibraryCenter.m
//  NEUer
//
//  Created by kl h on 2017/11/5.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryCenter.h"

static LibraryCenter * center;

@implementation LibraryCenter

+ (instancetype)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[LibraryCenter alloc] init];
    });
    return center;
}

@end
