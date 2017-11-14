//
//  GatewaySelfServiceMenuModel.m
//  NEUer
//
//  Created by lanya on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewaySelfServiceMenuModel.h"
#import "LYTool.h"

@interface GatewaySelfServiceMenuModel () <NSURLSessionDelegate>

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
    GatewaySelfServiceMenuQueryBlock _queryBasicInfoBlock;
    GatewaySelfServiceMenuLoginBlock _queryOnlineInfoBlock;
    GatewaySelfServiceMenuLoginBlock _queryInternetListBlock;
    GatewaySelfServiceMenuLoginBlock _queryBlock;
    
    GatewaySelfServiceMenuQueryBlock _refreshBlock;
    GatewaySelfServiceMenuQueryBlock _refreshPayBlock;
    
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
    
    _financialPayInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    _financialCheckoutInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    _internetRecordInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    _onlineInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    _todayInternetRecordInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    _appendingFinanceCheckoutInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    _appendingFinancePayInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
    _appendingInternetRecordInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
}


#pragma mark - Public Method

- (void)refreshData {
    _logDetailPage = 1;
    
    if (_onlineInfoArray.count > 0) {
        [_onlineInfoArray removeAllObjects];
    }
    
    if (self.todayInternetRecordInfoArray.count > 0) {
        [self.todayInternetRecordInfoArray removeAllObjects];
    }
    
    [self queryUserBasicInformationListComplete:^(BOOL success, NSString *data) {}];
    [self queryUserOnlineInformationListComplete:^(BOOL success, NSString *data) {}];
    [self queryUserOnlineLogDetailListComplete:^(BOOL success, NSString *data) {}];
}

- (void)refreshInternetRecordsDataComplete:(GatewaySelfServiceMenuQueryBlock)block {
    
    _refreshBlock = block;
    
    _logDetailPage = 1;
    
    while (_internetRecordInfoArray.count > 10) {
        [_internetRecordInfoArray removeLastObject];
    }
    
    [self queryUserOnlineLogDetailListComplete:^(BOOL success, NSString *data) {
        
        if (success) {
            _refreshBlock(YES, @"成功");
        } else {
            _refreshBlock(NO, @"失败");
        }
    }];
}

- (void)refreshCheckoutDataComplete:(GatewaySelfServiceMenuQueryBlock)block {
    _financialCheckoutPage = 1;
    _refreshBlock = block;
    
    while (_financialCheckoutInfoArray.count >= 10) {
        [_financialCheckoutInfoArray removeAllObjects];
    }
    
    [self queryUserFinancialCheckOutListComlete:^(BOOL success, NSString *data) {
        if (success) {
            _refreshBlock(YES, @"刷新成功");
        } else {
            _refreshBlock(NO, @"刷新失败");
        }
    }];
}

- (void)refreshPayInfoDataComplete:(GatewaySelfServiceMenuQueryBlock)block {
    
    _refreshPayBlock = block;
    
    _financialPayPage = 1;
    
    while (_financialPayInfoArray.count >= 10) {
        [_financialPayInfoArray removeAllObjects];
    }
    
    [self queryUserOnlineFinancialPayListComplete:^(BOOL success, NSString *data) {
        if (success) {
            _refreshPayBlock(YES, @"成功");
        } else {
            _refreshPayBlock(NO, @"失败");
        }
    }];
}

//获取验证码
- (void)getVerifyImage:(GatewaySelfServiceMenuGetVerifyImageBlock)block {
    
    NSArray<NSHTTPCookie *> *cookies = self.session.configuration.HTTPCookieStorage.cookies;
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.domain isEqualToString:@"ipgw.neu.edu.cn"]) {
            [self.session.configuration.HTTPCookieStorage deleteCookie:cookie];
        }
    }

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

//登录
- (void)loginGatewaySelfServiceMenuWithUser:(NSString *)account password:(NSString *)password verifyCode:(NSString *)verifyCode loginState:(GatewaySelfServiceMenuLoginBlock)block{

    _loginBlock = block;

    
    NSDictionary *param = @{
                            @"_csrf" : self.csrfStr,
                            @"LoginForm[username]" : account,
                            @"LoginForm[password]" : password,
                            @"LoginForm[verifyCode]" : verifyCode,
                            @"login-button" : @""
                            };
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/site/index"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [param.queryString.URLEncode dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@", response.URL.absoluteString);
        if ([response.URL.absoluteString isEqualToString:@"http://ipgw.neu.edu.cn:8800/home/base/index"]) {
            if (_loginBlock) {
                
                _loginBlock(YES, @"登录成功");
            }
        } else {
            if (_loginBlock) {
                _loginBlock(NO, @"登录失败");
            }
        }
    }];
    
    [task resume];
    
}

//首页用户基本信息
- (void)queryUserBasicInformationListComplete:(GatewaySelfServiceMenuQueryBlock)block {
    
    _queryBasicInfoBlock = block;
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/home/base/index"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        _basicInfo = [[GatewaySelfServiceMenuBasicInfoBean alloc] init];
        
//        更新csrf
        NSArray *crsfArray = [hpple searchWithXPathQuery:@"/html/head/meta[7]"];
        for (TFHppleElement *element in crsfArray) {
            if ([element objectForKey:@"content"]) {
                _csrfStr = [element objectForKey:@"content"];
            }
        }
        
        TFHppleElement *element = (TFHppleElement *)[[hpple searchWithXPathQuery:@"//*[@class='font-red']"] lastObject];
        if (element) {
            _basicInfo.user_state = element.text;
        } else {
            element = (TFHppleElement *)[[hpple searchWithXPathQuery:@"//*[@class='font-green']"] lastObject];
            _basicInfo.user_state = element.text;
        }
        
        NSArray *dataArray = [hpple searchWithXPathQuery:@"//li[@class='list-group-item']"];
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

            if ([_basicInfo.product_usedFlow containsString:@"M"]) {
                if ([_basicInfo.product_name isEqualToString:@"std"]) {
                    _basicInfo.product_restFlow = [NSString stringWithFormat:@"%.2f", 25 - _basicInfo.product_usedFlow.floatValue / 1000];
                } else {
                    _basicInfo.product_restFlow = [NSString stringWithFormat:@"%.2f", 35 - _basicInfo.product_usedFlow.floatValue / 1000];
                }
            } else if ([_basicInfo.product_usedFlow containsString:@"byte"]) {
                if ([_basicInfo.product_name isEqualToString:@"std"]) {
                    _basicInfo.product_restFlow = [NSString stringWithFormat:@"%.2f", 25 - _basicInfo.product_usedFlow.floatValue / 1000000000];
                } else {
                    _basicInfo.product_restFlow = [NSString stringWithFormat:@"%.2f", 35 - _basicInfo.product_usedFlow.floatValue / 1000000000];
                }
            } else if ([_basicInfo.product_usedFlow containsString:@"K"]) {
                if ([_basicInfo.product_name isEqualToString:@"std"]) {
                    _basicInfo.product_restFlow = [NSString stringWithFormat:@"%.2f", 25 - _basicInfo.product_usedFlow.floatValue / 1000000];
                } else {
                    _basicInfo.product_restFlow = [NSString stringWithFormat:@"%.2f", 35 - _basicInfo.product_usedFlow.floatValue / 1000000];
                }
            } else {
                if ([_basicInfo.product_name isEqualToString:@"std"]) {
                    _basicInfo.product_restFlow = [NSString stringWithFormat:@"%.2f", 25 - _basicInfo.product_usedFlow.floatValue];
                } else {
                    _basicInfo.product_restFlow = [NSString stringWithFormat:@"%.2f", 35 - _basicInfo.product_usedFlow.floatValue];
                }
            }
            
            _queryBasicInfoBlock(YES, @"成功！");
        } else {
            _queryBasicInfoBlock(NO, @"失败");
        }
        
    }];
    
    [dataTask resume];
}

//获取首页正在联网信息
- (void)queryUserOnlineInformationListComplete:(GatewaySelfServiceMenuQueryBlock)block {
    
    _queryOnlineInfoBlock = block;
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/home/base/index"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        
        TFHppleElement *tempInfoElement = [[hpple searchWithXPathQuery:@"//table[@class='table table-bordered']"] firstObject];

        NSArray<TFHppleElement *> *onlineInfoTempArray = [tempInfoElement childrenWithTagName:@"tr"];
        for (int i = 1; i < onlineInfoTempArray.count; ++i) {
            GatewaySelfServiceMenuOnlineInfoBean *infoBean = [[GatewaySelfServiceMenuOnlineInfoBean alloc] init];
            NSArray *tempDataArray = [onlineInfoTempArray[i] childrenWithTagName:@"td"];
            if (tempDataArray.count >= 6) {
                infoBean.online_number = ((TFHppleElement *)tempDataArray[0]).text;
                infoBean.online_ipAddress = ((TFHppleElement *)tempDataArray[1]).text;
                infoBean.online_productName = ((TFHppleElement *)tempDataArray[2]).text;
                infoBean.online_lastactive = ((TFHppleElement *)tempDataArray[3]).text;
                infoBean.online_operation = ((TFHppleElement *)tempDataArray[4]).text;
                infoBean.online_AccountingStrategy = ((TFHppleElement *)tempDataArray[5]).text;
                TFHppleElement *tempElement = tempDataArray[6];
                TFHppleElement *idElement = [tempElement firstChild];
                infoBean.online_ID = [idElement objectForKey:@"id"];
    
                [self.onlineInfoArray addObject:infoBean];
            }
        }
        
        if (self.onlineInfoArray.count == onlineInfoTempArray.count - 1) {
            if (self.onlineInfoArray.count == 0) {
                _queryOnlineInfoBlock(NO, @"无在线设备");
            } else {
                _queryOnlineInfoBlock(YES, @"查询成功");
            }
        } else {
            _queryOnlineInfoBlock(NO, @"查询失败");
        }
    }];
    
    [dataTask resume];
    
}

- (void)getTheModifyCsrf {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/user/chgpwd/index"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];

    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *crsfArray = [hpple searchWithXPathQuery:@"/html/head/meta[7]"];
        for (TFHppleElement *element in crsfArray) {
            if ([element objectForKey:@"content"]) {
                _csrfStr = [element objectForKey:@"content"];
            }
        }
    }];
    [task resume];
}

//修改密码
- (void)modifyPasswordForIPGWwithOldPassword:(NSString *)oldpassword newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword Complete:(GatewaySelfServiceMenuQueryBlock)block {
    _queryBlock = block;
    
    [self getTheModifyCsrf];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/user/chgpwd/index"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];

    request.HTTPMethod = @"POST";
    NSDictionary *params = @{
                             @"_csrf" : self.csrfStr,
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
    
    [self updateCsrfValue];
}

//上网明细
- (void)queryUserOnlineLogDetailListComplete:(GatewaySelfServiceMenuQueryBlock)block {
    _queryInternetListBlock = block;
    
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
        
//        每次查询都需要先把之前追加的上网明细清除
        [_appendingInternetRecordInfoArray removeAllObjects];
        if (_todayInternetRecordInfoArray.count > 0 && _logDetailPage == 1) {
            [_todayInternetRecordInfoArray removeAllObjects];
        }
        
//        获取今日上网明细
        BOOL flag = YES;
        
        for (GatewaySelfServiceMenuInternetRecordsInfoBean *bean in internetMutableArray) {
            NSString *logoutDate = [LYTool changeDateFormatterFromDateFormat:@"MM-dd HH:mm:ss" toDateFormat:@"MM-dd" withDateString:bean.internet_logoutTime];
            
            if (!logoutDate) {
                if (_todayInternetRecordInfoArray.count > 0) {
                    for (GatewaySelfServiceMenuInternetRecordsInfoBean *todayBean in _todayInternetRecordInfoArray) {
                        if ([todayBean.internet_logoutTime isEqualToString:bean.internet_logoutTime]) {
                            flag = NO;
                        }
                    }
                    
                    if (flag) {
                        [_todayInternetRecordInfoArray addObject:bean];
                    }
                } else {
                    [_todayInternetRecordInfoArray addObject:bean];
                }
            }
            
        }
        
        if (self.internetRecordInfoArray.count != 0 && _logDetailPage == 1) {
            [self.internetRecordInfoArray removeAllObjects];
        }
        
        if (self.internetRecordInfoArray.count == 0) {
            [self.internetRecordInfoArray addObjectsFromArray:internetMutableArray.mutableCopy];
            _logDetailPage++;
            _queryInternetListBlock(YES, @"查询成功");
            return;
        } else {
            if (![[self.internetRecordInfoArray lastObject].internet_lastactive isEqualToString:[internetMutableArray lastObject].internet_lastactive]) {
                [self.internetRecordInfoArray addObjectsFromArray:internetMutableArray.mutableCopy];
                [self.appendingInternetRecordInfoArray addObjectsFromArray:internetMutableArray.mutableCopy];
                _logDetailPage++;
                _queryInternetListBlock(YES, @"查询成功");
            } else {
                _queryInternetListBlock(NO, @"没有更多消息了");
            }
        }
    }];
    [task resume];
}

//缴费信息
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
        
        [self.appendingFinancePayInfoArray removeAllObjects];
        
        if (self.financialPayInfoArray.count != 0 && _financialPayPage == 1) {
            [self.financialPayInfoArray removeAllObjects];
        }
        
        if (self.financialPayInfoArray.count == 0) {
            [self.financialPayInfoArray addObjectsFromArray:financialMutableArray.mutableCopy];
            _financialPayPage++;
            _queryBlock(YES, @"查询成功");
            return;
        } else {
            if (![[self.financialPayInfoArray lastObject].financial_creatTime isEqualToString:[financialMutableArray lastObject].financial_creatTime]) {
                [self.appendingFinancePayInfoArray addObjectsFromArray:financialMutableArray.mutableCopy];
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

//结算信息
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
        
        [_appendingFinanceCheckoutInfoArray removeAllObjects];
        
        if (self.financialCheckoutInfoArray.count > 0 && _financialCheckoutPage == 1) {
            [self.financialCheckoutInfoArray removeAllObjects];
        }
        
        if (self.financialCheckoutInfoArray.count == 0) {
            [self.financialCheckoutInfoArray addObjectsFromArray:financialMutableArray.mutableCopy];
            _financialCheckoutPage++;
            _queryBlock(YES, @"查询成功");
            return;
        } else {
            if (![[self.financialCheckoutInfoArray lastObject].checkout_creatTime isEqualToString:[financialMutableArray lastObject].checkout_creatTime]) {
                [self.appendingFinanceCheckoutInfoArray addObjectsFromArray:financialMutableArray.mutableCopy];
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

//强制下线
- (void)offLineTheIPGWWithDevicesID:(NSInteger)deviceID complete:(GatewaySelfServiceMenuQueryBlock)block {
    
    _loginBlock = block;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/home/base/drop"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    request.HTTPMethod = @"POST";
    NSDictionary *params = @{
                             @"id" : [NSString stringWithFormat:@"%ld", deviceID]
                             };
    
    request.HTTPBody = [params.queryString.URLEncode dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setValue:self.csrfStr forHTTPHeaderField:@"X-CSRF-Token"];
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"utf8" forHTTPHeaderField:@"charset"];
    [request setValue:@"http://ipgw.neu.edu.cn:8800/home/base/index" forHTTPHeaderField:@"Referer"];
    [request setValue:@"http://ipgw.neu.edu.cn:8800" forHTTPHeaderField:@"Origin"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if ([dic[@"code"] isEqualToString:@"1"]) {
            _loginBlock(YES, @"成功");
        } else {
            _loginBlock(NO, @"失败");
        }
        
    }];

    [task resume];

    [self updateCsrfValue];
}

- (void)pauseAccountComplete:(GatewaySelfServiceMenuQueryBlock)block {
    _queryBlock = block;
    
    [self updateCsrfValue];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/home/base/pause"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        request.HTTPMethod = @"POST";
        NSDictionary *param = @{
                                @"_csrf" : self.csrfStr
                                };
        request.HTTPBody = [param.queryString.URLEncode dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
            NSString *csrfStr = nil;
            //        更新csrf
            NSArray *crsfArray = [hpple searchWithXPathQuery:@"/html/head/meta[7]"];
            for (TFHppleElement *element in crsfArray) {
                if ([element objectForKey:@"content"]) {
                    csrfStr = [element objectForKey:@"content"];
                }
            }
            
            NSString *state = ((TFHppleElement *)[[hpple searchWithXPathQuery:@"//*[@class='font-red']"] lastObject]).text;
            
            if ([state isEqualToString:@"暂停"]) {
                self.csrfStr = csrfStr;
                _queryBlock(YES, @"修改状态成功");
            } else {
                _queryBlock(NO, @"修改状态失败");
            }
        }];
        [task resume];
    });
    
}

- (void)openAccountComplete:(GatewaySelfServiceMenuQueryBlock)block {
    _queryBlock = block;
    
    [self updateCsrfValue];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/home/base/open"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        request.HTTPMethod = @"POST";
        NSDictionary *param = @{
                                @"_csrf" : self.csrfStr
                                };
        request.HTTPBody = [param.queryString.URLEncode dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
            NSString *csrfStr = nil;
            //        更新csrf
            NSArray *crsfArray = [hpple searchWithXPathQuery:@"/html/head/meta[7]"];
            for (TFHppleElement *element in crsfArray) {
                if ([element objectForKey:@"content"]) {
                    csrfStr = [element objectForKey:@"content"];
                }
            }
            
            NSString *state = ((TFHppleElement *)[[hpple searchWithXPathQuery:@"//*[@class='font-green']"] lastObject]).text;
            if ([state isEqualToString:@"正常"]) {
                self.csrfStr = csrfStr;
                _queryBlock(YES, @"修改状态成功");
            } else {
                _queryBlock(NO, @"修改状态失败");
            }
        }];
        [task resume];
    });
    
}

- (void)updateCsrfValue {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ipgw.neu.edu.cn:8800/home/base/index"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        //        更新csrf
        NSArray *crsfArray = [hpple searchWithXPathQuery:@"/html/head/meta[7]"];
        for (TFHppleElement *element in crsfArray) {
            if ([element objectForKey:@"content"]) {
                _csrfStr = [element objectForKey:@"content"];
            }
        }
    }];
    
    [dataTask resume];
}

#pragma mark - Getter
- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{
                                                @"User-Agent":@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/604.3.5 (KHTML, like Gecko) Version/11.0.1 Safari/604.3.5",
//                                                @"User-Agent":@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36"
                                                };
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _session;
}

@end

@implementation GatewaySelfServiceMenuOnlineInfoBean
@end

@implementation GatewaySelfServiceMenuBasicInfoBean


- (NSDictionary<NSNumber *,NSString *> *)restFlowLevelDictionary {
    
    if (_product_restFlow) {
        float restValue = _product_restFlow.floatValue;
        
        if (restValue >= 10) {
            _restFlowLevelDictionary = @{
                                         @(GatewaySelfServiceMenuRestFlowLevelEnough) : @"剩余流量充足"
                                         };
        } else if (restValue < 10 && restValue > 0) {
            _restFlowLevelDictionary = @{
                                         @(GatewaySelfServiceMenuRestFlowLevelNotEnough) : @"剩余流量不足"
                                         };
        } else {
            _restFlowLevelDictionary = @{
                                         @(GatewaySelfServiceMenuRestFlowLevelNotEnough) : @"使用流量已超额"
                                         };
        }
    } else {
        _restFlowLevelDictionary = @{
                                     @(GatewayStatusUnknown) : @"未知"
                                     };
    }
    
    return _restFlowLevelDictionary;
}

- (void)setUser_state:(NSString *)user_state {
    if ([user_state isEqualToString:@"暂停"]) {
        _user_state = @"开启";
    } else {
        _user_state = @"暂停";
    }
}

- (NSArray<GatewayCellBasicInfoBean *> *)userInfoBeanArray {
    if (!_userInfoBeanArray) {
        NSMutableArray *infoBeanMutableArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        GatewayCellBasicInfoBean *bean = [[GatewayCellBasicInfoBean alloc] init];
        if (self) {
            bean = [[GatewayCellBasicInfoBean alloc] init];
            bean.messageName = @"学号";
            bean.message = self.user_number;
            bean.messageType = 0;
            [infoBeanMutableArray addObject:bean];
            
            bean = [[GatewayCellBasicInfoBean alloc] init];
            bean.messageName = @"姓名";
            bean.message = self.user_name;
            bean.messageType = 0;
            [infoBeanMutableArray addObject:bean];
            
            bean = [[GatewayCellBasicInfoBean alloc] init];
            bean.messageName = @"状态";
            if ([self.user_state isEqualToString:@"暂停"]) {
                bean.message = @"正常";
            } else {
                bean.message = @"暂停";
            }
            bean.messageType = 0;
            [infoBeanMutableArray addObject:bean];
            
            bean = [[GatewayCellBasicInfoBean alloc] init];
            bean.messageName = @"已用流量";
            bean.message = self.product_usedFlow;
            bean.messageType = 1;
            [infoBeanMutableArray addObject:bean];
            
            bean = [[GatewayCellBasicInfoBean alloc] init];
            bean.messageName = @"已用时长";
            bean.message = self.product_usedDuration;
            bean.messageType = 1;
            [infoBeanMutableArray addObject:bean];
            
            bean = [[GatewayCellBasicInfoBean alloc] init];
            bean.messageName = @"产品余额";
            bean.message = self.product_balance;
            bean.messageType = 1;
            [infoBeanMutableArray addObject:bean];

        }
        _userInfoBeanArray = infoBeanMutableArray;
    }
    return _userInfoBeanArray;
}

@end

@implementation GatewaySelfServiceMenuInternetRecordsInfoBean

- (void)setInternet_lastactive:(NSString *)internet_lastactive {
    NSString *today = [LYTool dateOfTodayWithFormat:@"yyyy-MM-dd"];
    NSString *newDate = [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"yyyy-MM-dd" withDateString:internet_lastactive];
    if ([today isEqualToString:newDate]) {
        _internet_lastactive = [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"HH:mm:ss" withDateString:internet_lastactive];
    } else {
        _internet_lastactive = [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"MM-dd HH:mm:ss" withDateString:internet_lastactive];
    }
}

- (void)setInternet_logoutTime:(NSString *)internet_logoutTime {
    NSString *today = [LYTool dateOfTodayWithFormat:@"yyyy-MM-dd"];
    NSString *newDate = [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"yyyy-MM-dd" withDateString:internet_logoutTime];
    if ([today isEqualToString:newDate]) {
        _internet_logoutTime = [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"HH:mm:ss" withDateString:internet_logoutTime];
    } else {
        _internet_logoutTime = [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"MM-dd HH:mm:ss" withDateString:internet_logoutTime];
    }
}

@end

@implementation GatewaySelfServiceMenuFinancialPayInfoBean
@end

@implementation GatewaySelfServiceMenuFinancialCheckOutInfoBean
@end

@implementation GatewayCellBasicInfoBean
@end
