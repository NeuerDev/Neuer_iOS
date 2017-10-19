//
//  HomeComponentScheduleView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeComponentScheduleView.h"

@interface HomeComponentScheduleView ()
@property (nonatomic, strong) UIView *contentView;
@end

@implementation HomeComponentScheduleView

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        self.titleLabel.text = @"今日课程";
        [self.actionButton setTitle:@"完整课表" forState:UIControlStateNormal];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    
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
