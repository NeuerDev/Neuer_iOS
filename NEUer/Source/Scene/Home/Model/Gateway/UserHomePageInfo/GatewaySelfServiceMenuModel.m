//
//  GatewaySelfServiceMenuModel.m
//  NEUer
//
//  Created by lanya on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewaySelfServiceMenuModel.h"

@interface GatewaySelfServiceMenuModel () <JHRequestDelegate, NSURLSessionDelegate>

@property (nonatomic, copy) NSString *cookie;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, strong) NSString *loginStr;
@property (nonatomic, strong) NSString *csrfStr;
@property (nonatomic, strong) NSString *csrfCookieStr;
@property (nonatomic, strong) NSString *PHPSESSIDStr;

@end

@implementation GatewaySelfServiceMenuModel
{
    GatewaySelfServiceMenuLoginBlock _loginBlock;
    GatewaySelfServiceMenuQueryBlock _queryBlock;
    NSInteger _logDetailPage;
    NSInteger _financialPayPage;
    NSInteger _financialCheckoutPage;
}

#pragma mark - InitMethod
- (instancetype)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

- (void)initData {
    _logDetailPage = 1;
    _financialPayPage = 1;
    _financialCheckoutPage = 1;
}


#pragma mark - Public Method

- (void)refreshData {
    _logDetailPage = 1;
    _financialPayPage = 1;
    _financialCheckoutPage = 1;
}

- (void)getVerifyImage:(GatewaySelfServiceMenuGetVerifyImageBlock)block {
    
    NSArray<NSHTTPCookie *> *cookies = self.session.configuration.HTTPCookieStorage.cookies;
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.domain isEqualToString:@"ipgw.neu.edu.cn"]) {
            [self.session.configuration.HTTPCookieStorage deleteCookie:cookie];
        }
    }
//    http://ipgw.neu.edu.cn/srun_portal_pc.php?ac_id=1&
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        NSString *setCookies = ((NSHTTPURLResponse *)response).allHeaderFields[@"Set-Cookie"];
        for (NSString *strings in [setCookies componentsSeparatedByString:@";"]) {
            NSArray *componentsString = [strings componentsSeparatedByString:@"="];
            for (int i = 0; i < componentsString.count; ++i) {
                if ([componentsString[i] containsString:@"PHPSESSID"]) {
                    _PHPSESSIDStr = [NSString stringWithFormat:@"PHPSESSID=%@;", componentsString[++i]];
                } else if ([componentsString[i] containsString:@"_csrf"]) {
                    _csrfCookieStr= [NSString stringWithFormat:@"_csrf=%@;", componentsString[++i]];
                } else {
                    continue;
                }
            }
        }
        NSMutableString *cookieMutableString = [self.PHPSESSIDStr stringByAppendingString:@"login=1234567;"].mutableCopy;
        cookieMutableString = [cookieMutableString stringByAppendingString:self.csrfCookieStr].mutableCopy;
        _cookie = cookieMutableString.copy;
        
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        
        NSArray *dataArray = [hpple searchWithXPathQuery:@"//*[@id='loginform-verifycode-image']"];
        
        NSMutableString *imgStr = [NSMutableString stringWithCapacity:0];
        for (TFHppleElement *element in dataArray) {
            if ([element objectForKey:@"src"]) {
                imgStr = [element objectForKey:@"src"].mutableCopy;
            }
        }
        _imgUrl = [@"http://ipgw.neu.edu.cn:8800" stringByAppendingString:imgStr].copy;
        
        SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
        [downloader setValue:self.cookie forHTTPHeaderField:@"Cookie"];
        [downloader downloadImageWithURL:[NSURL URLWithString:self.imgUrl] options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(image, @"success");
                }
            });
        }];
        
        NSArray *crsfArray = [hpple searchWithXPathQuery:@"/html/head/meta[7]"];
        for (TFHppleElement *element in crsfArray) {
            if ([element objectForKey:@"content"]) {
                _csrfStr = [element objectForKey:@"content"];
            }
        }
    }];
    [task resume];
}

- (void)loginGatewaySelfServiceMenuWithUser:(NSString *)account password:(NSString *)password verifyCode:(NSString *)verifyCode loginState:(GatewaySelfServiceMenuLoginBlock)block{

    NSDictionary *param = @{
                            @"_csrf" : self.csrfStr,
                            @"LoginForm[username]" : account,
                            @"LoginForm[password]" : password,
                            @"LoginForm[verifyCode]" : verifyCode,
                            @"login-button" : @""
                            };
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/site/index"] method:@"POST" params:param];
    request.delegate = self;
    request.requestType = JHRequestTypeNone;
    [request start];

    _loginBlock = block;
    
}

- (void)queryUserBasicInformationListComplete:(GatewaySelfServiceMenuQueryBlock)block {
    
    _queryBlock = block;
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/home/base/index"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *dataArray = [hpple searchWithXPathQuery:@"//li[@class='list-group-item']"];
        _basicInfo = [[GatewaySelfServiceMenuBasicInfoBean alloc] init];
        NSMutableArray *infoArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (TFHppleElement *elements in dataArray) {
            NSArray *textArray = [elements childrenWithTagName:@"text"];
            
            TFHppleElement *lastElement = ((TFHppleElement *)[textArray lastObject]);
            NSString *tempString = [lastElement.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [infoArray addObject:tempString];
        }
        if (infoArray.count >= 15) {
            _basicInfo.user_number = infoArray[0];
            _basicInfo.user_name = infoArray[1];
            _basicInfo.user_E_walletBalance = infoArray[3];
            
            _basicInfo.product_ID = infoArray[4];
            _basicInfo.product_name = infoArray[5];
            _basicInfo.product_accountingStrategy = infoArray[6];
            _basicInfo.product_usedFlow = infoArray[7];
            _basicInfo.product_usedDuration = infoArray[8];
            _basicInfo.product_usedTimes = infoArray[9];
            _basicInfo.product_usedAmount = infoArray[10];
            _basicInfo.product_balance = infoArray[11];
            _basicInfo.product_carrierBundle = infoArray[12];
            _basicInfo.product_closingDate = infoArray[14];
            
            _queryBlock(YES, @"成功！");
        } else {
            _queryBlock(NO, @"失败");
        }
        
    }];
    
    [dataTask resume];
}

- (void)queryUserOnlineInformationListComplete:(GatewaySelfServiceMenuQueryBlock)block {
    
    _queryBlock = block;
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/home/base/index"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        
        TFHppleElement *tempInfoElement = [[hpple searchWithXPathQuery:@"//table[@class='table table-bordered']"] firstObject];
        TFHppleElement *onlineInfoElement = [[tempInfoElement childrenWithTagName:@"tr"] lastObject];
        NSArray *onlineInfoArray = [onlineInfoElement childrenWithTagName:@"td"];
        
        _onlineInfo = [[GatewaySelfServiceMenuOnlineInfoBean alloc] init];
        if (onlineInfoArray.count >= 6) {
            _onlineInfo.online_number = onlineInfoArray[0];
            _onlineInfo.online_ipAddress = onlineInfoArray[1];
            _onlineInfo.online_productName = onlineInfoArray[2];
            _onlineInfo.online_lastactive = onlineInfoArray[3];
            _onlineInfo.online_operation = onlineInfoArray[4];
            _onlineInfo.online_AccountingStrategy = onlineInfoArray[5];
            
            _queryBlock(YES, @"成功！");
        } else {
            _queryBlock(NO, @"失败");
        }
        
    }];
    
    [dataTask resume];
}

- (void)modifyPasswordForIPGWwithOldPassword:(NSString *)oldpassword newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword Complete:(GatewaySelfServiceMenuQueryBlock)block {
    _queryBlock = block;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/user/chgpwd/index"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];

    request.HTTPMethod = @"POST";
    NSDictionary *params = @{
                             @"_csrf" : self.csrfCookieStr,
                             @"ModifyPasswordForm[old_password]" : oldpassword,
                             @"ModifyPasswordForm[user_password]" : newPassword,
                             @"ModifyPasswordForm[user_password2]" : confirmPassword
                             };
    
    request.HTTPBody = [params.queryString.URLEncode dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([response.URL.absoluteString isEqualToString:@"http://ipgw.neu.edu.cn:8800/site/index"]) {
            _queryBlock(YES, @"密码修改成功");
        } else if ([response.URL.absoluteString isEqualToString:@"http://ipgw.neu.edu.cn:8800/user/chgpwd/index"]) {
            _queryBlock(NO, @"密码修改失败");
        } else {
            _queryBlock(NO, @"出现错误");
        }
    }];
    [task resume];
}

- (void)queryUserOnlineLogDetailListComplete:(GatewaySelfServiceMenuQueryBlock)block {
    _queryBlock = block;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ipgw.neu.edu.cn:8800/log/detail/index?page=%ld&per-page=10", _logDetailPage]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        NSMutableArray <GatewaySelfServiceMenuInternetRecordsInfoBean *> *internetMutableArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        TFHppleElement *element = [[hpple searchWithXPathQuery:@"//*[@class='table table-bordered detail-view']/tbody"] lastObject];
        NSArray *tempArray = [element childrenWithTagName:@"tr"];
        for (TFHppleElement *element in tempArray) {
            NSArray *recordDataArray = [element childrenWithTagName:@"td"];
            if (recordDataArray.count == 8) {
                GatewaySelfServiceMenuInternetRecordsInfoBean *recordInfo = [[GatewaySelfServiceMenuInternetRecordsInfoBean alloc] init];
                recordInfo.internet_number = ((TFHppleElement *)recordDataArray[0]).text;
                recordInfo.internet_lastactive = ((TFHppleElement *)recordDataArray[1]).text;
                recordInfo.internet_logoutTime = ((TFHppleElement *)recordDataArray[2]).text;
                recordInfo.internet_ipAddress = ((TFHppleElement *)recordDataArray[3]).text;
                recordInfo.internet_operation = ((TFHppleElement *)recordDataArray[4]).text;
                recordInfo.internet_usedFlow = ((TFHppleElement *)recordDataArray[5]).text;
                recordInfo.internet_usedDuration = ((TFHppleElement *)recordDataArray[6]).text;
                recordInfo.internet_usedFee = ((TFHppleElement *)recordDataArray[7]).text;
                
                [internetMutableArray addObject:recordInfo];
            }
        }
        
        if (self.internetRecordInfoArray.count == 0) {
            [self.internetRecordInfoArray addObjectsFromArray:internetMutableArray.mutableCopy];
            _logDetailPage++;
            _queryBlock(YES, @"查询成功");
            return;
        } else {
            if (![[self.internetRecordInfoArray lastObject].internet_lastactive isEqualToString:[internetMutableArray lastObject].internet_lastactive]) {
                [self.internetRecordInfoArray addObjectsFromArray:internetMutableArray.mutableCopy];
                _logDetailPage++;
                _queryBlock(YES, @"查询成功");
            } else {
                _queryBlock(NO, @"没有更多消息了");
            }
        }
    }];
    [task resume];
}

- (void)queryUserOnlineFinancialPayListComplete:(GatewaySelfServiceMenuQueryBlock)block {
    _queryBlock = block;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ipgw.neu.edu.cn:8800/financial/pay/list?page=%ld&per-page=10", _financialPayPage]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        NSMutableArray <GatewaySelfServiceMenuFinancialPayInfoBean *> *financialMutableArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        TFHppleElement *element = [[hpple searchWithXPathQuery:@"//*[@class='table table-bordered detail-view']/tbody"] lastObject];
        NSArray *tempArray = [element childrenWithTagName:@"tr"];
        for (TFHppleElement *element in tempArray) {
            NSArray *financialDataArray = [element childrenWithTagName:@"td"];
            if (financialDataArray.count == 9) {
                GatewaySelfServiceMenuFinancialPayInfoBean *financialInfo = [[GatewaySelfServiceMenuFinancialPayInfoBean alloc] init];
                financialInfo.financial_number = ((TFHppleElement *)financialDataArray[1]).text;
                financialInfo.financial_payAmmount = ((TFHppleElement *)financialDataArray[2]).text;
                financialInfo.financial_type = ((TFHppleElement *)financialDataArray[3]).text;
                financialInfo.financial_payWay = ((TFHppleElement *)financialDataArray[4]).text;
                financialInfo.financial_product = ((TFHppleElement *)financialDataArray[5]).text;
                financialInfo.financial_creatTime = ((TFHppleElement *)financialDataArray[6]).text;
                financialInfo.financial_administrator = ((TFHppleElement *)financialDataArray[7]).text;
                
                [financialMutableArray addObject:financialInfo];
            }
        }
        
        if (self.financialPayInfoArray.count == 0) {
            [self.financialPayInfoArray addObjectsFromArray:financialMutableArray.mutableCopy];
            _financialPayPage++;
            _queryBlock(YES, @"查询成功");
            return;
        } else {
            if (![[self.financialPayInfoArray lastObject].financial_creatTime isEqualToString:[financialMutableArray lastObject].financial_creatTime]) {
                [self.financialPayInfoArray addObjectsFromArray:financialMutableArray.mutableCopy];
                _financialPayPage++;
                _queryBlock(YES, @"查询成功");
            } else {
                _queryBlock(NO, @"没有更多消息了");
            }
        }
        
    }];
    [task resume];
}

- (void)queryUserFinancialCheckOutListComlete:(GatewaySelfServiceMenuQueryBlock)block {
    
    _queryBlock = block;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ipgw.neu.edu.cn:8800/financial/checkout/list?page=%ld&per-page=10", _financialCheckoutPage]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        NSMutableArray  <GatewaySelfServiceMenuFinancialCheckOutInfoBean *> *financialMutableArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        TFHppleElement *element = [[hpple searchWithXPathQuery:@"//*[@class='table table-bordered detail-view']/tbody"] lastObject];
        NSArray *tempArray = [element childrenWithTagName:@"tr"];
        for (TFHppleElement *element in tempArray) {
            NSArray *financialDataArray = [element childrenWithTagName:@"td"];
            if (financialDataArray.count > 0) {
                GatewaySelfServiceMenuFinancialCheckOutInfoBean *checkoutInfo = [[GatewaySelfServiceMenuFinancialCheckOutInfoBean alloc] init];
                checkoutInfo.checkout_number = ((TFHppleElement *)financialDataArray[1]).text;
                checkoutInfo.checkout_payAmmount = ((TFHppleElement *)financialDataArray[2]).text;
                checkoutInfo.checkout_product = ((TFHppleElement *)financialDataArray[3]).text;
                checkoutInfo.checkout_combo = ((TFHppleElement *)financialDataArray[4]).text;
                checkoutInfo.checkout_flow = ((TFHppleElement *)financialDataArray[5]).text;
                checkoutInfo.checkout_time = ((TFHppleElement *)financialDataArray[6]).text;
                checkoutInfo.checkout_creatTime = ((TFHppleElement *)financialDataArray[8]).text;
                
                [financialMutableArray addObject:checkoutInfo];
            }
        }
        
        if (self.financialCheckoutInfoArray.count == 0) {
            [self.financialCheckoutInfoArray addObjectsFromArray:financialMutableArray.mutableCopy];
            _financialCheckoutPage++;
            _queryBlock(YES, @"查询成功");
            return;
        } else {
            if (![[self.financialCheckoutInfoArray lastObject].checkout_creatTime isEqualToString:[financialMutableArray lastObject].checkout_creatTime]) {
                [self.financialCheckoutInfoArray addObjectsFromArray:financialMutableArray.mutableCopy];
                _financialCheckoutPage++;
                _queryBlock(YES, @"查询成功");
            } else {
                _queryBlock(NO, @"没有更多消息了");
            }
        }
        
    }];
    [task resume];
    
}

#pragma mark - JHRequestDelegate

- (void)requestDidFail:(JHRequest *)request {

}

- (void)requestDidSuccess:(JHRequest *)request {

//    NSString *string = [[NSString alloc] initWithData:request.response.data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", request.response.url.absoluteString);
    if ([request.response.url.absoluteString isEqualToString:@"http://ipgw.neu.edu.cn:8800/home/base/index"]) {
        if (_loginBlock) {
            _loginBlock(YES, @"登录成功");
        }
    } else {
        if (_loginBlock) {
            _loginBlock(NO, @"登录失败");
        }
    }
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

- (NSMutableArray<GatewaySelfServiceMenuFinancialPayInfoBean *> *)financialPayInfoArray {
    if (!_financialPayInfoArray) {
        _financialPayInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _financialPayInfoArray;
}

- (NSMutableArray<GatewaySelfServiceMenuFinancialCheckOutInfoBean *> *)financialCheckoutInfoArray {
    if (!_financialCheckoutInfoArray) {
        _financialCheckoutInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _financialCheckoutInfoArray;
}

- (NSMutableArray<GatewaySelfServiceMenuInternetRecordsInfoBean *> *)internetRecordInfoArray {
    if (!_internetRecordInfoArray) {
        _internetRecordInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _internetRecordInfoArray;
}


@end

@implementation GatewaySelfServiceMenuOnlineInfoBean
@end

@implementation GatewaySelfServiceMenuBasicInfoBean
@end

@implementation GatewaySelfServiceMenuInternetRecordsInfoBean
@end

@implementation GatewaySelfServiceMenuFinancialPayInfoBean
@end

@implementation GatewaySelfServiceMenuFinancialCheckOutInfoBean
@end
