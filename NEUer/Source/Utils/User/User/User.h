//
//  User.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/2.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserKeychain;

@interface User : NSObject

@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *realName;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *wechatId;
@property (nonatomic, strong) NSDate *enrollDate;
@property (nonatomic, strong) UserKeychain *keychain;

- (void)authorWithAccount:(NSString *)account password:(NSString *)password complete:(void (^)(BOOL, NSString *))complete;

- (void)authorComplete:(void (^)(BOOL, NSString *))complete;

@end
