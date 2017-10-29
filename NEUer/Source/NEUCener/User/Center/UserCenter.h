//
//  UserCenter.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@interface UserCenter : NSObject

@property (nonatomic, strong, readonly) User *currentUser;

/**
 获得用户中心单例对象
 用于管理登陆的用户

 @return instancetype
 */
+ (instancetype)defaultCenter;

/**
 初始化用户中心
 */
- (void)setup;

/**
 返回所有登录过的用户

 @return 用户数组
 */
- (NSArray<User *> *)allUsers;


/**
 切换用户，如果教务处认证通过则切换成功，否则要输入密码重新验证

 @param user 新用户
 @param complete 回调
 */
- (void)switchToUser:(User *)user complete:(void(^)(BOOL success, NSString *message))complete;


/**
 验证并登录

 @param account 教务处学号
 @param password 教务处密码
 @param complete 回调
 */
- (void)authorWithAccount:(NSString *)account password:(NSString *)password complete:(void(^)(BOOL success, NSString *message))complete;


/**
 登出 切换用户
 */
- (void)logout;

- (void)connectWithWechat:(NSString *)wechatId;

- (void)connectWithWeibo:(NSString *)weiboId;

- (void)connectWithQQ:(NSString *)qqId;

- (void)setAccount:(NSString *)account password:(NSString *)password forKeyType:(UserKeyType)keyType;

@end
