//
//  EcardInfoModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardInfoModel.h"

@interface EcardInfoModel () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation EcardInfoModel

- (void)fetchAvatarComplete:(EcardActionCompleteBlock)block {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ecard.neu.edu.cn/SelfSearch/User/Photo.ashx"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    WS(ws);
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            ws.info.image = image;
            
            if (image) {
                // 同步设置当前用户的info
                User *currentUser = [UserCenter defaultCenter].currentUser;
                if (!currentUser.imageData) {
                    currentUser.imageData = data;
                }
                [currentUser commitUpdates];
            }
        }
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(data && !error, error);
            });
        }
    }];
    
    [task resume];
}

- (void)queryInfoComplete:(EcardActionCompleteBlock)block {
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
                    NSString *balance = [string substringFromIndex:@"主钱包余额：".length];
                    ws.info.balance = [balance stringByReplacingOccurrencesOfString:@"元" withString:@""];
                } else if ([string hasPrefix:@"性别："]) {
                    NSString *sexStr = [string substringFromIndex:@"性别：".length];
                    ws.info.sex = [sexStr isEqualToString:@"男"] ? 1 : [sexStr isEqualToString:@"女"] ? 2 : 0;
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
            ws.info.lastUpdateTime = [[[NSDate alloc] init] timeIntervalSince1970];
            [ws.info commitUpdates];
        }
        
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(data && !error, error);
            });
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

- (EcardInfoBean *)info {
    if (!_info) {
        _info = [EcardInfoBean infoWithUser:[UserCenter defaultCenter].currentUser];
    }
    
    return _info;
}

@end

@implementation EcardInfoBean

+ (EcardInfoBean *)infoWithUser:(User *)user {
    EcardInfoBean *info = [[EcardInfoBean alloc] init];
    FMDatabase *db = [DataBaseCenter defaultCenter].database;
    FMResultSet *result = [db executeQuery:@"select * from t_ecard where number = ?", user.number];
    while ([result next]) {
        info.name = user.realName;
        info.number = user.number;
        info.major = user.major;
        info.campus = user.campus;
        info.sex = user.sex;
        info.campus = user.campus;
        info.major = user.major;
        info.state = [result stringForColumn:@"state"];
        info.balance = [result stringForColumn:@"balance"];
        info.allowance = [result stringForColumn:@"allowance"];
        info.status = [result stringForColumn:@"status"];
        info.image = [UIImage imageWithData:UserCenter.defaultCenter.currentUser.imageData];
        info.lastUpdateTime = [result intForColumn:@"lastUpdateTime"];
    }
    return info;
}

- (BOOL)enable {
    return [_state isEqualToString:@"正常卡"];
}

- (EcardInfoBalanceLevel)balanceLevel {
    EcardInfoBalanceLevel balanceLevel = EcardInfoBalanceLevelUnknown;
    if (_balance) {
        float balance = [_balance floatValue];
        if (balance>50) {
            balanceLevel = EcardInfoBalanceLevelEnough;
        } else if (balance>20) {
            balanceLevel = EcardInfoBalanceLevelNotEnough;
        } else {
            balanceLevel = EcardInfoBalanceLevelNoMoney;
        }
    }
    
    return balanceLevel;
}

- (NSString *)lastUpdate {
    return [JHTool fancyStringFromDate:[NSDate dateWithTimeIntervalSince1970:_lastUpdateTime]];
}

- (void)commitUpdates {
    // 同步设置当前用户的info
    User *currentUser = [UserCenter defaultCenter].currentUser;
    if (!currentUser.realName) {
        currentUser.realName = _name;
    }
    if (!currentUser.sex) {
        currentUser.sex = _sex;
    }
    if (!currentUser.campus) {
        currentUser.campus = _campus;
    }
    if (!currentUser.major) {
        currentUser.major = _major;
    }
    [currentUser commitUpdates];
    
    FMDatabase *db = [DataBaseCenter defaultCenter].database;
    [db executeUpdate:@"replace into t_ecard (number, state, balance, allowance, status, lastUpdateTime) values (?, ?, ?, ?, ?, ?)", _number, _state, _balance, _allowance, _status, @(_lastUpdateTime)];
}

@end;
