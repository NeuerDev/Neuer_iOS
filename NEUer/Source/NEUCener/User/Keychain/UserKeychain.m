//
//  UserKeychain.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/2.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "UserKeychain.h"

@implementation UserKey

@end

@interface UserKeychain ()
@property (nonatomic, strong) NSArray<UserKey *> *keys;
@end

@implementation UserKeychain

+ (instancetype)keychainForUser:(User *)user {
    UserKeychain *keyChain = [[UserKeychain alloc] init];
    FMDatabase *db = [DataBaseCenter defaultCenter].database;
    FMResultSet *result = [db executeQuery:@"select * from t_key where number = ?", user.number];
    NSMutableArray *keys = @[].mutableCopy;
    while ([result next]) {
        UserKey *key = [[UserKey alloc] init];
        key.type = [result intForColumn:@"keyType"];
        key.value = [result stringForColumn:@"password"];
        [keys addObject:key];
    }
    keyChain.keys = keys.copy;
    keyChain.user = user;
    return keyChain;
}

- (NSArray<UserKey *> *)allKeys {
    return self.keys;
}

- (NSString *)passwordForKeyType:(UserKeyType)type {
    UserKey *targetKey = nil;
    for (UserKey *key in self.keys) {
        if (key.type == type) {
            targetKey = key;
            break;
        }
    }
    return targetKey.value;
}

- (void)setPassword:(NSString *)password forKeyType:(UserKeyType)type {
    NSMutableArray *keys = self.keys.mutableCopy;
    UserKey *targetKey = nil;
    for (UserKey *key in keys) {
        if (key.type == type) {
            targetKey = key;
            break;
        }
    }
    if (targetKey) {
        targetKey.value = password;
    } else {
        targetKey = [[UserKey alloc] init];
        targetKey.type = type;
        targetKey.value = password;
        [keys addObject:targetKey];
    }
    self.keys = keys.copy;
    
    FMDatabase *db = [DataBaseCenter defaultCenter].database;
    [db executeUpdate:@"update t_key set password = ? where number = ? and keyType = ?;", password, _user.number, @(type)];
    [db executeUpdate:@"insert into t_key (number, keyType, password) select ?, ?, ? where not exists(select * from t_key where number = ? and keyType = ?);", _user.number, @(type), password, _user.number, @(type)];
}

- (void)deleteUserKeyForType:(UserKeyType)type {
    FMDatabase *db = [DataBaseCenter defaultCenter].database;
    [db executeUpdate:@"delete from t_key where number = ? and keyType = ?;", _user.number, @(type)];
    
    NSMutableArray<UserKey *> *keys = self.keys.mutableCopy;
    UserKey *targetKey = nil;
    for (UserKey *key in _keys) {
        if (key.type == type) {
            targetKey = key;
            break;
        }
    }
    
    [keys removeObject:targetKey];
    _keys = keys.copy;
}

#pragma mark - Getter

- (NSArray *)keys {
    if (!_keys) {
        NSMutableArray<UserKey *> *keys = @[].mutableCopy;
        FMDatabase *db = [DataBaseCenter defaultCenter].database;
        FMResultSet *result = [db executeQuery:@"select * from t_key where number = ?", _user.number];
        while ([result next]) {
            UserKey *key = [[UserKey alloc] init];
            key.value = [result stringForColumn:@"password"];
            key.type = [result intForColumn:@"keyType"];
            [keys addObject:key];
        }
        _keys = keys.copy;
    }
    
    return _keys;
}

@end
