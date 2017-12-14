//
//  LibraryLoginModel.m
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryLoginModel.h"

@interface LibraryLoginModel () <JHRequestDelegate>
@property (nonatomic, assign) NSInteger infoType;
@end

@implementation LibraryLoginModel
#pragma mark - Public Methods
- (void)gotoLogin {
    _infoType = 0;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/F?func=file&file_name=login-session"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
    
}

- (void)login {
    _infoType = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",_tmpURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url method:@"POST" params:@{@"func":@"login-session".URLEncode,@"login_source":@"bor-info".URLEncode,@"bor_id":_username.URLEncode,@"bor_verification":_password.URLEncode,@"bor_library":@"NEU50".URLEncode}];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)expiredLogin {
    _infoType = 2;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",_expiredURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url method:@"POST" params:@{@"func":@"patron-notice".URLEncode,@"nxtpg_patron_notice":@"N".URLEncode,@"nxtpg_source":@"www_f_login_session".URLEncode,@"nxtpg_bor_id":_ID.URLEncode,@"nxtpg_prog":@"www_f_bor_info".URLEncode,@"nxtpg_file":@"".URLEncode,@"nxtpg_login_source":@"BOR-INFO".URLEncode,@"nxtpg_code_value":@"Y".URLEncode,@"nxtpg_tr_value":@"N".URLEncode,@"nxtpg_heading_no":@"".URLEncode,@"func=login.x":@"50".URLEncode,@"func=login.y":@"8".URLEncode}];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)searchBorrowingInfo {
    _borrowingArr = [NSMutableArray array];
    _infoType = 3;
    
    NSURL *url = [NSURL URLWithString:_borrowingURL];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
    
}

- (void)searchBorrowHistoryInfo {
    _borrowHistoryArr = [NSMutableArray array];
    _infoType = 4;
    
    NSURL *url = [NSURL URLWithString:_borrowHistoryURL];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)searchReservationInfo {
    _reservationArr = [NSMutableArray array];
    _infoType = 5;
    
    NSURL *url = [NSURL URLWithString:_reservationURL];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)searchBookedInfo {
    _bookedArr = [NSMutableArray array];
    _infoType = 6;
    
    NSURL *url = [NSURL URLWithString:_bookedURL];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)searchCashInfo {
    _cashArr = [NSMutableArray array];
    _infoType = 7;
    
    NSURL *url = [NSURL URLWithString:_cashURL];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)partRenewalWithBean:(LibraryLoginMyInfoBorrowingBean *)bean {
    _infoType = 8;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?func=bor-renew-all&renew_selected=Y&adm_library=NEU50&%@=Y",bean.tempURL,bean.renewNumber];
    NSURL *url = [NSURL URLWithString:urlStr];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)allRenewal {
    _infoType = 9;
    
    NSURL *url = [NSURL URLWithString:_renewURL];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}



#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    NSData *htmlData = request.response.data;
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    switch (_infoType) {
        case 0: {
            
            // 获取 var tmp 暂存索引 服务器生成的 必须保存
            NSArray<TFHppleElement *> *formArray = [xpathParser searchWithXPathQuery:@"//form[@name='form1']"];
            _tmpURL = [formArray[0] objectForKey:@"action"];
            [self login];
        }
            break;
            
        case 1: {
            NSArray<TFHppleElement *> *textArray = [xpathParser searchWithXPathQuery:@"//p[@class='text1']"];
            if (textArray.count) {
                _expiredURL = [[xpathParser searchWithXPathQuery:@"//form[@name='form1']"][0] objectForKey:@"action"];
                _ID = [[xpathParser searchWithXPathQuery:@"//input[@name='nxtpg_bor_id']"][0] objectForKey:@"value"];
                [self expiredLogin];
            } else {
                [self resultFromHtmlData:htmlData];
            }
        }
            break;
            
        case 2: {
            [self resultFromHtmlData:htmlData];
        }
            break;
            
    
            
        case 3: {
            [self borrowingArrayFromHtmlData:htmlData];
            //计算最小还书天数
            NSInteger min = NSIntegerMax;
            if (_borrowingArr.count == 0) {
                _loginBean.returnDateLevel = LibraryInfoReturnDateLevelLow;
                _loginBean.days = min;
            } else {
                for (NSInteger i = 0; i < _borrowingArr.count; i++) {
                    if ([_borrowingArr[i].days intValue] < min) {
                        min = [_borrowingArr[i].days integerValue];
                    }
                }
                _loginBean.days = min;
                if (min > 15) {
                    _loginBean.returnDateLevel = LibraryInfoReturnDateLevelLow;
                } else if (min <= 15 && min >5) {
                    _loginBean.returnDateLevel = LibraryInfoReturnDateLevelMiddle;
                } else {
                    _loginBean.returnDateLevel = LibraryInfoReturnDateLevelHigh;
                }
            }
            if ([_delegate respondsToSelector:@selector(loginDidSuccess)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate loginDidSuccess];
                });
            }
        }
            break;
            
        case 4: {
            _borrowHistoryArr = [self borrowHistoryArrayFromHtmlData:htmlData];
            if ([_delegate respondsToSelector:@selector(getBorrowHistoryInfoDidSuccess)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate getBorrowHistoryInfoDidSuccess];
                });
            }
            
        }
            break;
            
        case 8: {
            [self partRenewInfoFromHtmlData:htmlData];
        }
            break;
            
        case 9: {
            [self allRenewInfoFromHtmlData:htmlData];
        }
            
        default:
            break;
    }
}

- (void)requestDidFail:(JHRequest *)request {
    
}

#pragma mark - Private Methods
- (void)resultFromHtmlData:(NSData *)htmlData {
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray<TFHppleElement *> *titleArr = [xpathParser searchWithXPathQuery:@"//div[@class='title']"];
    if (titleArr.count) {
        //密码错误
        if ([_delegate respondsToSelector:@selector(loginDidFail)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate loginDidFail];
            });
        }
        
    } else {
        //密码正确
        
        //我的基本信息
        NSArray<TFHppleElement *> *td2Array = [xpathParser searchWithXPathQuery:@"//td[@class='td2']"];
        _loginBean = [[LibraryLoginBean alloc] init];
        _loginBean.nameStr = [td2Array[1] text];
        _loginBean.collegeStr = [td2Array[3] text];
        _loginBean.languageStr = [td2Array[5] text];
        _loginBean.gradeStr = [td2Array[7] text];
        _loginBean.addressBeginStr = [td2Array[13] text];
        _loginBean.addressEndStr = [td2Array[15] text];
        _loginBean.statusStr = [td2Array[27] text];
        _loginBean.barCodeStr = [td2Array[31] text];
        _loginBean.registrationStr = [td2Array[33] text];

        //我的流通
        NSArray<TFHppleElement *> *aArray = [xpathParser searchWithXPathQuery:@"//td/a"];
        _loginBean.borrowingStr = [aArray[0] text];
        _loginBean.borrowHistoryStr = [aArray[1] text];
        _loginBean.reservationStr = [aArray[2] text];
        _loginBean.bookedStr = [aArray[3] text];
        _loginBean.cashStr = [aArray[4] text];
        NSArray<TFHppleElement *> *td1Array = [xpathParser searchWithXPathQuery:@"//td[@class='td1']"];
        _loginBean.arrearsStr = [td1Array.lastObject text];
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < aArray.count; i++) {
            NSString *urlStr = [aArray[i] objectForKey:@"href"];
            NSRange start = [urlStr rangeOfString:@"("];
            NSRange end = [urlStr rangeOfString:@")"];
            urlStr = [urlStr substringWithRange:NSMakeRange(start.location + 1, end.location - start.location - 1)];
            urlStr = [[urlStr substringToIndex:urlStr.length - 1] substringFromIndex:1];
            [array addObject:urlStr];
        }

        _borrowingURL = [array objectAtIndex:0];
        _borrowHistoryURL = [array objectAtIndex:1];
        _reservationURL = [array objectAtIndex:2];
        _bookedURL = [array objectAtIndex:3];
        _cashURL = [array objectAtIndex:4];

        NSArray<TFHppleElement *> *recommendArr = [xpathParser searchWithXPathQuery:@"//a[@id='head_jg']"];
        _recommendURL = [recommendArr[0] objectForKey:@"href"];
        _recommendURL = [[_recommendURL substringToIndex:_recommendURL.length - 3] substringFromIndex:22];

        if (_borrowingURL.length) {
            [self searchBorrowingInfo];
        }

    }

}

- (void)borrowingArrayFromHtmlData:(NSData *)htmlData {
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray<TFHppleElement *> *tdArr = [xpathParser searchWithXPathQuery:@"//td[@class='td1']"];
    NSArray<TFHppleElement *> *inputArr = [xpathParser searchWithXPathQuery:@"//input[@type='checkbox']"];
    NSArray<TFHppleElement *> *scriptArr = [xpathParser searchWithXPathQuery:@"//a[@title='退出系统']"];
    NSString *hrefStr = [scriptArr[0] objectForKey:@"href"];
    NSString *subStr = [hrefStr componentsSeparatedByString:@"-"].lastObject;
    subStr = [subStr componentsSeparatedByString:@"?"].firstObject;
    NSInteger length = subStr.length;
    subStr = [NSString stringWithFormat:@"%ld",[subStr integerValue] - 1];
    if (length != subStr.length) {
        NSInteger num = length - subStr.length;
        for (NSInteger i = 0; i < num; i++) {
            subStr = [NSString stringWithFormat:@"0%@",subStr];
        }
    }
    hrefStr = [hrefStr componentsSeparatedByString:@"-"].firstObject;
    hrefStr = [NSString stringWithFormat:@"%@-%@",hrefStr,subStr];
    int num = (int)(tdArr.count - 1) / 11;
    
    if (num != 0) {
        for (int i = 0; i < num; i++) {
            LibraryLoginMyInfoBorrowingBean *bean = [[LibraryLoginMyInfoBorrowingBean alloc] init];
            bean.author = [tdArr[i*11+3] text];
            bean.yearOfPublication = [tdArr[i*11+5] text];
            bean.shouldReturnDate = [tdArr[i*11+6] text];
            bean.branch = [tdArr[i*11+8] text];
            bean.claimNumber = [tdArr[i*11+9] text];
            bean.renewNumber = [inputArr[i] objectForKey:@"name"];
            bean.tempURL = hrefStr;
            if ([tdArr[i*11+10] text]) {
                bean.itemDescription = [tdArr[i*11+10] text];
            }
            //设置还书日期格式和剩余天数
            [self setReturnDateLevelWithMin:bean.shouldReturnDate bean:bean];
            [_borrowingArr addObject:bean];
            
        }
        NSArray<TFHppleElement *> *titleArr = [xpathParser searchWithXPathQuery:@"//td/a"];
        for (int i = 0; i < _borrowingArr.count; i++) {
            _borrowingArr[i].title = [titleArr[i*3+8] text];
        }
        
        NSArray<TFHppleElement *> *renewAllArr = [xpathParser searchWithXPathQuery:@"//a[@title='Renew All']"];
        _renewURL = [renewAllArr[0] objectForKey:@"href"];
        _renewURL = [[_renewURL substringToIndex:_renewURL.length - 3] substringFromIndex:24];
    }
}

- (NSMutableArray<LibraryLoginMyInfoBorrowHistoryBean *> *)borrowHistoryArrayFromHtmlData:(NSData *)htmlData {
    NSMutableArray<LibraryLoginMyInfoBorrowHistoryBean *> *array = [NSMutableArray array];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray<TFHppleElement *> *tdArr = [xpathParser searchWithXPathQuery:@"//td[@class='td1']"];
    int num = (int)(tdArr.count - 1) / 10;
    for (int i = 0; i < num; i++) {
        LibraryLoginMyInfoBorrowHistoryBean *bean = [[LibraryLoginMyInfoBorrowHistoryBean alloc] init];
        bean.year = [tdArr[i*10+4] text];
        NSMutableString *dateStr = [NSMutableString stringWithFormat:@"%@",[tdArr[i*10+5] text]];
        [dateStr insertString:@"/" atIndex:4];
        [dateStr insertString:@"/" atIndex:7];
        bean.shouldReturnDate = dateStr;
        bean.shouldReturnTime = [tdArr[i*10+6] text];
        bean.returnDate = [tdArr[i*10+7] text];
        bean.returnTime = [tdArr[i*10+8] text];
        if ([tdArr[i*10+9] text]) {
            bean.fine = [tdArr[i*10+9] text];
        }
        bean.branch = [tdArr[i*10+10] text];
        [array addObject:bean];
    }
    
    NSArray<TFHppleElement *> *titleArr = [xpathParser searchWithXPathQuery:@"//td/a"];
    for (int i = 0; i < num; i++) {
        array[i].author = [titleArr[i*3+7] text];
        array[i].title = [titleArr[i*3+8] text];
    }
    return array;
}

- (void)partRenewInfoFromHtmlData:(NSData *)htmlData {
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray<TFHppleElement *> *tdArr = [xpathParser searchWithXPathQuery:@"//td[@class='td1']"];
    if ([tdArr[8] text].length) {
        if ([_delegate respondsToSelector:@selector(partRenewalDidFail:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate partRenewalDidFail:[tdArr[8] text]];
            });
        }
    } else {
        if ([_delegate respondsToSelector:@selector(partRenewalDidSuccess)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate partRenewalDidSuccess];
            });
        }
    }
}

- (void)allRenewInfoFromHtmlData:(NSData *)htmlData {
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray<TFHppleElement *> *tdArr = [xpathParser searchWithXPathQuery:@"//td[@class='td1']"];
    NSInteger num = tdArr.count / 9;
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < num; i++) {
        [array addObject:[tdArr[i*9 + 8] text]];
    }
    if ([_delegate respondsToSelector:@selector(allRenewal:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate allRenewal:array];
        });
    }
}

#pragma mark - Setter
- (void)setReturnDateLevelWithMin:(NSString *)dateString bean:(LibraryLoginMyInfoBorrowingBean *)bean {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSMutableString *dateStr = [NSMutableString stringWithFormat:@"%@",dateString];
    [dateStr insertString:@"/" atIndex:4];
    [dateStr insertString:@"/" atIndex:7];
    bean.shouldReturnDate = dateStr;
    NSDate *date = [dateFormatter dateFromString:dateStr];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:nowDate  toDate:date  options:0];
    NSInteger days = (NSInteger)[comps day];
    bean.days = [NSString stringWithFormat:@"%ld",days];
    if (days > 0) {
        bean.returnDateLevel = LibraryInfoReturnDateLevelLow;
    } else {
        bean.returnDateLevel = LibraryInfoReturnDateLevelHigh;
    }
}

@end

@implementation LibraryLoginBean

@end

@implementation LibraryLoginMyInfoBorrowingBean

@end

@implementation LibraryLoginMyInfoBorrowHistoryBean

@end

@implementation LibraryLoginMyInfoReservationBean

@end

@implementation LibraryLoginMyInfoBookedBean

@end

@implementation LibraryLoginMyInfoCashBean

@end
