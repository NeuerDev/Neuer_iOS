//
//  NetworkInternetListTableViewCell.h
//  NEUer
//
//  Created by lanya on 2017/11/5.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GatewaySelfServiceMenuModel.h"

@interface NetworkInternetListTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UILabel *deviceLabel;
@property (nonatomic, strong) UILabel *lastActiveLabel;
@property (nonatomic, strong) UILabel *logoutTimeLabel; // 下线时间
@property (nonatomic, strong) UILabel *usedFlowLabel;

@property (nonatomic, strong) GatewaySelfServiceMenuInternetRecordsInfoBean *infoBean;

@end
