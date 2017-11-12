//
//  EcardLoginModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardLoginModel.h"
#import "TesseractCenter.h"

typedef void(^EcardGetVerifyImageBlock)(UIImage *verifyImage, NSString *verifyCode, NSError *error);

@interface EcardLoginModel () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

// 仅用于获取验证码的cookie
@property (nonatomic, strong) NSString *cookie;

// 页面信息
@property (nonatomic, strong) NSString *viewStateStr;
@property (nonatomic, strong) NSString *lastFocusStr;
@property (nonatomic, strong) NSString *eventTargetStr;
@property (nonatomic, strong) NSString *eventArgumentStr;
@property (nonatomic, strong) NSString *eventValidationStr;

@end

@implementation EcardLoginModel {
    EcardActionCompleteBlock _currentActionBlock;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)loginWithUser:(NSString *)userName password:(NSString *)password complete:(EcardActionCompleteBlock)block {
    WS(ws);
    _username = userName;
    _password = password;
    _currentActionBlock = block;
    [self getVerifyImage:^(UIImage *verifyImage, NSString *verifyCode, NSError *error) {
        [ws authorUser:userName password:password verifyCode:verifyCode complete:nil];
    }];
}

#pragma mark - Private Methods

- (BOOL)isAvailableCode:(NSString *)code {
    code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange range = [code rangeOfString:@"^\\d{4}$" options:NSRegularExpressionSearch];
    if (code.length==4 && range.location!=NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

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
                if (image && !error) {
                    NSString *verifyCode = @"";
                    G8Tesseract *tesseract = [TesseractCenter defaultCenter].tesseract;
                    tesseract.image = image;
                    if (tesseract.recognize && [ws isAvailableCode:tesseract.recognizedText]) {
                        NSLog(@"识别成功 : %@", tesseract.recognizedText);
                        verifyCode = [tesseract.recognizedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(image, verifyCode, error);
                        });
                    } else {
                        NSLog(@"识别失败 : %@", tesseract.recognizedText);
                        [ws getVerifyImage:block];
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, nil, error);
                    });
                }
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
        // 登录失败 密码错误
        if (_currentActionBlock) {
            NSError *error = [NSError errorWithDomain:JHErrorDomain code:JHErrorTypeInvaildAccountPassword userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                _currentActionBlock(NO, error);
            });
        }
        _currentActionBlock = nil;
    }];
    
    [task resume];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    NSLog(@"登录跳转了 %@", request.URL.absoluteString);
    if ([request.URL.absoluteString isEqualToString:@"http://ecard.neu.edu.cn/SelfSearch/Index.aspx"]) {
        // 登录成功 进入首页
        __strong EcardActionCompleteBlock block = _currentActionBlock;
        NSURLSessionDataTask *newTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (block) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(data && !error, error);
                });
            }
        }];
        [newTask resume];
    } else {
        
    }
    
    _currentActionBlock = nil;
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
