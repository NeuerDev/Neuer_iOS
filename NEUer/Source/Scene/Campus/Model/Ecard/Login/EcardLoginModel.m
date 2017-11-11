//
//  EcardLoginModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardLoginModel.h"
#import "TesseractCenter.h"

typedef void(^EcardGetVerifyImageBlock)(UIImage *verifyImage, NSError *error);

@interface EcardLoginModel () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

// 仅用于获取验证码的cookie
@property (nonatomic, strong) NSString *cookie;

// 页面信息
@property (nonatomic, strong) NSString *viewStateStr;
@property (nonatomic, strong) NSString *lastFocusStr;
@property (nonatomic, strong) NSString *eventTargetStr;
@property (nonatomic, strong) NSString *eventArgumentStr;
@property (nonatomic, strong) NSString *eventValidationStr;

@end

@implementation EcardLoginModel

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)loginWithUser:(NSString *)userName password:(NSString *)password complete:(EcardActionCompleteBlock)block {
    WS(ws);
    [self getVerifyImage:^(UIImage *verifyImage, NSError *error) {
        if (verifyImage) {
            
            [ws authorUser:userName password:password verifyCode:nil complete:^(BOOL success, NSError *error) {
                
            }];
        }
    }];
}

#pragma mark - Private Methods

- (void)getVerifyImage:(EcardGetVerifyImageBlock)block {
    WS(ws);
    
    NSArray<NSHTTPCookie *> *cookies = self.session.configuration.HTTPCookieStorage.cookies;
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.domain isEqualToString:@"ecard.neu.edu.cn"]) {
            [self.session.configuration.HTTPCookieStorage deleteCookie:cookie];
        }
    }
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/Login.aspx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 提取当前cookie 仅用于获取验证码
        NSString *setCookies = ((NSHTTPURLResponse *)response).allHeaderFields[@"Set-Cookie"];
        for (NSString *string in [setCookies componentsSeparatedByString:@";"]) {
            NSArray *components = [string componentsSeparatedByString:@"="];
            if (components.count==2&&[components[0] isEqualToString:@"ASP.NET_SessionId"]) {
                ws.cookie = [NSString stringWithFormat:@".NECEID=1; .NEWCAPEC1=$newcapec$:zh-CN_CAMPUS; ASP.NET_SessionId=%@", components[1]];
                break;
            } else {
                continue;
            }
        }
        
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        
        NSArray<TFHppleElement *> *viewStateArray = [xpathParser searchWithXPathQuery:@"//*[@id='__VIEWSTATE']"];
        ws.viewStateStr = [[viewStateArray firstObject] objectForKey:@"value"] ? : @"";
        ws.eventTargetStr = @"btnLogin";
        ws.eventArgumentStr = @"";
        NSArray<TFHppleElement *> *eventValidationArray = [xpathParser searchWithXPathQuery:@"//*[@id='__EVENTVALIDATION']"];
        ws.eventValidationStr = [[eventValidationArray firstObject] objectForKey:@"value"] ? : @"";
        NSArray<TFHppleElement *> *lastFocusArray = [xpathParser searchWithXPathQuery:@"//*[@id='__LASTFOCUS']"];
        ws.lastFocusStr = [[lastFocusArray firstObject] objectForKey:@"value"] ? : @"";
        
        SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageDownloader;
        [downloader setValue:ws.cookie forHTTPHeaderField:@"Cookie"];
        [downloader downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ecard.neu.edu.cn/SelfSearch/validateimage.ashx?%.16lf", rand()/(double)RAND_MAX]] options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image, error);
            });
        }];
    }];
    [task resume];
}

- (void)authorUser:(NSString *)userName password:(NSString *)password verifyCode:(NSString *)verifyCode complete:(EcardActionCompleteBlock)block {
    WS(ws);
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/Login.aspx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    urlRequest.HTTPMethod = @"POST";
    NSDictionary *params = @{
                             @"__VIEWSTATE":ws.viewStateStr,
                             @"__EVENTTARGET":ws.eventTargetStr,
                             @"__EVENTARGUMENT":ws.eventArgumentStr,
                             @"__EVENTVALIDATION":ws.eventValidationStr,
                             @"__LASTFOCUS":ws.lastFocusStr,
                             @"txtUserName":userName,
                             @"txtPassword":password,
                             @"txtVaildateCode":verifyCode,
                             @"hfIsManager":@"0",
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
        
    }];
    
    [task resume];
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
