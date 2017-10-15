//
//  GatewayModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/9.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewayModel.h"
#import "JHRequest.h"

@implementation GatewayBean

@end

@interface GatewayModel ()<LoginViewControllerDelegate, JHRequestDelegate>
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) GatewayBean *bean;
@property (nonatomic, assign) BOOL requestState;
@end

@implementation GatewayModel

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
    [LoginViewController shareLoginViewController].delegate = self;
}

#pragma mark - LoginViewControllerDelegate
- (void)personalInformationArray:(NSArray <NSString *>*)info withloginState:(LoginState)loginState {
    if (info.count >= 2) {
        _account = [info objectAtIndex:0];
        _password = [info objectAtIndex:1];
        [self fetchGatewayData];
    }
}

- (BOOL)didSuccessLogin {
    if (self.requestState) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

#pragma mark - load data
- (BOOL)hasUser {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"account"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"password"]) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

- (void)fetchGatewayData {
    
    NSURL *url = [NSURL URLWithString:@"http://ipgw.neu.edu.cn/srun_portal_pc.php"];
    NSString *userName = _account != nil ? _account :[[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
    NSString *password = _password != nil ? _password : [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
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
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url method:@"POST" params:param];
    request.delegate = self;
    request.requestType = JHRequestTypeNone;
    [request start];
}

- (void)requestDidFail:(JHRequest *)request {
    [self setRequestState:NO];
    [_delegate fetchGatewayDataFailureWithMsg:@"登录校园网失败，请检查账户是否接入校园网"];
}

- (void)requestDidSuccess:(JHRequest *)request {
    
    NSURL *url = [NSURL URLWithString:@"http://ipgw.neu.edu.cn/include/auth_action.php?"];
    //创建请求对象
    NSMutableURLRequest *nsRequest = [NSMutableURLRequest requestWithURL:url];
    [nsRequest setHTTPMethod:@"post"];
    NSData *tempdata = [@"action=get_online_info&key=91714" dataUsingEncoding:NSUTF8StringEncoding];
    [nsRequest setHTTPBody:tempdata];
    
    NSURLSession *session =[NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:nsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([dataStr isEqualToString:@"not_online"]) {
            if (self.delegate) {
                [_delegate fetchGatewayDataFailureWithMsg:@"账号或密码错误"];
            }
            [self setRequestState:NO];
        } else {
            NSArray *dataArr = [dataStr componentsSeparatedByString:@","];
            _bean.flow = dataArr[0];
            _bean.time = dataArr[1];
            _bean.balance = dataArr[2];
            _bean.ip = [dataArr lastObject];
            NSLog(@"%@", _bean);
            if (self.delegate) {
                [_delegate fetchGatewayDataSuccess];
            }
            [self setRequestState:YES];
        }
    }];
    //启动任务
    [dataTask resume];
}

- (GatewayBean *)gatewayInfo {
    return self.bean;
}

#pragma mark - Private Method
- (void)setRequestState:(BOOL)requestState {
    _requestState = requestState;
}

@end
