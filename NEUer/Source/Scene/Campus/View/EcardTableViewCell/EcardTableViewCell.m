//
//  EcardTableViewCell.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/19.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardTableViewCell.h"

@implementation EcardTableViewCell

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
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(self.infoView);
    }];
    
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(4);
        make.left.and.bottom.equalTo(self.infoView);
    }];
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.centerY.equalTo(self.infoView);
    }];
}

#pragma mark - Setter

- (void)setConsumeBean:(EcardConsumeBean *)consumeBean {
    _consumeBean = consumeBean;
    _titleLabel.text = consumeBean.title;
    _descriptionLabel.text = consumeBean.desc;
    _moneyLabel.text = [NSString stringWithFormat:@"%.2f", consumeBean.cost.floatValue];
    
    _iconImageView.image = [UIImage imageNamed:@[@"", @"ecard_bath", @"ecard_food"][consumeBean.consumeType]];
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

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.infoView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.numberOfLines = 1;
        _descriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _descriptionLabel.textColor = [UIColor lightGrayColor];
        [self.infoView addSubview:_descriptionLabel];
    }
    
    return _descriptionLabel;
}

- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [self.infoView addSubview:_moneyLabel];
    }
    
    return _moneyLabel;
}

@end
