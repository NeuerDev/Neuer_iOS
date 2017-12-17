//
//  EcardHistoryModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardHistoryModel.h"

@interface EcardHistoryModel () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

// 页面信息
@property (nonatomic, strong) NSString *viewStateStr;
@property (nonatomic, strong) NSString *lastFocusStr;
@property (nonatomic, strong) NSString *eventTargetStr;
@property (nonatomic, strong) NSString *eventArgumentStr;
@property (nonatomic, strong) NSString *eventValidationStr;

@end

@implementation EcardHistoryModel {
    EcardActionCompleteBlock _currentActionBlock;
    EcardQueryConsumeCompleteBlock _queryTodayConsumeCompleteBlock;
}

- (void)queryTodayConsumeHistoryComplete:(EcardQueryConsumeCompleteBlock)block {
    WS(ws);
    [self queryConsumeHistoryFrom:[[NSDate alloc] init]
                               to:[[NSDate alloc] init]
                         complete:^(NSArray *consumeArray, BOOL hasMore, NSError *error) {
        if (consumeArray && !error) {
            ws.todayConsumeArray = consumeArray;
        }
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(consumeArray && !error, hasMore, error);
            });
        }
    }];
}

- (void)queryConsumeStatisicsComplete:(EcardActionCompleteBlock)block {
    
}

#pragma mark - Private Methods

/*
 抓取校园卡消费记录步骤
 1. 访问 http://ecard.neu.edu.cn/SelfSearch/User/ConsumeInfo.aspx 获取网页中的 __VIEWSTATE 和 __EVENTVALIDATION
 2. 利用这两个参数对 http://ecard.neu.edu.cn/SelfSearch/User/ConsumeInfo.aspx 进行 post 请求
 3. 在新网页里继续获取这两个参数 如果有更多 则继续请求
 */

- (void)prepareForConsumeQueryComplete:(EcardActionCompleteBlock)complete {
    WS(ws);
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/User/ConsumeInfo.aspx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    urlRequest.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        
        NSArray<TFHppleElement *> *viewStateArray = [xpathParser searchWithXPathQuery:@"//*[@id='__VIEWSTATE']"];
        ws.viewStateStr = [[viewStateArray firstObject] objectForKey:@"value"] ? : @"";
        NSArray<TFHppleElement *> *eventValidationArray = [xpathParser searchWithXPathQuery:@"//*[@id='__EVENTVALIDATION']"];
        ws.eventValidationStr = [[eventValidationArray firstObject] objectForKey:@"value"] ? : @"";
        if (complete) {
            complete(data && !error, error);
        }
    }];
    
    [task resume];
}

- (void)queryConsumeHistoryFrom:(NSDate *)fromDate
                             to:(NSDate *)toDate
                       complete:(void(^)(NSArray *consumeArray, BOOL hasMore, NSError *error))complete {
    WS(ws);
    NSInteger page = 0;
    
    [self prepareForConsumeQueryComplete:^(BOOL success, NSError *error) {
        if (success) {
            [ws queryConsumeHistoryFrom:fromDate to:toDate page:page complete:^(NSArray *consumeArray, BOOL hasMore, NSError *error) {
                if (complete) {
                    complete(consumeArray, hasMore, error);
                }
            }];
        }
    }];
}

- (void)queryConsumeHistoryFrom:(NSDate *)fromDate
                             to:(NSDate *)toDate
                           page:(NSInteger)page
                       complete:(void(^)(NSArray<EcardConsumeBean *> *consumeArray, BOOL hasMore, NSError *error))complete {
    WS(ws);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *fromDateStr = [formatter stringFromDate:fromDate];
    NSString *toDateStr = [formatter stringFromDate:toDate];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/User/ConsumeInfo.aspx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    urlRequest.HTTPMethod = @"POST";
    NSDictionary *params = @{
                             @"__VIEWSTATE":ws.viewStateStr,
                             @"__EVENTTARGET":@"ctl00$ContentPlaceHolder1$AspNetPager1",
                             @"__EVENTARGUMENT":[NSString stringWithFormat:@"%ld", page+1],
                             @"__EVENTVALIDATION":ws.eventValidationStr,
                             @"ctl00$ContentPlaceHolder1$rbtnType":@"0",
                             @"ctl00$ContentPlaceHolder1$txtStartDate":fromDateStr,
                             @"ctl00$ContentPlaceHolder1$txtEndDate":toDateStr,
                             @"ctl00$ContentPlaceHolder1$rbtnType":@"0",
                             @"ctl00$ContentPlaceHolder1$btnSearch":@"查  询"
                             };
    
    urlRequest.HTTPBody = [params.queryString.URLEncode dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        
        NSArray<TFHppleElement *> *viewStateArray = [xpathParser searchWithXPathQuery:@"//*[@id='__VIEWSTATE']"];
        ws.viewStateStr = [[viewStateArray firstObject] objectForKey:@"value"] ? : @"";
        NSArray<TFHppleElement *> *eventValidationArray = [xpathParser searchWithXPathQuery:@"//*[@id='__EVENTVALIDATION']"];
        ws.eventValidationStr = [[eventValidationArray firstObject] objectForKey:@"value"] ? : @"";
        
        NSArray<TFHppleElement *> *consumeRowArray = [[xpathParser searchWithXPathQuery:@"//*[@id='ContentPlaceHolder1_gridView']"].firstObject childrenWithTagName:@"tr"];
        NSMutableArray<EcardConsumeBean *> *consumeBeanArray = @[].mutableCopy;
        for (TFHppleElement *row in consumeRowArray) {
            if (row.attributes[@"class"]
                && ![row.attributes[@"class"] isEqualToString:@"HeaderStyle"]
                && row.children.count==9) {
                
                NSArray<TFHppleElement *> *childArray = row.children;
                NSString *time;
                if (childArray[1].children
                    && childArray[1].children.count==3
                    && [childArray[1].children[1] isKindOfClass:[TFHppleElement class]]) {
                    time = ((TFHppleElement *)childArray[1].children[1]).text;
                }
                if (!time) {
                    continue;
                }
                NSString *subject = childArray[2].text;
                NSString *money = childArray[3].text;
                NSString *station = childArray[6].text;
                NSString *device = childArray[7].text;
                EcardConsumeBean *consumeBean = [[EcardConsumeBean alloc] initWithTime:time station:station device:device money:money subject:subject];
                [consumeBeanArray addObject:consumeBean];
            }
        }
        
        if (complete) {
            complete(consumeBeanArray.copy, NO, error);
        }
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

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    // 如果重定向到login的话说明登录失效 需要重新登录
    if ([request.URL.absoluteString isEqualToString:@"http://ecard.neu.edu.cn/SelfSearch/login.aspx"]) {
        if (_currentActionBlock) {
            NSError *error = [NSError errorWithDomain:JHErrorDomain code:JHErrorTypeRequireLogin userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                _currentActionBlock(NO, error);
            });
        }
        return;
    }
    __strong EcardActionCompleteBlock block = _currentActionBlock;
    NSURLSessionDataTask *newTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(data && !error, error);
            });
        }
    }];
    [newTask resume];
}

@end


@interface EcardConsumeBean ()
@property (nonatomic, assign) NSDate *date;             // 时间
@property (nonatomic, strong) NSString *station;        // 工作站
@property (nonatomic, strong) NSString *device;         // 机器编号
@property (nonatomic, strong) NSString *money;          // 消费
@property (nonatomic, strong) NSString *subject;        // 科目描述 （淋浴支出 餐费支出）
@property (nonatomic, strong) NSString *detail;         // 推断的消费项目
@property (nonatomic, strong) NSString *window;         // 推断的消费位置
@end

@implementation EcardConsumeBean

- (instancetype)initWithTime:(NSString *)time station:(NSString *)station device:(NSString *)device money:(NSString *)money subject:(NSString *)subject {
    if (self = [super init]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy/M/d H:mm:ss"; // 2017/10/14 8:16:50
        _date = [formatter dateFromString:time];
        _station = station;
        _device = device;
        _money = money;
        _subject = subject;
    }
    
    return self;
}

#pragma mark - Getter

- (NSString *)time {
    return [JHTool fancyStringFromDate:_date];
}

- (NSNumber *)cost {
    if (!_cost) {
        _cost = [NSNumber numberWithFloat:-_money.floatValue];
    }
    
    return _cost;
}

- (EcardConsumeType)consumeType {
    return [@{
              @"淋浴支出":@(EcardConsumeTypeBath),
              @"餐费支出":@(EcardConsumeTypeFood),
              }[_subject] integerValue];
}

- (NSString *)title {
    if (!_title) {
        if (self.detail.length > 0) {
            _title = [NSString stringWithFormat:@"%@", self.detail];
        } else {
            _title = self.device;
        }
    }
    
    return _title;
}

- (NSString *)desc {
    if (!_desc) {
        _desc = [NSString stringWithFormat:@"%@ %@", self.time, self.window];
    }
    
    return _desc;
}

- (NSString *)detail {
    if (!_detail) {
        if ([_subject isEqualToString:@"购热水支出"]) {
            _detail = @"水卡钱包充值";
        } else if ([_subject isEqualToString:@"淋浴支出"]) {
            _detail = @"洗澡";
        } else if ([_device containsString:@"超市"]) {
            _detail = @"购物";
        } else if ([_device containsString:@"水果"]) {
            _detail = @"买水果";
        } else {
            _detail = @"";
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"H";
            NSInteger hour = [formatter stringFromDate:_date].integerValue;
            if (hour>5 && hour<10) {
                // 早餐
                _detail = @{
                            @"浑南一楼1#":@"豆浆",
                            @"浑南一楼2#":@"豆浆",
                            @"浑南一楼5#":@"面包糕点",
                            @"浑南一楼17#":@"油条",
                            @"浑南一楼38#":@"早餐馄饨",
                            @"浑南三楼123#":@"饮料粥品",
                            }[_device] ? : _device;
            } else if (hour>=10 && hour<15) {
                // 午餐
                _detail = @{
                            @"浑南一楼1#":@"豆浆",
                            @"浑南一楼2#":@"豆浆",
                            @"浑南一楼5#":@"面食",
                            @"浑南一楼7#":@"拉面、干拌面",
                            @"浑南一楼24#":@"自选菜品",
                            @"浑南一楼26#":@"煎蛋饭",
                            @"浑南一楼27#":@"米饭",
                            @"浑南一楼38#":@"蒸笼",
                            @"浑南一楼40#":@"水饺",
                            @"浑南二楼74#":@"锅贴炖汤",
                            @"浑南二楼91#":@"米饭",
                            @"浑南二楼103#":@"煎蛋饭",
                            @"浑南三楼123#":@"饮料粥品",
                            }[_device] ? : _device;
            } else if (hour>=15 && hour<23) {
                // 晚餐
                _detail = @{
                            @"浑南一楼1#":@"豆浆",
                            @"浑南一楼2#":@"豆浆",
                            @"浑南一楼5#":@"面食",
                            @"浑南一楼7#":@"拉面、干拌面",
                            @"浑南一楼24#":@"自选菜品",
                            @"浑南一楼26#":@"煎蛋饭",
                            @"浑南一楼27#":@"米饭",
                            @"浑南一楼38#":@"蒸笼",
                            @"浑南一楼40#":@"水饺",
                            @"浑南二楼74#":@"锅贴炖汤",
                            @"浑南二楼91#":@"米饭",
                            @"浑南二楼103#":@"煎蛋饭",
                            @"浑南三楼123#":@"饮料粥品",
                            }[_device] ? : _device;
            }
        }
    }
    
    return _detail;
}

- (NSString *)window {
    if (!_window) {
        _window = @"";
        
        if ([_subject isEqualToString:@"购热水支出"]) {
            _window = @"圈存机";
        } else if ([_subject isEqualToString:@"淋浴支出"]) {
            _window = @"学生澡堂";
        } else if ([_subject isEqualToString:@"餐费支出"]) {
            
            NSDictionary *specificWindowRegexMap = @{
                                                     @"教工餐厅50号机":@"学府餐厅",
                                                     @"一楼超市":@"一楼超市",
                                                     @"二楼超市":@"二楼超市",
                                                     @"水果":@"水果店",
                                                     };
            
            for (NSString *regex in specificWindowRegexMap) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
                
                if ([predicate evaluateWithObject:_device]) {
                    _window = specificWindowRegexMap[regex];
                } else {
                    continue;
                }
            }
            
            if (_window.length==0) {
                _window = @{
                            @"浑南一楼1#":@"原磨豆浆窗口",
                            @"浑南一楼2#":@"原磨豆浆窗口",
                            @"浑南一楼5#":@"早餐西点窗口",
                            @"浑南一楼7#":@"一楼兰州拉面窗口",
                            @"浑南一楼17#":@"一楼早餐油条窗口",
                            @"浑南一楼24#":@"一楼自选菜品窗口",
                            @"浑南一楼26#":@"一楼煎蛋饭窗口",
                            @"浑南一楼27#":@"一楼米饭窗口",
                            @"浑南一楼38#":@"一楼蒸笼窗口",
                            @"浑南一楼40#":@"一楼水饺窗口",
                            @"浑南二楼74#":@"二楼锅贴炖汤窗口",
                            @"浑南二楼91#":@"二楼米饭窗口",
                            @"浑南二楼103#":@"二楼煎蛋饭窗口",
                            @"浑南三楼123#":@"三楼粥品窗口",
                            }[_device] ? : _device;
                
            }
        }
    }
    
    return _window;
}

@end
