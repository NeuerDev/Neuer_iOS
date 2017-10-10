//
//  GatewayCenter.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GatewayStatus) {
    GatewayStatusUnknown = -1,
    GatewayStatusNO,
    GatewayStatusYES,
};

static NSString * const kGatewayNetworkStatusChangeNotification = @"kGatewayNetworkStatusChangeNotification";

@interface GatewayCenter : NSObject

+ (instancetype)defaultCenter;

- (void)startMonitoring;

- (GatewayStatus)wifiStatus;

- (GatewayStatus)campusStatus;

- (GatewayStatus)reachableStatus;

- (BOOL)networkEnable;

@end
