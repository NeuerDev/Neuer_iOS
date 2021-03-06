//
//  GatewayModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/9.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewayModel.h"
#import "JHRequest.h"
#import "LYTool.h"

@implementation GatewayBean

@end

@interface GatewayModel () <JHRequestDelegate>
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) GatewayBean *bean;
@end

@implementation GatewayModel
{
    NSUserDefaults *userDefault;
}

#pragma mark - Init Method
- (instancetype)init {
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

#pragma mark - Init data
- (void)initData {
    _bean = [[GatewayBean alloc] init];
    userDefault = [NSUserDefaults standardUserDefaults];
}

#pragma mark - LoginViewControllerDelegate

- (BOOL)didLoginSuccessed {
    return self.isLogin;
}

//- (void)personalInformationWithDic:(NSDictionary<LoginKey,NSString *> *)info {
//    if (info.count >= 2) {
//        _account = [info valueForKey:@"account"];
//        _password = [info valueForKey:@"password"];
//       [self fetchGatewayData];
//    } else {
//        NSAssert(info.count < 2, @"数据传输错误！");
//    }
//}

#pragma mark - load data
- (BOOL)hasUser {
    if ([userDefault objectForKey:@"account"] && [userDefault objectForKey:@"password"]) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

- (void)fetchGatewayData {
    
//    action=login&ac_id=1&user_ip=&nas_ip=&user_mac=&url=&username=20154883&password=123456&save_me=0
    NSString *userName = _account != nil ? _account :[userDefault objectForKey:@"account"];
    NSString *password = _password != nil ? _password : [userDefault objectForKey:@"password"];
    NSDictionary *param = @{
                            @"action":@"login",
                            @"ac_id":@"1",
                            @"user_ip":@"",
                            @"nas_ip":@"",
                            @"user_mac":@"",
                            @"url":@"",
                            @"username":userName,
                            @"password":password,
                            @"save_me":@"0"
                            };
    
    NSURL *url = [NSURL URLWithString:@"http://ipgw.neu.edu.cn/srun_portal_pc.php?"];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url method:@"POST" params:param];
    request.delegate = self;
    request.requestType = JHRequestTypeNone;
    [request start];
    
    
}

- (void)requestDidFail:(JHRequest *)request {
    [self setIsLogin:NO];
    [_delegate fetchGatewayDataFailureWithMsg:@"登录校园网失败，请检查账户是否接入校园网"];
}

- (void)requestDidSuccess:(JHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString:@"http://ipgw.neu.edu.cn/include/auth_action.php?"];
        //创建请求对象
        NSMutableURLRequest *nsRequest = [NSMutableURLRequest requestWithURL:url];
        [nsRequest setHTTPMethod:@"post"];
        NSData *tempdata = [@"action=get_online_info&key=86316" dataUsingEncoding:NSUTF8StringEncoding];
        [nsRequest setHTTPBody:tempdata];
        
        NSURLSession *session =[NSURLSession sharedSession];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:nsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", dataStr);
            if ([dataStr isEqualToString:@"not_online"]) {
                if (self.delegate) {
                    [_delegate fetchGatewayDataFailureWithMsg:@"账号或密码错误"];
                    [self setIsLogin:NO];
                }
            } else {
                NSArray *dataArr = [dataStr componentsSeparatedByString:@","];
                if (dataArr.count >= 6) {
                    _bean.flow = dataArr[0];
                    _bean.time = dataArr[1];
                    _bean.balance = dataArr[2];
                    _bean.ip = [dataArr lastObject];
                    [self setIsLogin:YES];
                } else {
                    [self setIsLogin:NO];
                }
                NSLog(@"%@", _bean);
                if (self.delegate) {
                    [_delegate fetchGatewayDataSuccess];
                }
            }
        }];
        //启动任务
        [dataTask resume];
    });
}




- (void)quitTheGateway {
    //    action=auto_logout&info=&user_ip=172.28.127.44&username=20154883
    NSDictionary *param = @{
                            @"url":@"",
                            @"ac_id":@"1",
                            @"action":@"auto_logout",
                            @"info":@"",
                            @"user_ip":[LYTool getDeviceIPAddressesOnWifi],
                            @"username":[userDefault valueForKey:@"account"]
                            };

//    AFNetworkReachabilityManager *reachManager = [AFNetworkReachabilityManager manager];
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [reachManager startMonitoring];
    
//    NSLog(@"%@", [LYTool getDeviceIPAddressesOnWifi]);
//    [manager POST:@"https://ipgw.neu.edu.cn/srun_portal_pc.php?" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"退出成功！");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"退出失败");
//    }];
}

- (GatewayBean *)gatewayInfo {
    return self.bean;
}

#pragma mark - Private Method
- (void)setIsLogin:(BOOL)isLogin {
    _isLogin = isLogin;
}

@end
