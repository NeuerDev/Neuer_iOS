//
//  NetworkInternetListTableViewCell.m
//  NEUer
//
//  Created by lanya on 2017/11/5.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkInternetListTableViewCell.h"
#import "LYTool.h"

@interface NetworkInternetListTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UILabel *deviceLabel;
@property (nonatomic, strong) UILabel *lastActiveLabel;
@property (nonatomic, strong) UILabel *logoutTimeLabel; // 下线时间
@property (nonatomic, strong) UILabel *usedFlowLabel;
@property (nonatomic, strong) UILabel *lastActiveStatusLabel;
@property (nonatomic, strong) UILabel *logoutTimeStatusLabel;

@end

@implementation NetworkInternetListTableViewCell

#pragma mark - Init Methods

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initConstraints];
        
        self.separatorInset = UIEdgeInsetsMake(0, 72, 0, 16);
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)initConstraints {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.mas_equalTo(@(48));
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
    }];
    
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).with.offset(8);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
    }];
    
    [self.deviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(self.infoView);
    }];
    
    [self.lastActiveStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceLabel.mas_bottom).with.offset(4);
        make.left.equalTo(self.infoView);
    }];
    
    [self.lastActiveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceLabel.mas_bottom).with.offset(4);
        make.left.equalTo(self.lastActiveStatusLabel.mas_right).with.offset(4);
    }];
    
    [self.logoutTimeStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastActiveLabel.mas_bottom).with.offset(4);
        make.left.and.bottom.equalTo(self.infoView);
    }];
    [self.logoutTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastActiveLabel.mas_bottom).with.offset(4);
        make.left.equalTo(self.lastActiveLabel);
    }];
    
    [self.usedFlowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.and.right.equalTo(self.infoView);
    }];
}

#pragma mark - Setter
- (void)setInfoBean:(GatewaySelfServiceMenuInternetRecordsInfoBean *)infoBean {
    _infoBean = infoBean;
    
    if ([_infoBean.internet_operation isEqualToString:@"iPad"] || [_infoBean.internet_operation isEqualToString:@"iPhone"] || [_infoBean.internet_operation isEqualToString:@"Android"]) {
        _iconImageView.image = [UIImage imageNamed:@"network_phone"];
    } else {
        _iconImageView.image = [UIImage imageNamed:@"network_computer"];
    }
    
    _lastActiveLabel.text = [NSString stringWithFormat:@"%@", _infoBean.internet_lastactive];
    _logoutTimeLabel.text = [NSString stringWithFormat:@"%@", _infoBean.internet_logoutTime];
    _deviceLabel.text = _infoBean.internet_operation;
    _usedFlowLabel.text = _infoBean.internet_usedFlow;
    
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_iconImageView];
    }
    
    return _iconImageView;
}

- (UIView *)infoView {
    if (!_infoView) {
        _infoView = [[UIView alloc] init];
        [self.contentView addSubview:_infoView];
    }
    
    return _infoView;
}

- (UILabel *)deviceLabel {
    if (!_deviceLabel) {
        _deviceLabel = [[UILabel alloc] init];
        _deviceLabel.numberOfLines = 1;
        _deviceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.infoView addSubview:_deviceLabel];
    }
    
    return _deviceLabel;
}

- (UILabel *)lastActiveLabel {
    if (!_lastActiveLabel) {
        _lastActiveLabel = [[UILabel alloc] init];
        _lastActiveLabel.numberOfLines = 1;
        _lastActiveLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _lastActiveLabel.textColor = [UIColor lightGrayColor];
        [self.infoView addSubview:_lastActiveLabel];
    }
    
    return _lastActiveLabel;
}

- (UILabel *)logoutTimeLabel {
    if (!_logoutTimeLabel) {
        _logoutTimeLabel = [[UILabel alloc] init];
        _logoutTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _logoutTimeLabel.numberOfLines = 1;
        _logoutTimeLabel.textColor = [UIColor lightGrayColor];
        [self.infoView addSubview:_logoutTimeLabel];
    }
    return _logoutTimeLabel;
}

- (UILabel *)usedFlowLabel {
    if (!_usedFlowLabel) {
        _usedFlowLabel = [[UILabel alloc] init];
        _usedFlowLabel.numberOfLines = 1;
        _usedFlowLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [self.infoView addSubview:_usedFlowLabel];
    }
    return _usedFlowLabel;
}

- (UILabel *)lastActiveStatusLabel {
    if (!_lastActiveStatusLabel) {
        _lastActiveStatusLabel = [[UILabel alloc] init];
        _lastActiveStatusLabel.text = @"上线";
        [LYTool setBorder:_lastActiveStatusLabel color:[UIColor beautyOrange] cornerRadius:3];
        [_lastActiveStatusLabel.layer setCornerRadius:2];
//        [_lastActiveStatusLabel.layer setBorderWidth:0.8];
        _lastActiveStatusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _lastActiveStatusLabel.textColor = [UIColor beautyOrange];
        [self.contentView addSubview:_lastActiveStatusLabel];
    }
    return _lastActiveStatusLabel;
}

- (UILabel *)logoutTimeStatusLabel {
    if (!_logoutTimeStatusLabel) {
        _logoutTimeStatusLabel = [[UILabel alloc] init];
        _logoutTimeStatusLabel.text = @"下线";
        [LYTool setBorder:_logoutTimeStatusLabel color:[UIColor beautyBlue] cornerRadius:2];
        [_logoutTimeStatusLabel.layer setCornerRadius:2];
//        [_logoutTimeStatusLabel.layer setBorderWidth:0.8];
        _logoutTimeStatusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _logoutTimeStatusLabel.textColor = [UIColor beautyBlue];
        [self.contentView addSubview:_logoutTimeStatusLabel];
    }
    return _logoutTimeStatusLabel;
}

@end
