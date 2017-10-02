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
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://202.118.31.241:8080/api/v1/login?userName=%@&passwd=%@", account, password.md5]];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.completeBlock = ^(JHRequest *request) {
        JHResponse *response = request.response;
        if (response.success) {
            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:[[NSString stringFromGBKData:response.data] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]);
            if (YES) {
                [self.keychain setPassword:password forType:UserKeyTypeAAO];
            } else {
                [self.keychain setPassword:@"" forType:UserKeyTypeAAO];
            }
        } else {
            NSLog(@"xxxxx");
        }
    };
    [request start];
}

- (void)authorComplete:(void (^)(BOOL, NSString *))complete {
    [self authorWithAccount:self.number password:[self.keychain passwordForType:UserKeyTypeAAO] complete:complete];
}

@end
