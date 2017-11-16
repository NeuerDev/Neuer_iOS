//
//  CustomSectionHeaderFooterView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "CustomSectionHeaderFooterView.h"

@implementation CustomSectionHeaderFooterView

#pragma mark - Init Methods

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-4);
    }];
    
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.left.equalTo(self.titleLabel.mas_right);
    }];
    
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.lastBaseline.equalTo(self.titleLabel.mas_lastBaseline);
    }];
}

#pragma mark - Public Methods

- (void)startAnimating {
    [UIView animateWithDuration:0.1 animations:^{
        self.indicatorView.alpha = 1;
    }];
    [self.indicatorView startAnimating];
}

- (void)stopAnimating {
    [UIView animateWithDuration:0.1 animations:^{
        self.indicatorView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.indicatorView startAnimating];
    }];
}

#pragma mark - Respond Methods

- (void)didClickedActionButton {
    if (_performActionBlock) {
        _performActionBlock(_section);
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        _actionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        [_actionButton setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(didClickedActionButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_actionButton];
    }
    
    return _actionButton;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.alpha = 0;
        [self.contentView addSubview:_indicatorView];
    }
    
    return _indicatorView;
}

#pragma mark - Setter

- (void)setPerformActionBlock:(CustomSectionHeaderFooterPerformActionBlock)performActionBlock {
    _performActionBlock = performActionBlock;
}

@end
