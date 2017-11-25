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
    UserKeyTypeECard,
    UserKeyTypeLib,
};

@interface UserKey : NSObject

@property (nonatomic, assign) UserKeyType type;
@property (nonatomic, strong) NSString *value;

@end

@interface UserKeychain : NSObject
@property (nonatomic, weak) User *user;

+ (instancetype)keychainForUser:(User *)user;

- (NSArray<UserKey *> *)allKeys;

- (NSString *)passwordForKeyType:(UserKeyType)type;

- (void)setPassword:(NSString *)password forKeyType:(UserKeyType)type;

- (void)deleteUserKeyForType:(UserKeyType)type;

@end
