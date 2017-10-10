//
//  UserKeychain.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/2.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "UserKeychain.h"

@implementation UserKeychain

+ (instancetype)keychainForUser:(User *)user {
    return [[UserKeychain alloc] init];
}

- (NSArray<UserKey *> *)allKeys {
    return @[];
}

- (NSString *)passwordForType:(UserKeyType)type {
    return @"";
}

- (void)setPassword:(NSString *)password forType:(UserKeyType)type {
    
}

@end
