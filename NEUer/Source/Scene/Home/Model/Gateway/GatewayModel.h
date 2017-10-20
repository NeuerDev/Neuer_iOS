//
//  GatewayModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/9.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"

@interface GatewayBean : NSObject
@property (strong, nonatomic) NSString *flow;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *balance;
@property (strong, nonatomic) NSString *ip;

@end

@protocol GatewayModelDelegate

@required

- (void)fetchGatewayDataSuccess;
- (void)fetchGatewayDataFailureWithMsg:(NSString *)msg;

@end

@interface GatewayModel : NSObject
@property (nonatomic, weak) id<GatewayModelDelegate> delegate;
- (BOOL)hasUser;
- (void)fetchGatewayData;
- (void)quitTheGateway;
- (GatewayBean *)gatewayInfo;

@end
