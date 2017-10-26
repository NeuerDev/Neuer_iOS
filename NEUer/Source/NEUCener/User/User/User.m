//
//  User.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/2.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "User.h"
#import "UserKeychain.h"

@interface User ()

@property (nonatomic, strong) UserKeychain *keychain;

@end

@implementation User

+ (NSArray<User *> *)allUsers {
    NSMutableArray *allUsers = @[].mutableCopy;
    FMDatabase *db = [DataBaseCenter defaultCenter].database;
    FMResultSet *result = [db executeQuery:@"select * from t_user order by lastLoginTime desc"];
    while ([result next]) {
        User *user = [[User alloc] init];
        user.number = [result stringForColumn:@"number"];
        user.realName = [result stringForColumn:@"realName"];
        user.nickName = [result stringForColumn:@"nickName"];
        user.sex = [result intForColumn:@"sex"];
        user.campus = [result stringForColumn:@"campus"];
        user.major = [result stringForColumn:@"major"];
        user.imageData = [result dataForColumn:@"imageData"];
        user.avatarUrl = [result stringForColumn:@"avatarUrl"];
        user.wechatId = [result stringForColumn:@"wechatId"];
        user.weiboId = [result stringForColumn:@"weiboId"];
        user.qqId = [result stringForColumn:@"qqId"];
        user.enrollDate = [result intForColumn:@"enrollDate"];
        user.token = [result stringForColumn:@"token"];
        user.lastLoginTime = [result intForColumn:@"lastLoginTime"];
        [allUsers addObject:user];
    }
    return allUsers.copy;
}

+ (instancetype)userWithNumber:(NSString *)number {
    User *user = nil;
    FMDatabase *db = [DataBaseCenter defaultCenter].database;
    FMResultSet *result = [db executeQuery:@"select * from t_user where number = ?", number];
    while ([result next]) {
        user = [[User alloc] init];
        user.number = [result stringForColumn:@"number"];
        user.realName = [result stringForColumn:@"realName"];
        user.nickName = [result stringForColumn:@"nickName"];
        user.sex = [result intForColumn:@"sex"];
        user.campus = [result stringForColumn:@"campus"];
        user.major = [result stringForColumn:@"major"];
        user.imageData = [result dataForColumn:@"imageData"];
        user.avatarUrl = [result stringForColumn:@"avatarUrl"];
        user.wechatId = [result stringForColumn:@"wechatId"];
        user.weiboId = [result stringForColumn:@"weiboId"];
        user.qqId = [result stringForColumn:@"qqId"];
        user.enrollDate = [result intForColumn:@"enrollDate"];
        user.token = [result stringForColumn:@"token"];
        user.lastLoginTime = [result intForColumn:@"lastLoginTime"];
    }
    
    return user;
}

- (void)authorWithAccount:(NSString *)account password:(NSString *)password complete:(void (^)(BOOL, NSString *))complete {
    WS(ws);
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://202.118.31.241:8080/api/v1/login?userName=%@&passwd=%@", account, password.md5]];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.completeBlock = ^(JHRequest *request) {
        JHResponse *response = request.response;
        if (response.success) {
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:[[NSString stringFromGBKData:response.data] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if (resultDic) {
                if ([resultDic[@"success"] isEqualToString:@"0"]) {
                    [ws.keychain setPassword:password forKeyType:UserKeyTypeAAO];
                    ws.realName = resultDic[@"data"][@"realName"];
                    ws.number = resultDic[@"data"][@"userName"];
                    ws.token = resultDic[@"data"][@"token"];
                    complete(YES, @"author success");
                } else {
                    [ws.keychain setPassword:@"" forKeyType:UserKeyTypeAAO];
                    complete(NO, @"author failed");
                }
            } else {
                complete(NO, @"author failed");
            }
        } else {
            complete(NO, @"author failed");
        }
    };
    [request start];
}

- (void)authorComplete:(void (^)(BOOL, NSString *))complete {
    [self authorWithAccount:self.number password:[self.keychain passwordForKeyType:UserKeyTypeAAO] complete:complete];
}

- (void)setPassword:(NSString *)password forKeyType:(UserKeyType)keyType {
    [self.keychain setPassword:password forKeyType:keyType];
}

- (void)commitUpdates {
    User *user = [User userWithNumber:_number];
    FMDatabase *db = [DataBaseCenter defaultCenter].database;
    
    [db executeUpdate:@"replace into t_user (number ,realName, nickName, sex, campus, major, imageData, avatarUrl, wechatId, qqId, weiboId, enrollDate, token, lastLoginTime) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _number, _realName ? : user.realName, _nickName ? : user.nickName, @(_sex == 0 ? : user.sex), _campus ? : user.campus, _major ? : user.major, _imageData ? : user.imageData, _avatarUrl ? : user.avatarUrl, _wechatId ? : user.wechatId, _qqId ? : user.qqId, _weiboId ? : user.weiboId, @(_enrollDate ? : user.enrollDate), _token ? : user.token, @([[[NSDate alloc] init] timeIntervalSince1970])];
}

#pragma mark - Getter

- (UserKeychain *)keychain {
    if (!_keychain) {
        _keychain = [UserKeychain keychainForUser:self];
    }
    
    return _keychain;
}

@end
