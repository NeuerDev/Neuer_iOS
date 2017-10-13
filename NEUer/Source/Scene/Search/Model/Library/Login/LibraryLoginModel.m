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
    
    NSString *urlStr1 = [NSString stringWithFormat:@"http://202.118.8.7:8991/F?func=file&file_name=login-session"];
    NSURL *url1 = [NSURL URLWithString:urlStr1];
    
    JHRequest *request1 = [[JHRequest alloc] initWithUrl:url1];
    request1.delegate = self;
    request1.requestType = JHRequestTypeCancelPrevious;
    [request1 start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self gotoLogin];
    });
}

- (void)gotoLogin {
    _username = @"20154858";
    _password = @"154858";
   
    NSString *urlStr = [NSString stringWithFormat:@"%@",_tmpUrl];
//    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/F"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url method:@"POST" params:@{@"func":@"login-session".URLEncode,@"login_source":@"bor-info".URLEncode,@"bor_id":_username.URLEncode,@"bor_verification":_password.URLEncode,@"bor_library":@"NEU50".URLEncode}];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    
    NSData *htmlData = request.response.data;
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    // 获取 var tmp 暂存索引 服务器生成的 必须保存
    NSArray<TFHppleElement *> *formArray = [xpathParser searchWithXPathQuery:@"//form[@name='form1']"];
    _tmpUrl = [formArray[0] objectForKey:@"action"];
    
    NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    NSLog(@"htmlStr - %@",_tmpUrl);
}

- (void)requestDidFail:(JHRequest *)request {
    
}

@end
