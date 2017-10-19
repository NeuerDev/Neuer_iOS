//
//  EcardTableViewCell.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/19.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EcardTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *moneyLabel;

@property (nonatomic, strong) EcardConsumeBean *consumeBean;

@end
