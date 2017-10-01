//
//  HomeComponentBaseView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeComponentBaseView.h"

@interface HomeComponentBaseView ()

@property (nonatomic, strong) UIView *bodyView;

@end

@implementation HomeComponentBaseView

- (instancetype)init {
    if (self = [super init]) {
        [self initBaseConstraints];
    }
    
    return self;
}

- (void)initBaseConstraints {
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(self).with.offset(16);
        make.right.equalTo(self).with.offset(-16);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTitleLabel.mas_bottom).with.offset(4);
        make.left.and.right.equalTo(self.subTitleLabel);
    }];
    
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.subTitleLabel);
        make.lastBaseline.equalTo(self.titleLabel);
    }];
    
    NSAssert(self.bodyView, @"body view is nil");
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(16);
        make.left.and.right.equalTo(self.subTitleLabel);
        make.bottom.equalTo(self.mas_bottom).with.offset(-24);
    }];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        [self addSubview:_subTitleLabel];
    }
    
    return _subTitleLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        [_actionButton setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
        [self addSubview:_actionButton];
    }
    
    return _actionButton;
}

- (UIView *)bodyView {
    return nil;
}

@end


