//
//  GatewayComponentInfoView.h
//  NEUer
//
//  Created by lanya on 2017/10/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GatewayModel.h"

@interface GatewayComponentInfoView : UIView

//- (instancetype)initWithGatewayComponentInfo:(GatewayComponentInfoType)infoType withGatewayBean:(GatewayBean *)bean;
- (void)setUpWithGatewayBean:(GatewayBean *)bean;

@end
