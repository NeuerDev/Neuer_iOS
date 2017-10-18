//
//  EcardCenter.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardCenter.h"

@implementation EcardCenter

static EcardCenter * center;

#pragma mark - Singleton

+ (instancetype)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[EcardCenter alloc] init];
    });
    
    return center;
}

#pragma mark - Getter

- (EcardModel *)currentModel {
    if (!_currentModel) {
        _currentModel = [[EcardModel alloc] initWithUser:[[UserCenter defaultCenter] currentUser]];
    }
    
    return _currentModel;
}
@end
