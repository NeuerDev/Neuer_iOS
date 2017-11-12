//
//  NetworkOnlineDevicesTableViewCell.m
//  NEUer
//
//  Created by lanya on 2017/11/5.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkOnlineDevicesTableViewCell.h"

@implementation NetworkOnlineDevicesTableViewCell
{
    NetworkOnlineDevicesTableViewCellSetActionBlock _actionBlock;
}

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
    
    [self.lastActiveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceLabel.mas_bottom).with.offset(4);
        make.left.and.bottom.equalTo(self.infoView);
    }];
    
    [self.offLineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.and.right.equalTo(self.infoView);
    }];
}

#pragma mark - Response Method
- (void)didClickedOffLineButton {
    if (_actionBlock) {
        _actionBlock(_onlineInfoBean.online_ID.integerValue);
    }
}

- (void)setOnlineDevicesActionBlock:(NetworkOnlineDevicesTableViewCellSetActionBlock)block {
    _actionBlock = block;
}

#pragma mark - Setter

- (void)setOnlineInfoBean:(GatewaySelfServiceMenuOnlineInfoBean *)onlineInfoBean {
    _onlineInfoBean = onlineInfoBean;
    _deviceLabel.text = _onlineInfoBean.online_operation;
    _lastActiveLabel.text = _onlineInfoBean.online_lastactive;
    
    NSString *operation = _onlineInfoBean.online_operation;
    if ([operation isEqualToString:@"iPhone"] || [operation isEqualToString:@"Android"] || [operation isEqualToString:@"iPad"]) {
        _iconImageView.image = [UIImage imageNamed:@"network_phone"];
    } else {
        _iconImageView.image = [UIImage imageNamed:@"network_computer"];
    }
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

- (UIButton *)offLineButton {
    if (!_offLineButton) {
        _offLineButton = [[UIButton alloc] init];
        [_offLineButton setTitle:@"下线" forState:UIControlStateNormal];
        [_offLineButton addTarget:self action:@selector(didClickedOffLineButton) forControlEvents:UIControlEventTouchUpInside];
        [_offLineButton setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
        _offLineButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _offLineButton.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
        _offLineButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _offLineButton.layer.cornerRadius = 30.0f/2;
        _offLineButton.alpha = 0.8;
        _offLineButton.layer.borderColor = [UIColor beautyBlue].CGColor;
        _offLineButton.backgroundColor = [UIColor groupTableViewBackgroundColor];

        [self.infoView addSubview:_offLineButton];
    }
    
    return _offLineButton;
}

@end
