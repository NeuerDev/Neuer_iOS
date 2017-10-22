//
//  JHToastView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkStatusView.h"

static NetworkStatusView *_networkStateView;
const CGFloat kNetworkViewHeight = 80.0f;

@interface NetworkStatusView ()

@property (nonatomic, weak) UIView *parentView;

@end

@implementation NetworkStatusView {
    CGFloat _originY;
    CGFloat _viewBeginY;
    CGFloat _touchBeginY;
}

+ (instancetype)sharedNetworkStatusView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        _networkStateView = [[NetworkStatusView alloc] init];
        [window addSubview:_networkStateView];
        _networkStateView.parentView = window;
        _networkStateView.frame = CGRectMake(
                                       CGRectGetMinX(window.bounds) + 16,
                                       CGRectGetMaxY(window.bounds),
                                       CGRectGetWidth(window.bounds) - 32,
                                       kNetworkViewHeight
                                       );
        
        _networkStateView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_networkStateView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(16, 16)].CGPath;
    });
    
    return _networkStateView;
}

#pragma mark - Init Methods

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
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.top.and.bottom.equalTo(self);
            make.left.equalTo(self.imageView.mas_right).with.offset(16);
            make.right.equalTo(self.mas_right).with.offset(-16);
        }];
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 16.0f;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowOpacity = 0.7;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    _touchBeginY = [[touches anyObject] locationInView:self.superview].y;
    _viewBeginY = CGRectGetMinY(self.frame);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGFloat currentY = [[touches anyObject] locationInView:self.superview].y;
    CGFloat offset = _touchBeginY - currentY;
    self.frame = ({
        CGRect frame = self.frame;
        CGPoint origin = self.frame.origin;
        if (origin.y > _originY) {
            origin.y = _viewBeginY - offset;
        } else {
            origin.y = _viewBeginY - offset*pow(0.85, (offset+CGRectGetHeight(self.frame))/CGRectGetHeight(self.frame));
        }
        frame.origin = origin;
        frame;
    });
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:4.0f];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    CGFloat currentY = CGRectGetMinY(self.frame);
    if (currentY > _originY+CGRectGetHeight(self.frame)/2) {
        [_parentView bringSubviewToFront:self];
        [self.layer removeAllAnimations];
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(
                                    CGRectGetMinX(_parentView.frame) + 16,
                                    CGRectGetMaxY(_parentView.frame),
                                    CGRectGetWidth(_parentView.frame) - 32,
                                    kNetworkViewHeight
                                    );
        } completion:nil];
    } else {
        [self show];
    }
}

#pragma mark - Public Methods

- (void)show {
    _originY = CGRectGetMaxY(_parentView.frame) - kNetworkViewHeight - 16;
    [_parentView bringSubviewToFront:self];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:4.0f];
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(
                                        CGRectGetMinX(_parentView.frame) + 16,
                                        _originY,
                                        CGRectGetWidth(_parentView.frame) - 32,
                                        kNetworkViewHeight
                                        );
    } completion:^(BOOL finished) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:4.0f];
    }];
}

- (void)dismiss {
    [_parentView bringSubviewToFront:self];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = CGRectMake(
                                        CGRectGetMinX(_parentView.frame) + 16,
                                        CGRectGetMaxY(_parentView.frame),
                                        CGRectGetWidth(_parentView.frame) - 32,
                                        kNetworkViewHeight
                                        );
    } completion:nil];
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

@end
