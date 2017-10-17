//
//  GatewayComponentInfoView.h
//  NEUer
//
//  Created by lanya on 2017/10/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GatewayModel.h"

//typedef NS_OPTIONS(NSUInteger, GatewayComponentInfoType) {
//    GatewayComponentInfoTypeUserId          = 1 << 0,
//    GatewayComponentInfoTypeFlow            = 1 << 1,
//    GatewayComponentInfoTypeBalance         = 1 << 2,
//    GatewayComponentInfoTypeIpAddress       = 1 << 3,
//    GatewayComponentInfoTypeTime            = 1 << 4
//};

@interface GatewayComponentInfoView : UIView

//- (instancetype)initWithGatewayComponentInfo:(GatewayComponentInfoType)infoType withGatewayBean:(GatewayBean *)bean;
- (void)setUpWithGatewayBean:(GatewayBean *)bean;

@end
