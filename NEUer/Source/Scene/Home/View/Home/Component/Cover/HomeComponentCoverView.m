//
//  HomeComponentCoverView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeComponentCoverView.h"

@interface HomeComponentCoverView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *coverImageView;
@end

@implementation HomeComponentCoverView

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        self.titleLabel.text = @"在东大的678天";
        [self.actionButton setTitle:@"往期作品" forState:UIControlStateNormal];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(0, 16, 0, 16));
        make.height.equalTo(self.coverImageView.mas_width).multipliedBy(10.0f/16.0f);
    }];
}

#pragma mark - Getter

- (UIView *)bodyView {
    return self.contentView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        
        _contentView.layer.shadowOffset = CGSizeMake(0, 4);
        _contentView.layer.shadowOpacity = 0.8;
        _contentView.layer.shadowRadius = 4;
        
        [self addSubview:_contentView];
    }
    
    return _contentView;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home"]];
        _coverImageView.layer.cornerRadius = 16.0f;
        _coverImageView.layer.masksToBounds = YES;
        self.contentView.layer.shadowColor = _coverImageView.image.mainColor.CGColor;
        [self.contentView addSubview:_coverImageView];
    }
    
    return _coverImageView;
}

@end
