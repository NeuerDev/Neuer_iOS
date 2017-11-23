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
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(28);
        make.left.equalTo(self.mas_left).with.offset(16);
        make.right.equalTo(self.mas_right).with.offset(-16);
    }];
    
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-16);
        make.lastBaseline.equalTo(self.titleLabel);
    }];
    
    NSAssert(self.bodyView, @"body view is nil");
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(16);
        make.left.and.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
    }];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.dk_textColorPicker = DKColorPickerWithKey(title);
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        _actionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        DKThemeVersion *themeVersion = [DKNightVersionManager sharedManager].themeVersion;
        [_actionButton setTitleColor:DKColorPickerWithKey(accent)(themeVersion) forState:UIControlStateNormal];
        [self addSubview:_actionButton];
    }
    
    return _actionButton;
}

- (UIView *)bodyView {
    return nil;
}

@end


