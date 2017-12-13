//
//  AaoModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoModel.h"
#import "LYTool.h"

@interface AaoModel () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSString *cookie;
@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation AaoModel
{
    AaoAuthorCallbackBlock _block;
    AaoQueryInfoBlock _queryBlock;
    AaoGetImageBlock _imageBlock;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _scheduleInfoArray = @[];
        _scoreInfoArray = @[];
        _scoreTypeArray = @[];
    }
    
    return self;
}

#pragma mark - Login

- (void)getVerifyImage:(AaoGetImageBlock)block {
    
    _imageBlock = block;
    
    NSArray<NSHTTPCookie *> *cookies = self.session.configuration.HTTPCookieStorage.cookies;
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.domain isEqualToString:@"aao.qianhao.aiursoft.com"]) {
            [self.session.configuration.HTTPCookieStorage deleteCookie:cookie];
        }
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://aao.qianhao.aiursoft.com/ACTIONLOGON.APPPROCESS?mode=1&applicant=ACTIONQUERYSTUDENTSCHEDULEBYSELF"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
//        Cookie
        NSString *setCookie = ((NSHTTPURLResponse *)response).allHeaderFields[@"Set-Cookie"];
        NSArray *components = [setCookie componentsSeparatedByString:@" "];
        NSMutableString *tempcookie = [NSMutableString stringWithCapacity:0];
        for (int i = 0; i < components.count; ++i) {
            if (0 == i) {
                tempcookie = [tempcookie stringByAppendingString:components[0]].mutableCopy;
            } else if (2 == i) {
                tempcookie = [tempcookie stringByAppendingString:components[2]].mutableCopy;
            }
        }
        if (tempcookie.length > 1) {
            tempcookie = [tempcookie substringToIndex:tempcookie.length - 1].mutableCopy;
        }
        self.cookie = tempcookie.copy;

        
//        imgURL
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *dataArray = [hpple searchWithXPathQuery:@"//*[@class='in']/img"];
        NSMutableString *imgStr = [NSMutableString stringWithCapacity:0];
        for (TFHppleElement *element in dataArray) {
            if ([element objectForKey:@"src"]) {
                imgStr = [element objectForKey:@"src"].mutableCopy;
            }
        }
        _imageUrl = [@"https://aao.qianhao.aiursoft.com/" stringByAppendingString:imgStr].copy;
    
        SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
        // 这个cookie是必须的，否则图片的cookie将跟之后网页的cookie不一致。
        [downloader setValue:self.cookie forHTTPHeaderField:@"Cookie"];
        [downloader downloadImageWithURL:[NSURL URLWithString:self.imageUrl] options:SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_imageBlock && image) {
                    _imageBlock(YES, image);
                } else {
                    _imageBlock(NO, nil);
                }
            });
        }];
    }];
    
    [task resume];
}

- (void)authorUser:(NSString *)userName password:(NSString *)password verifyCode:(NSString *)verifyCode queryType:(AaoAtionQueryType)queryType callBack:(AaoAuthorCallbackBlock)callback {
    
    _block = callback;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://aao.qianhao.aiursoft.com/ACTIONLOGON.APPPROCESS?mode="] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
//    默认按照登录学生成绩查询登录
    NSString *type = nil;
    switch (queryType) {
        case 0:
        {
            type = @"ACTIONQUERYSTUDENTSCHEDULEBYSELF";
        }
            break;
        case 1:
        {
            type = @"ACTIONQUERYSTUDENTSCORE";
        }
            break;
    }
    
    
    NSDictionary *params = @{
                             @"WebUserNO" : userName,
                             @"applicant" : type,
                             @"Password" : password,
                             @"Agnomen" : verifyCode,
                             @"submit7" : @"%%B5%%C7%%C2%%BC"
                             };
    request.HTTPMethod = @"POST";
    request.HTTPBody = [params.queryString.URLEncode dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"%@", [NSString stringFromGBKData:data]);
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
        NSArray <TFHppleElement *>*array = [hpple searchWithXPathQuery:@"//script"];
        TFHppleElement *element = ([array lastObject]).children[0];
        NSString *alertString = [LYTool subStringFromString:element.content startString:@"(\"" endString:@"\\n"];
        NSLog(@"%@", alertString);
        
        if (_block) {
            _block(NO, alertString);
        }
    }];
    [task resume];
}


#pragma mark - QueryInfo

// 查询考试日程
- (void)queryExaminationScheduleWithBlock:(AaoQueryInfoBlock)block {
    
    _queryBlock = block;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://aao.qianhao.aiursoft.com/ACTIONQUERYEXAMTIMETABLEBYSTUDENT.APPPROCESS?mode=2"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (_queryBlock) {
            _queryBlock(YES, [NSString stringFromGBKData:data]);
        }
    }];
    [task resume];
}

// 查询学籍信息
- (void)queryStudentStatusWithBlock:(AaoQueryInfoBlock)block {
    
    _queryBlock = block;
    WS(ws);
    
    AaoStudentStatusBean *stautsBean = [[AaoStudentStatusBean alloc] init];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://aao.qianhao.aiursoft.com/ACTIONQUERYBASESTUDENTINFO.APPPROCESS"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [ws queryAvatarImageWithBlock:^(BOOL success, UIImage *verifyImage){
            if (verifyImage) {
                stautsBean.status_photo = verifyImage;
                _queryBlock(YES, @"success");
            } else {
                _queryBlock(NO, @"failure");
            }
        }];
    }];
    
    
    [task resume];
}

- (void)queryAvatarImageWithBlock:(AaoGetImageBlock)block {
    // 头像
    _imageBlock = block;
    
    SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
    [downloader setValue:self.cookie forHTTPHeaderField:@"Cookie"];
    [downloader downloadImageWithURL:[NSURL URLWithString:@"https://aao.qianhao.aiursoft.com/ACTIONDSPUSERPHOTO.APPPROCESS"] options:SDWebImageDownloaderAllowInvalidSSLCertificates progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (_imageBlock) {
            _imageBlock(YES, image);
        }
    }];
}

// 培养计划
- (void)queryTrainingPlanWithBlock:(AaoQueryInfoBlock)block {
    
    _queryBlock = block;
    
    NSMutableURLRequest *request = nil;
    if ([UserCenter defaultCenter].currentUser) {
        NSString *year = [[UserCenter defaultCenter].currentUser.number substringToIndex:4];
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://202.118.27.146/plan%@/Pro_print.action?pro.proid=X080902&view=yes", year]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    } else {
        _queryBlock(NO, @"请先登录");
    }
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (_queryBlock) {
            _queryBlock(YES, [NSString stringFromGBKData:data]);
        }
    }];
    [task resume];
}

// 学业预警
- (void)querySchoolPrecautionWithBlock:(AaoQueryInfoBlock)block {
    
    _queryBlock = block;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://aao.qianhao.aiursoft.com/ACTIONQUERYBASESTUDENTINFO3.APPPROCESS"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (_queryBlock) {
            _queryBlock(YES, [NSString stringFromGBKData:data]);
        }
    }];
    
    [task resume];
}

- (void)queryStudentScoreWithTermType:(AaoTermType)termType Block:(AaoQueryInfoBlock)block {
    
    _queryBlock = block;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://aao.qianhao.aiursoft.com/ACTIONQUERYSTUDENTSCORE.APPPROCESS"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString stringWithFormat:@"YearTermNO=%ld", (long)termType] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [self ly_updateStudentScoreWithData:data];
            _queryBlock(YES, nil);
        } else {
            _queryBlock(NO, nil);
        }
    }];
    
    [task resume];
}

#pragma mark - Private Method

- (void)ly_updateStudentScheduleWithData:(NSData *)data {
    NSMutableArray *scheduleTempArray = @[].mutableCopy;
    TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
    
    // 先分出 6 行
    NSArray *elementArray = [hpple searchWithXPathQuery:@"//*[@style='height:100px']"];
    for (int i = 0; i < elementArray.count; ++i) {
        //                再分出每一行中的 7 列
        NSArray <TFHppleElement *> *classArray = [elementArray[i] childrenWithTagName:@"td"];
        for (int j = 1; j < classArray.count; ++j) {
            //                    如果有课，则展示出来
            if ([classArray[j] childrenWithTagName:@"text"].count > 1) {
                NSArray <TFHppleElement *> *textArray = [classArray[j] childrenWithTagName:@"text"];
                AaoStudentScheduleBean *bean = [[AaoStudentScheduleBean alloc] init];
                
                
                for (int k = 0; k < textArray.count; ++k) {
                    if ([textArray[k].content containsString:@"周"]) {
                        bean.schedule_classWeek = textArray[k].content;
                        if ([textArray[k].content containsString:@"-"]) {
                            bean.schedule_classWeek = [[textArray[k].content componentsSeparatedByString:@" "] firstObject];
                            NSArray <NSString *> *seperateArray = [bean.schedule_classWeek componentsSeparatedByString:@"-"];
                            bean.schedule_beginWeek = [[seperateArray firstObject] integerValue];
                            
                            NSRange range = NSMakeRange(0, [[seperateArray lastObject] rangeOfString:@"周"].location);
                            bean.schedule_endWeek = [[[seperateArray lastObject] substringWithRange:range] integerValue];
                            
                            NSArray <NSString *>*sections = [[[textArray[k].content componentsSeparatedByString:@" "] lastObject] componentsSeparatedByString:@"节"];
                            bean.schedule_classSum = [[sections firstObject] intValue];
                            
                            
                        } else {
                            bean.schedule_beginWeek = [[[textArray[k].content componentsSeparatedByString:@" "] firstObject] integerValue];
                            bean.schedule_endWeek = bean.schedule_beginWeek;
                        }
                        break;
                    }
                }
                
                bean.schedule_courceName = textArray[0].content;
                bean.schedule_classDay = j;
                bean.schedule_classPeriod = i;
                bean.schedule_duringClasses = [NSString stringWithFormat:@"%d ~ %ld 节", (i + 1) + i, bean.schedule_classSum + (i + 1) + i];
                
                bean.schedule_color = [UIColor randomColor];
                if (scheduleTempArray.count) {
                    for (AaoStudentScheduleBean *tempBean in scheduleTempArray) {
                        if ([bean.schedule_courceName isEqualToString:tempBean.schedule_courceName]) {
                            bean.schedule_color = tempBean.schedule_color;
                        }
                    }
                }
                //                            缺少教师信息或教室信息
                if (textArray.count == 3) {
                    if ([LYTool isContainsNumber:textArray[1].content]) {
                        bean.schedule_classroom = textArray[1].content;
                        bean.schedule_teacherName = @"";
                    } else {
                        bean.schedule_teacherName = textArray[1].content;
                        bean.schedule_classroom = @"";
                    }
                } else if (textArray.count == 4) {
                    bean.schedule_teacherName = textArray[1].content;
                    bean.schedule_classroom = textArray[2].content;
                } else if (textArray.count > 4) {
                    if (textArray.count == 6) {
                        
                    }
                }
                
                [scheduleTempArray addObject:bean];
            } else {
                continue;
            }
        }
    }
    
    NSMutableArray <AaoStudentScheduleBean *>*classTempArray = scheduleTempArray.mutableCopy;
    for (int i = 0; i < scheduleTempArray.count; ++i) {
        AaoStudentScheduleBean *tempBean = scheduleTempArray[i];
        if (tempBean.schedule_classSum == 4) {
            for (int j = i; j < scheduleTempArray.count; ++j) {
                AaoStudentScheduleBean *innerBean = scheduleTempArray[j];
                if ([tempBean.schedule_courceName isEqualToString:innerBean.schedule_courceName] && tempBean.schedule_classPeriod == innerBean.schedule_classPeriod - 1) {
                    [classTempArray objectAtIndex:j].schedule_duringClasses = tempBean.schedule_duringClasses;
                }
            }
        }
    }
    
    _scheduleInfoArray = classTempArray.copy;
}

- (void)ly_updateStudentScoreWithData:(NSData *)data {
    
    TFHpple *hpple = [TFHpple hppleWithHTMLData:data];
    NSArray <TFHppleElement *> *searchElements = [hpple searchWithXPathQuery:@"//*[@style='BORDER-COLLAPSE:collapse']/tr"];
    
    NSMutableArray *tempArray = @[].mutableCopy;
    for (int i = 1; i < searchElements.count - 1; ++i) {
        TFHppleElement *element = searchElements[i];
        NSArray <TFHppleElement *> *textElements = [element childrenWithTagName:@"text"];
        if (textElements.count > 0) {
            NSArray <TFHppleElement *> *scoreArray = [element childrenWithTagName:@"td"];
            if ([scoreArray[1].text isEqualToString:@" "] && [scoreArray[2].text isEqualToString:@" "]) {
                break;
            }
            AaoStudentScoreBean *bean = [[AaoStudentScoreBean alloc] init];
            bean.score_curriculum = scoreArray[0].text;
            bean.score_number = scoreArray[1].text;
            bean.score_name = scoreArray[2].text;
            bean.score_examType = scoreArray[3].text;
            bean.score_period = scoreArray[4].text;
            bean.score_credit = scoreArray[5].text;
            bean.score_scoreType = scoreArray[6].text;
            bean.score_dailyScore = scoreArray[7].text;
            if (!scoreArray[7].text) {
                bean.score_dailyScore = @"暂无记录";
            }
            bean.score_midtermScore = scoreArray[8].text;
            if (!scoreArray[8].text) {
                bean.score_midtermScore = @"暂无记录";
            }
            bean.score_finalScore = scoreArray[9].text;
            if (!scoreArray[9].text) {
                bean.score_finalScore = @"暂无记录";
            }
            bean.score_totalScore = scoreArray[10].text;
            [tempArray addObject:bean];
        }
    }
    
    _scoreInfoArray = tempArray.copy;
    
    
    [self ly_initializeTermTypeWithData:data];
}

- (void)ly_initializeTermTypeWithData:(NSData *)data {
    TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
    NSArray <TFHppleElement *>*array = [hpple searchWithXPathQuery:@"//*[@name='YearTermNO']/option"];
    NSMutableArray <NSDictionary *>*searchTypeArray = @[].mutableCopy;
    for (int i = 0; i < array.count; ++i) {
        TFHppleElement *element = array[i];
        NSDictionary *param = @{
                                element.text : @(i+1)
                                };
        [searchTypeArray addObject:param];
    }
    
    _scoreTypeArray = searchTypeArray;
}



- (void)setCurrentTermTypeWithName:(NSString *)name {
    for (int i = 0; i < self.scoreTypeArray.count; ++i) {
        if ([[self.scoreTypeArray[i].allKeys firstObject] isEqualToString:name]) {
            _currentTermType = (AaoTermType)[self.scoreTypeArray[i].allValues firstObject];
        }
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    // 判断服务器返回的是否为服务器信任证书
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        //        获取服务器返回的这个信任证书
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        if (completionHandler) {
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    NSURLSessionDataTask *newTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@", response.URL.absoluteString);
        
        NSString *urlString = response.URL.absoluteString;
//        此时 block 已经在登录模块赋值了
        if (_block && [urlString isEqualToString:@"https://aao.qianhao.aiursoft.com/ACTIONQUERYSTUDENTSCHEDULEBYSELF.APPPROCESS"]) {
            [self ly_updateStudentScheduleWithData:data];
            _block(YES, nil);
            
        } else if (_block && [urlString isEqualToString:@"https://aao.qianhao.aiursoft.com/ACTIONQUERYSTUDENTSCORE.APPPROCESS"]) {
            [self ly_updateStudentScoreWithData:data];
            _block(YES, nil);
        } else {
            NSLog(@"请先登录");
            _block(NO, @"请先登录");
        }
        
    }];
    [newTask resume];
}

#pragma mark - Getter

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{
                                                @"User-Agent":@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_1) AppleWebKit/604.3.5 (KHTML, like Gecko) Version/11.0.1 Safari/604.3.5",
                                                };
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _session;
}
@end

@implementation AaoSchoolPrecautionBean

@end


@implementation AaoStudentScoreBean

@end


@implementation AaoStudentScheduleBean

@end


@implementation AaoStudentStatusBean

@end


@implementation AaoExaminationScheduleBean

@end
