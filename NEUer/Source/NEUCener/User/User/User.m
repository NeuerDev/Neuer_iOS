//
//  User.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/2.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "User.h"
#import "UserKeychain.h"

@implementation User

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
                    [ws.keychain setPassword:password forType:UserKeyTypeAAO];
                    ws.realName = resultDic[@"data"][@"realName"];
                    ws.number = resultDic[@"data"][@"userName"];
                    ws.token = resultDic[@"data"][@"token"];
                    complete(YES, @"author success");
                } else {
                    [ws.keychain setPassword:@"" forType:UserKeyTypeAAO];
                    complete(NO, @"author failed");
                }
            } else {
                complete(NO, @"author failed");
            }
        } else {
            complete(NO, @"author failed");
            NSLog(@"xxxxx");
        }
    };
    [request start];
}

- (void)authorComplete:(void (^)(BOOL, NSString *))complete {
    [self authorWithAccount:self.number password:[self.keychain passwordForType:UserKeyTypeAAO] complete:complete];
}

#pragma mark - Getter

- (UserKeychain *)keychain {
    if (!_keychain) {
        _keychain = [UserKeychain keychainForUser:self];
    }
    
    return _keychain;
}

@end
