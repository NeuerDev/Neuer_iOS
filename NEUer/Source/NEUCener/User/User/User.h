//
//  User.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/2.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserKeychain.h"

@interface User : NSObject

@property (nonatomic, strong) NSString *number;     // 学号
@property (nonatomic, strong) NSString *realName;   // 真实姓名
@property (nonatomic, strong) NSString *nickName;   // 昵称
@property (nonatomic, assign) NSInteger sex;        // 0 未知, 1 男, 2 女
@property (nonatomic, strong) NSString *campus;     // 学院
@property (nonatomic, strong) NSString *major;      // 专业
@property (nonatomic, strong) NSData *imageData;    // 照片
@property (nonatomic, strong) NSString *avatarUrl;  // 自定义头像
@property (nonatomic, strong) NSString *wechatId;   // 微信id
@property (nonatomic, strong) NSString *weiboId;    // 微博id
@property (nonatomic, strong) NSString *qqId;       // QQid
@property (nonatomic, assign) NSTimeInterval enrollDate;   // 入学日期
@property (nonatomic, strong) NSString *token;

@property (nonatomic, assign) NSTimeInterval lastLoginTime;  // 最后登录时间戳

+ (NSArray<User *> *)allUsers;

+ (instancetype)userWithNumber:(NSString *)number;

- (void)authorWithAccount:(NSString *)account password:(NSString *)password complete:(void (^)(BOOL, NSString *))complete;

- (void)authorComplete:(void (^)(BOOL, NSString *))complete;

- (UserKeychain *)keychain;

- (void)setPassword:(NSString *)password forKeyType:(UserKeyType)keyType;

- (void)commitUpdates;
@end
