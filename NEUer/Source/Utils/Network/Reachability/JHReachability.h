//
//  NEUReachability.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger {
    JHReachabilityStatusUnknown         = -1,
    JHReachabilityStatusNotReachable    = 0,
    JHReachabilityStatusReachableViaWiFi= 1,
    JHReachabilityStatusReachableViaWWAN= 2,
} JHReachabilityStatus;

typedef void(^JHReachabilityStatusChangeBlock)(JHReachabilityStatus status);

#pragma mark IPv6 协议支持
// Reachability完全支持IPv6协议.


extern NSString *kReachabilityChangedNotification;


@interface JHReachability : NSObject

@property (nonatomic, strong) JHReachabilityStatusChangeBlock changeBlock;

/*!
 * 用来检测hostName的连接状态.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * 用来检测IP地址的连接状态.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/*!
 * 用来检测默认的连接是否可用, 被用在没有特定连接的主机.
 */
+ (instancetype)reachabilityForInternetConnection;

/*!
 * 设置回调 block
 */
- (void)setReachabilityStatusChangeBlock:(JHReachabilityStatusChangeBlock)block;

- (JHReachabilityStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags;

/*!
 *开始在当前时间循环中监听Reachability通知.
 */
- (BOOL)startNotifier;
- (void)stopNotifier;

- (JHReachabilityStatus)currentReachabilityStatus;

/*!
 * 除非连接已经建立,WWAN可用,但是却没有激活. WiFi 连结也许需要一个VPN来进行连接.
 */
- (BOOL)connectionRequired;

@end
