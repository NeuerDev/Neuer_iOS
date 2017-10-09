//
//  UserKeychain.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/2.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

typedef NS_ENUM(NSInteger, UserKeyType) {
    UserKeyTypeAAO,
    UserKeyTypeIPGW,
    UserKeyTypeCard,
    UserKeyTypeLib,
};

@interface UserKey : NSObject

@property (nonatomic, assign) UserKeyType type;
@property (nonatomic, strong) NSString *value;

@end

@interface UserKeychain : NSObject

+ (instancetype)keychainForUser:(User *)user;

- (NSArray<UserKey *> *)allKeys;

- (NSString *)passwordForType:(UserKeyType)type;

- (void)setPassword:(NSString *)password forType:(UserKeyType)type;

@end
