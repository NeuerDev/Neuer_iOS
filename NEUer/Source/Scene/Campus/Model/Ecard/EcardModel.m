//
//  EcardModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardModel.h"

@interface EcardModel () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSString *cookie;

@property (nonatomic, strong) NSString *viewStateStr;
@property (nonatomic, strong) NSString *lastFocusStr;
@property (nonatomic, strong) NSString *eventTargetStr;
@property (nonatomic, strong) NSString *eventArgumentStr;
@property (nonatomic, strong) NSString *eventValidationStr;

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation EcardModel

- (void)getVerifyImage:(EcardGetVerifyImageBlock)block {
    WS(ws);
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/Login.aspx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
                block(image, @"");
            });
        }];
    }];
    [task resume];
}

- (void)authorUser:(NSString *)userName password:(NSString *)password verifyCode:(NSString *)verifyCode {
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

- (void)fetchAvatar {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/User/Photo.ashx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    WS(ws);
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            ws.info.avatarImage = image;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.infoDelegate fetchAvatarSuccess:(data && !error) error:error];
        });
    }];
    
    [task resume];
}

- (void)queryInfo {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/User/Home.aspx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    WS(ws);
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            ws.info = [[EcardInfoBean alloc] init];
            TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
            
            NSArray<TFHppleElement *> *infoArray = [xpathParser searchWithXPathQuery:@"//div[@class='person_news']/ul/li/span"];
            for (TFHppleElement *info in infoArray) {
                NSString *string = info.text;
                if ([string hasPrefix:@"学(工)号："]) {
                    ws.info.number = [string substringFromIndex:@"学(工)号：".length];
                } else if ([string hasPrefix:@"卡状态："]) {
                    ws.info.state = [string substringFromIndex:@"卡状态：".length];
                } else if ([string hasPrefix:@"姓名："]) {
                    ws.info.name = [string substringFromIndex:@"姓名：".length];
                } else if ([string hasPrefix:@"主钱包余额："]) {
                    ws.info.balance = [string substringFromIndex:@"主钱包余额：".length];
                } else if ([string hasPrefix:@"性别："]) {
                    ws.info.sex = [string substringFromIndex:@"性别：".length];
                } else if ([string hasPrefix:@"补助余额："]) {
                    ws.info.allowance = [string substringFromIndex:@"补助余额：".length];
                } else if ([string hasPrefix:@"身份："]) {
                    ws.info.status = [string substringFromIndex:@"身份：".length];
                }
            }
            
            TFHppleElement *departmemtInfoElement = [[xpathParser searchWithXPathQuery:@"//div[@class='person_news']/ul/li"] lastObject];
            if ([departmemtInfoElement.text hasPrefix:@"部门："]) {
                NSArray *array = [[departmemtInfoElement.text substringFromIndex:@"部门：".length] componentsSeparatedByString:@"/"];
                if (array.count >= 2) {
                    ws.info.campus = array[0];
                    ws.info.major = array[1];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.infoDelegate queryInfoSuccess:(data && !error) error:error];
        });
    }];
    
    [task resume];
}

- (void)queryConsumeHistory {
    
}

- (void)queryConsumeStatisics {
    
}

- (void)reportLost {
    
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    WS(ws);
    NSURLSessionDataTask *newTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [ws.loginDelegate loginSuccess:(data && !error) error:error];
    }];
    [newTask resume];
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

@implementation EcardInfoBean

@end;
