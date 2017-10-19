//
//  LibraryLoginModel.m
//  NEUer
//
//  Created by kl h on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryLoginModel.h"
#import "LibraryLoginMyInfoModel.h"


@interface LibraryLoginModel () <JHRequestDelegate>

@property (nonatomic, strong) LibraryLoginMyInfoModel *infoModel;
@property (nonatomic, strong) LibraryLoginBean *loginBean;
@property (nonatomic) BOOL isLogin;

@end

@implementation LibraryLoginModel
#pragma mark - Public Methods
- (void)gotoLogin {
    _isLogin = NO;
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/F?func=file&file_name=login-session"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];

}

- (void)login {
    _isLogin = YES;
    _username = @"20154858";
    _password = @"154858";
   
    NSString *urlStr = [NSString stringWithFormat:@"%@",_tmpURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url method:@"POST" params:@{@"func":@"login-session".URLEncode,@"login_source":@"bor-info".URLEncode,@"bor_id":_username.URLEncode,@"bor_verification":_password.URLEncode,@"bor_library":@"NEU50".URLEncode}];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    if (!_isLogin) {
        NSData *htmlData = request.response.data;
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
        // 获取 var tmp 暂存索引 服务器生成的 必须保存
        NSArray<TFHppleElement *> *formArray = [xpathParser searchWithXPathQuery:@"//form[@name='form1']"];
        _tmpURL = [formArray[0] objectForKey:@"action"];
        [self login];
    } else {
        NSData *htmlData = request.response.data;
        [self resultFromHtmlData:htmlData];
        [self.infoModel searchBorrowHistoryInfo];
    }
    
}

- (void)requestDidFail:(JHRequest *)request {
    
}

#pragma mark - Private Methods
- (void)resultFromHtmlData:(NSData *)htmlData {
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
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
    _infoModel = [[LibraryLoginMyInfoModel alloc] init];
    _infoModel.borrowingURL = [array objectAtIndex:0];
    _infoModel.borrowHistoryURL = [array objectAtIndex:1];
    _infoModel.reservationURL = [array objectAtIndex:2];
    _infoModel.bookedURL = [array objectAtIndex:3];
    _infoModel.cashURL = [array objectAtIndex:4];
    
}

@end

@implementation LibraryLoginBean

@end

