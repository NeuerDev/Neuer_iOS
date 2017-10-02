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

- (NSArray<User *> *)allUsers {
    return nil;
}

- (void)switchToUser:(User *)user complete:(void (^)(BOOL success, NSString *message))complete {
    [user authorComplete:^(BOOL success, NSString *message) {
        if (success) {
            _currentUser = user;
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

@end
