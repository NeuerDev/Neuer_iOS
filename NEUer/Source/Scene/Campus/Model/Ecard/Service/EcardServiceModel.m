//
//  EcardServiceModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardServiceModel.h"

@interface EcardServiceModel () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

// 页面信息
@property (nonatomic, strong) NSString *viewStateStr;
@property (nonatomic, strong) NSString *lastFocusStr;
@property (nonatomic, strong) NSString *eventTargetStr;
@property (nonatomic, strong) NSString *eventArgumentStr;
@property (nonatomic, strong) NSString *eventValidationStr;

@end

@implementation EcardServiceModel

- (void)changePasswordWithOldPassword:(NSString *)oldPassword
                          newPassword:(NSString *)newPassword
                        renewPassword:(NSString *)renewPassword
                             complete:(EcardActionCompleteBlock)complete {
    [self prepareForChangePassword:^(BOOL success, NSError *error) {
        if (success) {
            [self executeChangePasswordWithOldPassword:oldPassword
                                           newPassword:newPassword
                                         renewPassword:renewPassword
                                              complete:complete];
        } else {
            
        }
    }];
}

- (void)reportLostWithPassword:(NSString *)password
                identityNumber:(NSString *)identityNumber
                      complete:(EcardActionCompleteBlock)block {
    
}

#pragma mark - Private

- (void)prepareForChangePassword:(EcardActionCompleteBlock)complete {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/User/UpdatePwd.aspx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    WS(ws);
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
            
            NSArray<TFHppleElement *> *viewStateArray = [xpathParser searchWithXPathQuery:@"//*[@id='__VIEWSTATE']"];
            ws.viewStateStr = [[viewStateArray firstObject] objectForKey:@"value"] ? : @"";
            NSArray<TFHppleElement *> *eventValidationArray = [xpathParser searchWithXPathQuery:@"//*[@id='__EVENTVALIDATION']"];
            ws.eventValidationStr = [[eventValidationArray firstObject] objectForKey:@"value"] ? : @"";
            if (complete) {
                complete(data && !error, error);
            }
        }
    }];
    
    [task resume];
}

- (void)executeChangePasswordWithOldPassword:(NSString *)oldPassword
                                 newPassword:(NSString *)newPassword
                               renewPassword:(NSString *)renewPassword
                                    complete:(EcardActionCompleteBlock)complete {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/User/UpdatePwd.aspx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    urlRequest.HTTPMethod = @"POST";
    NSDictionary *params = @{
                             @"__VIEWSTATE":_viewStateStr,
                             @"__EVENTVALIDATION":_eventValidationStr,
                             @"ctl00$ContentPlaceHolder1$txtPwd":oldPassword,
                             @"ctl00$ContentPlaceHolder1$txtNewCode":newPassword,
                             @"ctl00$ContentPlaceHolder1$txtNewcode2":renewPassword,
                             @"ctl00$ContentPlaceHolder1$btnSave":@"保  存",
                             };
    NSMutableString *bodyStr = [[NSMutableString alloc] init];
    for (NSString *key in params) {
        if (bodyStr.length==0) {
            [bodyStr appendFormat:@"%@=%@", key, params[key]?:@""];
        } else {
            [bodyStr appendFormat:@"&%@=%@", key, params[key]?:@""];
        }
    }
    urlRequest.HTTPBody = [bodyStr.URLEncode dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            NSString *htmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if ([htmlStr containsString:@"密码修改成功"]) {
                [UserCenter.defaultCenter.currentUser.keychain setPassword:newPassword forKeyType:UserKeyTypeECard];
                if (complete) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(YES, nil);
                    });
                }
            } else if ([htmlStr containsString:@"旧密码输入不正确"]) {
                if (complete) {
                    NSError *error = [NSError errorWithDomain:JHErrorDomain code:JHErrorTypeInvaildAccountPassword userInfo:@{NSLocalizedDescriptionKey:@"旧密码输入不正确"}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(NO, error);
                    });
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(NO, error);
            });
        }
    }];
    
    [task resume];
}

- (void)prepareForReportLost:(EcardActionCompleteBlock)complete {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/User/UpdatePwd.aspx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    WS(ws);
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
            
            NSArray<TFHppleElement *> *viewStateArray = [xpathParser searchWithXPathQuery:@"//*[@id='__VIEWSTATE']"];
            ws.viewStateStr = [[viewStateArray firstObject] objectForKey:@"value"] ? : @"";
            NSArray<TFHppleElement *> *eventValidationArray = [xpathParser searchWithXPathQuery:@"//*[@id='__EVENTVALIDATION']"];
            ws.eventValidationStr = [[eventValidationArray firstObject] objectForKey:@"value"] ? : @"";
            if (complete) {
                complete(data && !error, error);
            }
        }
    }];
    
    [task resume];
}

- (void)executeReportLostWithPassword:(NSString *)password
                       identityNumber:(NSString *)identityNumber
                             complete:(EcardActionCompleteBlock)complete {
    
}

#pragma mark - Getter

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{
                                                @"User-Agent":@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Safari/604.1.38",
                                                };
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    
    return _session;
}

@end
