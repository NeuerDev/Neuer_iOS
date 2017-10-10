//
//  GatewayCenter.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GatewayStatus) {
    GatewayStatusUnknown = -1,  // 正在检测
    GatewayStatusNO,            // NO
    GatewayStatusYES,           // YES
};

static NSString * const kGatewayNetworkStatusChangeNotification = @"kGatewayNetworkStatusChangeNotification";

@interface GatewayCenter : NSObject

+ (instancetype)defaultCenter;

- (void)startMonitoring;

/**
 返回 wifi / 3,4g 状态
 */
- (GatewayStatus)wifiStatus;

/**
 返回校园网状态
 */
- (GatewayStatus)campusStatus;

/**
 返回网络连接状态
 */
- (GatewayStatus)reachableStatus;

/**
 返回是否开启了网络
 */
- (BOOL)networkEnable;

/**
 返回是否在校园网环境 是否能连接到ipgw
 */
- (void)testCampusEnvironment:(void(^)(BOOL isCampus))callback;

/**
 返回是否已经能上网 是否能连接到baidu
 */
- (void)testReachableStatus:(void(^)(BOOL isReachable))callback;


@end
