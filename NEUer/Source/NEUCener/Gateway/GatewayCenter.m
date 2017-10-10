//
//  GatewayCenter.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewayCenter.h"
#import "JHReachability.h"

@interface GatewayCenter ()

@property (nonatomic, assign) BOOL networkEnable;
@property (nonatomic, assign) GatewayStatus wifiStatus;
@property (nonatomic, assign) GatewayStatus campusStatus;
@property (nonatomic, assign) GatewayStatus reachableStatus;
@property (nonatomic, strong) JHReachability *reachability;

@end

@implementation GatewayCenter

static GatewayCenter * center;

#pragma mark - Singleton

+ (instancetype)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[GatewayCenter alloc] init];
    });
    
    return center;
}

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        _reachability = [JHReachability reachabilityForInternetConnection];
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)startMonitoring {
    
    _networkEnable = NO;
    _wifiStatus = GatewayStatusUnknown;
    _campusStatus = GatewayStatusUnknown;
    _reachableStatus = GatewayStatusUnknown;
    
    __weak __typeof(self) weakSelf = self;
    [_reachability setReachabilityStatusChangeBlock:^(JHReachabilityStatus status) {
        switch (status) {
            case JHReachabilityStatusUnknown:
                NSLog(@"未知");
                _networkEnable = NO;
                weakSelf.wifiStatus = GatewayStatusUnknown;
                weakSelf.campusStatus = GatewayStatusUnknown;
                weakSelf.reachableStatus = GatewayStatusUnknown;
                break;
            case JHReachabilityStatusNotReachable:
                NSLog(@"不可达");
                _networkEnable = NO;
                weakSelf.wifiStatus = GatewayStatusNO;
                weakSelf.campusStatus = GatewayStatusNO;
                weakSelf.reachableStatus = GatewayStatusNO;
                break;
            case JHReachabilityStatusReachableViaWiFi:
                NSLog(@"Wi-Fi");
                _networkEnable = YES;
                weakSelf.wifiStatus = GatewayStatusYES;
                [weakSelf startNetworkTest];
                break;
            case JHReachabilityStatusReachableViaWWAN:
                NSLog(@"3g/4g");
                _networkEnable = YES;
                weakSelf.wifiStatus = GatewayStatusNO;
                [weakSelf startNetworkTest];
                break;

            default:
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kGatewayNetworkStatusChangeNotification object:weakSelf];
    }];
    
    [_reachability startNotifier];
}

- (GatewayStatus)wifiStatus {
    return _wifiStatus;
}

- (GatewayStatus)campusStatus {
    return _campusStatus;
}

- (GatewayStatus)reachableStatus {
    return _reachableStatus;
}

- (BOOL)networkEnable {
    return _networkEnable;
}

#pragma mark - Private Methods

- (void)startNetworkTest {
    
    _campusStatus = GatewayStatusUnknown;
    _reachableStatus = GatewayStatusUnknown;
    
    JHRequest *innetRequest = [[JHRequest alloc] initWithUrl:[NSURL URLWithString:@"http://ipgw.neu.edu.cn"]];
    innetRequest.requestType = JHRequestTypeCancelPrevious;
    innetRequest.timeoutInterval = 10;
    JHRequest *outnetRequest = [[JHRequest alloc] initWithUrl:[NSURL URLWithString:@"http://www.baidu.com"]];
    outnetRequest.requestType = JHRequestTypeCancelPrevious;
    outnetRequest.timeoutInterval = 10;
    
    __weak __typeof(self) weakSelf = self;
    [innetRequest setCompleteBlock:^(JHRequest *request) {
        if (request.error) {
            weakSelf.campusStatus = GatewayStatusNO;
        } else {
            weakSelf.campusStatus = GatewayStatusYES;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kGatewayNetworkStatusChangeNotification object:weakSelf];
    }];
    [innetRequest start];
    
    [outnetRequest setCompleteBlock:^(JHRequest *request) {
        if ([request.response.string containsString:@"<!--STATUS OK-->"]) {
            weakSelf.reachableStatus = GatewayStatusYES;
        } else {
            weakSelf.reachableStatus = GatewayStatusNO;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kGatewayNetworkStatusChangeNotification object:weakSelf];
    }];
    [outnetRequest start];
}

@end
