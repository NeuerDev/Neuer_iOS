//
//  GatewayModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GatewayModel : NSObject

- (void)startMonitoring;

- (BOOL)hasUser;

- (BOOL)isWiFi;

- (BOOL)isInCampus;

- (BOOL)isReachable;

- (void)queryInfo:(void(^)(NSArray<NSString *> *infos))infoBlock;

- (void)login:(void(^)(BOOL isSuccess, NSString *msg))loginBlock;

@end
