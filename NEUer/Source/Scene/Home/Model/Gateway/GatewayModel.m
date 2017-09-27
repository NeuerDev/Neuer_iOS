//
//  GatewayModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewayModel.h"
#import <AFNetworking/AFNetworking.h>

// 001 using wifi
// 010 in campus
// 100 reachable
typedef NS_OPTIONS(NSInteger, GatewayState) {
    GatewayStateViaWiFi     = 1 << 0,
    GatewayStateCampus      = 1 << 1,
    GatewayStateReachable   = 1 << 2,
};

@interface GatewayModel ()

@property (nonatomic, assign) GatewayState state;
@property (nonatomic, strong) AFNetworkReachabilityManager *innerReachability;
@property (nonatomic, strong) AFNetworkReachabilityManager *outerReachability;
@end

@implementation GatewayModel

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        _state = 0;
        _innerReachability = [AFNetworkReachabilityManager managerForDomain:@"ipgw.neu.edu.cn"];
        _outerReachability = [AFNetworkReachabilityManager managerForDomain:@"taobao.com"];
    }
    
    return self;
}


#pragma mark - Public Methods

- (void)startMonitoring {
    
    __weak __typeof(self) weakSelf = self;
    [_innerReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"内网未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"内网不可达");
                weakSelf.state = weakSelf.state & (GatewayStateViaWiFi|GatewayStateReachable);
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"内网 Wi-Fi 连接成功");
                weakSelf.state = weakSelf.state | (GatewayStateViaWiFi|GatewayStateCampus);
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"内网 3g/4g 连接成功");
                weakSelf.state = weakSelf.state | GatewayStateCampus;
                weakSelf.state = weakSelf.state & (GatewayStateCampus|GatewayStateReachable);
                break;
                
            default:
                break;
        }
    }];
    [_outerReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"外网未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"外网不可达");
                weakSelf.state = weakSelf.state & (GatewayStateViaWiFi|GatewayStateReachable);
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"外网 Wi-Fi 连接成功");
                weakSelf.state = weakSelf.state | (GatewayStateViaWiFi|GatewayStateReachable);
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"外网 3g/4g 连接成功");
                weakSelf.state = weakSelf.state | GatewayStateReachable;
                weakSelf.state = weakSelf.state & (GatewayStateCampus|GatewayStateReachable);
                break;
                
            default:
                break;
        }
    }];
    
    [_innerReachability startMonitoring];
    [_outerReachability startMonitoring];
}

- (BOOL)hasUser {
    return YES;
}


- (BOOL)isWiFi {
    return _state & GatewayStateViaWiFi;
}


- (BOOL)isInCampus {
    return _state & GatewayStateCampus;
}


- (BOOL)isReachable {
    return _state & GatewayStateReachable;
}


- (void)queryInfo:(void (^)(NSArray<NSString *> *))infoBlock {
    
}


- (void)login:(void (^)(BOOL, NSString *))loginBlock {
    
}

@end
