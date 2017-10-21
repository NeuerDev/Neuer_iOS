//
//  HomeComponentNewsView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeComponentNewsView.h"

@interface HomeComponentNewsView ()
@property (nonatomic, strong) UIView *contentView;
@end

@implementation HomeComponentNewsView

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        self.titleLabel.text = @"东大新闻";
        [self.actionButton setTitle:@"更多" forState:UIControlStateNormal];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(200));
    }];
}

#pragma mark - Getter

- (UIView *)bodyView {
    return self.contentView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        
        [self addSubview:_contentView];
    }
    
    return _contentView;
}

@end

