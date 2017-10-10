//
//  JHToastView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkStatusView.h"

@implementation NetworkStatusView

- (instancetype)init {
    if (self = [super init]) {
        [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.mas_left).with.offset(16);
            make.height.and.width.mas_equalTo(@32);
        }];
        
        [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self.mas_right).with.offset(-16);
        }];
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.top.and.bottom.equalTo(self);
            make.left.equalTo(self.imageView.mas_right).with.offset(8);
            make.right.equalTo(self.dismissButton.mas_left).with.offset(-8);
        }];
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 16.0f;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowOpacity = 0.7;
    }
    
    return self;
}

#pragma mark - Getter

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = [UIColor colorWithHexStr:@"#555555"];
        _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self addSubview:_textLabel];
    }
    
    return _textLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    
    return _imageView;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        _effectView.layer.cornerRadius = 16.0f;
        _effectView.layer.masksToBounds = YES;
        [self addSubview:_effectView];
    }
    
    return _effectView;
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [[UIButton alloc] init];
        _dismissButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        [_dismissButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self addSubview:_dismissButton];
    }
    
    return _dismissButton;
}

@end
