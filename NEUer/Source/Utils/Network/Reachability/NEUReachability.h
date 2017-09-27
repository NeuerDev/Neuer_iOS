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
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

#pragma mark IPv6 协议支持
// Reachability完全支持IPv6协议.


extern NSString *kReachabilityChangedNotification;


@interface NEUReachability : NSObject

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
 *开始在当前时间循环中监听Reachability通知.
 */
- (BOOL)startNotifier;
- (void)stopNotifier;

- (NetworkStatus)currentReachabilityStatus;

/*!
 * 除非连接已经建立,WWAN可用,但是却没有激活. WiFi 连结也许需要一个VPN来进行连接.
 */
- (BOOL)connectionRequired;

@end
