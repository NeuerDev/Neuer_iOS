//
//  LibraryLoginModel.m
//  NEUer
//
//  Created by kl h on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryLoginModel.h"

@interface LibraryLoginModel () <JHRequestDelegate>

@end

@implementation LibraryLoginModel
#pragma mark - Public Methods
- (void)login {
    
    _username = @"20154858";
    _password = @"154858";
    
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/F?func=login-session&login_source=bor-info&bor_id=%@&bor_verification=%@&bor_library=NEU50",_username.URLEncode,_password.URLEncode];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    
    NSData *htmlData = request.response.data;
    NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    NSLog(@"htmlStr - %@",htmlStr);
}

- (void)requestDidFail:(JHRequest *)request {
    
}

@end
