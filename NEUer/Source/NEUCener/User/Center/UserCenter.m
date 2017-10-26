//
//  UserCenter.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "UserCenter.h"
#import "User.h"

static UserCenter *_singletonCenter = nil;

@interface UserCenter ()

@property (nonatomic, strong) User *currentUser;

@end

@implementation UserCenter

#pragma mark - Singleton

+ (instancetype)defaultCenter {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletonCenter = [super allocWithZone:zone];
    });
    return _singletonCenter;
}

- (instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletonCenter = [super init];
    });
    return _singletonCenter;
}

- (instancetype)copyWithZone:(NSZone *)zone{
    return _singletonCenter;
}

+ (instancetype)copyWithZone:(struct _NSZone *)zone{
    return _singletonCenter;
}

+ (instancetype)mutableCopyWithZone:(struct _NSZone *)zone{
    return _singletonCenter;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone{
    return _singletonCenter;
}

#pragma mark - Public Methods

- (void)setup {
    User *currentUser = nil;
    for (User *user in self.allUsers) {
        if (!currentUser || user.lastLoginTime > currentUser.lastLoginTime) {
            currentUser = user;
        } else {
            continue;
        }
    }
    
    _currentUser = currentUser;
}

- (NSArray<User *> *)allUsers {
    return [User allUsers];
}

- (void)switchToUser:(User *)user complete:(void (^)(BOOL success, NSString *message))complete {
    WS(ws);
    [user authorComplete:^(BOOL success, NSString *message) {
        if (success) {
            ws.currentUser = user;
        } else {
            
        }
        
        complete(success, message);
    }];
}

- (void)authorWithAccount:(NSString *)account password:(NSString *)password complete:(void (^)(BOOL, NSString *))complete {
    User *user = [[User alloc] init];
    WS(ws);
    [user authorWithAccount:account password:password complete:^(BOOL success, NSString *message) {
        if (success) {
            ws.currentUser = user;
            [user commitUpdates];
        }
        
        complete(success, message);
    }];
}

- (void)logout {
    
}

- (void)connectWithWechat:(NSString *)wechatId {
    
}

- (void)connectWithQQ:(NSString *)qqId {
    
}

- (void)connectWithWeibo:(NSString *)weiboId {
    
}

- (void)setAccount:(NSString *)account password:(NSString *)password forKeyType:(UserKeyType)keyType {
    User *user = nil;
    for (User *tempUser in self.allUsers) {
        if ([tempUser.number isEqualToString:account]) {
            user = tempUser;
            break;
        }
    }
    
    if (user) {
        [user setPassword:password forKeyType:keyType];
    } else {
        User *user = [[User alloc] init];
        user.number = account;
        [self addUser:user];
        [user setPassword:password forKeyType:keyType];
    }
}

#pragma mark - Private Methods

- (void)addUser:(User *)user {
    _currentUser = user;
    [user commitUpdates];
}

- (User *)currentUser {
    if (!_currentUser) {
        _currentUser = [User allUsers].firstObject;
    }
    
    return _currentUser;
}

@end
