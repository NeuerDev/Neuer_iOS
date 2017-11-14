//
//  NetworkReuseFooterView.m
//  NEUer
//
//  Created by lanya on 2017/11/14.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkReuseFooterView.h"

@interface NetworkReuseFooterView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *footerLabel;

@end

@implementation NetworkReuseFooterView

- (instancetype)init {
    if (self = [super init]) {
        [self initConstrains];
    }
    return self;
}

- (void)initConstrains {
    [self.footerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)setAnimated:(BOOL)animated {
    if (animated) {
        [self.indicatorView startAnimating];
        self.footerLabel.text = @"";
    } else {
        [self.indicatorView stopAnimating];
        self.footerLabel.text = @"已经没有更多消息了~";
    }
}

#pragma mark - Getter
- (UILabel *)footerLabel {
    if (!_footerLabel) {
        _footerLabel = [[UILabel alloc] init];
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        _footerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _footerLabel.textColor = [UIColor lightGrayColor];
        
        [self addSubview:_footerLabel];
    }
    return _footerLabel;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        _indicatorView.transform = transform;
        
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

@end
