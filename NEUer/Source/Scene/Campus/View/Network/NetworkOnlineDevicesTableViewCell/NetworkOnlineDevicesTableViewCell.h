//
//  NetworkOnlineDevicesTableViewCell.h
//  NEUer
//
//  Created by lanya on 2017/11/5.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GatewaySelfServiceMenuModel.h"

typedef void(^NetworkOnlineDevicesTableViewCellSetActionBlock)(NSInteger tag);

@interface NetworkOnlineDevicesTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UILabel *deviceLabel;
@property (nonatomic, strong) UILabel *lastActiveLabel;
@property (nonatomic, strong) UIButton *offLineButton;

@property (nonatomic, strong) GatewaySelfServiceMenuOnlineInfoBean *onlineInfoBean;

- (void)setOnlineDevicesActionBlock:(NetworkOnlineDevicesTableViewCellSetActionBlock)block;

@end
