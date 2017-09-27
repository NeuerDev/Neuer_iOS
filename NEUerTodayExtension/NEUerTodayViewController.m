//
//  TodayViewController.m
//  NEUGatewayExtension
//
//  Created by Jiahong Xu on 2017/9/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NEUerTodayViewController.h"
#import "GatewayModel.h"

#import "UIColor+JHCategory.h"

#import <NotificationCenter/NotificationCenter.h>
#import <Masonry/Masonry.h>

const NSInteger kPreferenceMinHeight = 110;
const NSInteger kPreferenceMaxHeight = 174;
NSString * const kPreferenceCompactBoolKey = @"kPreferenceCompactBoolKey";


#pragma mark - NEUTodayExtensionButton

@interface NEUTodayExtensionButton : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;
- (void)startAnimatingWithTitle:(NSString *)title;
- (void)stopAnimating;

@end

@implementation NEUTodayExtensionButton {
    UIImageView *_animateImageView;
    UILabel *_animateLabel;
    BOOL _animationShouldContinue;
}

#pragma mark - Init Methods

- (instancetype)init {
    return [self initWithImage:nil title:nil];
}


- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    if (self = [super init]) {
        self.imageView.image = image;
        self.titleLabel.text = title;
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(self);
            make.height.mas_equalTo(self.imageView.mas_width).multipliedBy(4.0f/5.0f);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.left.and.right.equalTo(self);
            make.top.equalTo(self.imageView.mas_bottom);
        }];
    }
    
    return self;
}


- (void)addTarget:(id)target action:(SEL)selector {
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:selector]];
}

#pragma mark - Public Methods

- (void)startAnimatingWithTitle:(NSString *)title {
    _imageView.userInteractionEnabled = NO;
    _animateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loader_large"]];
    _animateImageView.contentMode = UIViewContentModeCenter;
    _animateImageView.alpha = 0;
    
    _animateLabel = [[UILabel alloc] init];
    _animateLabel.textAlignment = NSTextAlignmentCenter;
    _animateLabel.textColor = [UIColor colorWithHexStr:@"#555555"];
    _animateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _animateLabel.alpha = 0;
    _animateLabel.text = title;
    
    _animationShouldContinue = YES;
    [self insertSubview:_animateImageView belowSubview:_imageView];
    [self insertSubview:_animateLabel belowSubview:_titleLabel];
    [_animateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imageView);
    }];
    [_animateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.titleLabel);
    }];
    
    [UIView animateWithDuration:1.0f/3.0f animations:^{
        _imageView.alpha = 0;
        _titleLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [self roateAnimating];
    }];
    
}


- (void)roateAnimating {
    if (_animationShouldContinue) {
        [UIView animateWithDuration:1.0f/3.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _animateImageView.alpha = 1;
            _animateLabel.alpha = 1;
            _animateImageView.transform = CGAffineTransformRotate(_animateImageView.transform, M_PI_2);
        } completion:^(BOOL finished) {
            [self roateAnimating];
        }];
    } else {
        [UIView animateWithDuration:1.0f/3.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _animateImageView.alpha = 0;
            _animateLabel.alpha = 0;
            _animateImageView.transform = CGAffineTransformRotate(_animateImageView.transform, M_PI_2);
        } completion:^(BOOL finished) {
            [_animateImageView removeFromSuperview];
            [_animateLabel removeFromSuperview];
            [UIView animateWithDuration:1.0f/6.0f animations:^{
                _imageView.alpha = 1;
                _titleLabel.alpha = 1;
            } completion:^(BOOL finished) {
                _imageView.userInteractionEnabled = YES;
            }];
        }];
    }
}


- (void)stopAnimating {
    _animationShouldContinue = NO;
}


#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexStr:@"#555555"];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageView];
    }
    
    return _imageView;
}

@end


#pragma mark - NEUTodayExtensionHeaderView

@interface NEUTodayExtensionMarqueeView : UIView

@property (nonatomic, strong) NSArray<NSAttributedString *> *titles;
@property (nonatomic, assign) BOOL infinited;
@property (nonatomic, assign) NSTimeInterval interval;

@property (nonatomic, strong) UILabel *headerLabel;

- (instancetype)initWithTitles:(NSArray<NSAttributedString *> *)titles interval:(NSTimeInterval)interval infinited:(BOOL)infinited;
- (void)start;
- (void)stop;

@end

@implementation NEUTodayExtensionMarqueeView {
    BOOL _shouldContinue;
}

#pragma mark - Init Methods

- (instancetype)initWithTitles:(NSArray<NSAttributedString *> *)titles interval:(NSTimeInterval)interval infinited:(BOOL)infinited {
    if (self = [super init]) {
        _titles = titles;
        _interval = interval;
        _infinited = infinited;

        _headerLabel = [[UILabel alloc] init];
        _headerLabel.numberOfLines = 0;
        _headerLabel.preferredMaxLayoutWidth = CGRectGetWidth([UIScreen mainScreen].bounds)-40;
        _headerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_headerLabel];
        
        [_headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    
    return self;
}


#pragma mark - Public Methods

- (void)start {
    _shouldContinue = YES;
    [self.layer removeAllAnimations];
    [self performAnimationWithTitleIndex:0];
}


- (void)stop {
    [self.layer removeAllAnimations];
}


- (void)performAnimationWithTitleIndex:(NSInteger)titleIndex {
    if (titleIndex<_titles.count) {
        NSAttributedString *title = _titles[titleIndex];
        self.headerLabel.attributedText = title;
        [UIView animateWithDuration:1.0f/3.0f animations:^{
            self.headerLabel.alpha = 1;
        } completion:^(BOOL finished) {
            if (titleIndex+1<_titles.count || _infinited) {
                [UIView animateWithDuration:1.0f/3.0f delay:_interval options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.headerLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    [self performAnimationWithTitleIndex:titleIndex+1];
                }];
            } else {
                [self performAnimationWithTitleIndex:titleIndex+1];
            }
        }];
    } else if (_infinited) {
        [self performAnimationWithTitleIndex:0];
    }
}

@end


#pragma mark - NEUerTodayViewController

@interface NEUerTodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) NEUTodayExtensionMarqueeView *headerView;

@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) NEUTodayExtensionButton *gatewayButton;
@property (nonatomic, strong) NEUTodayExtensionButton *dataButton;
@property (nonatomic, strong) NEUTodayExtensionButton *walletButton;
@property (nonatomic, strong) NEUTodayExtensionButton *libraryButton;
@property (nonatomic, strong) NEUTodayExtensionButton *scoreButton;

@property (nonatomic, strong) GatewayModel *gatewayModel;

@property (nonatomic, assign) BOOL isCompact;

@end

@implementation NEUerTodayViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef __IPHONE_10_0
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    _isCompact = self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact;
#endif
    
    [self initContraints];
    
    if (!_isCompact) {
        [self startUpdate];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    
}


- (void)viewDidAppear:(BOOL)animated {
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark - Init Methods

- (void)initContraints {
    
    if (_isCompact) {
        self.headerView.alpha = 0;
        
        [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(self.view);
            make.height.mas_equalTo(@(kPreferenceMinHeight));
        }];
    } else {
        self.headerView.alpha = 1;
        
        [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(self.view);
            make.height.mas_equalTo(@(kPreferenceMinHeight));
        }];
    }
    
    NSArray *buttonArray = @[self.gatewayButton,
                             self.dataButton,
                             self.libraryButton,
                             self.walletButton,
                             self.scoreButton];
    
    for (int index = 0; index < buttonArray.count; index++) {
        UIView *view = buttonArray[index];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.buttonView.mas_right).multipliedBy((float)(2*index+1)/(float)(buttonArray.count*2));
            make.width.mas_equalTo(self.buttonView.mas_width).multipliedBy(1.0f/(float)(buttonArray.count+1));
            make.centerY.equalTo(self.buttonView);
        }];
    }
    
    [self.gatewayButton layoutIfNeeded];
    CGFloat topOffset = (kPreferenceMinHeight - CGRectGetHeight(self.gatewayButton.frame))/3;
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).with.offset(topOffset);
        make.height.mas_equalTo(@(kPreferenceMaxHeight-kPreferenceMinHeight));
    }];
}

- (void)remakeContraints {
    if (_isCompact) {
        [UIView animateWithDuration:0.1 animations:^{
            self.headerView.alpha = 0;
        }];
        [self.buttonView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(self.view);
            make.height.mas_equalTo(@(kPreferenceMinHeight));
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.headerView.alpha = 1;
        }];
        [self.buttonView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(self.view);
            make.height.mas_equalTo(@(kPreferenceMinHeight));
        }];
    }
}

#pragma mark - Private Methods

- (void)startUpdate {
    NSMutableAttributedString *string0 = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] init];
    if (!self.gatewayModel.hasUser) {
        // 无用户信息
        [string0 appendAttributedString:
         [[NSAttributedString alloc] initWithString:@"我还不认识你 _(:з」∠)_ 先进入应用完善信息吧～"
                                         attributes:@{
                                                      NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                                      NSForegroundColorAttributeName:[UIColor colorWithHexStr:@"#555555"],
                                                      }]];
    } else {
        [string0 appendAttributedString:
         [[NSAttributedString alloc] initWithString:@"今天是您在东大的第 "
                                         attributes:@{
                                                      NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                                      NSForegroundColorAttributeName:[UIColor colorWithHexStr:@"#555555"],
                                                      }]];
        [string0 appendAttributedString:
         [[NSAttributedString alloc] initWithString:@"666"
                                         attributes:@{
                                                      NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle1],
                                                      NSForegroundColorAttributeName:[UIColor colorWithHexStr:@"#555555"],
                                                      }]];
        [string0 appendAttributedString:
         [[NSAttributedString alloc] initWithString:@" 天\n又是奋斗的一天～"
                                         attributes:@{
                                                      NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                                      NSForegroundColorAttributeName:[UIColor colorWithHexStr:@"#555555"],
                                                      }]];
    }
    [string1 appendAttributedString:
     [[NSAttributedString alloc] initWithString:@"「 行百里者半于九十 」"
                                     attributes:@{
                                                  NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2],
                                                  NSForegroundColorAttributeName:[UIColor colorWithHexStr:@"#555555"],
                                                  }]];
    
    
    self.headerView.titles = @[string0, string1];
    [self.headerView start];
}


#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}


#ifdef __IPHONE_10_0
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    _isCompact = activeDisplayMode==NCWidgetDisplayModeCompact;
    if (_isCompact) {
        self.preferredContentSize = CGSizeMake(maxSize.width, kPreferenceMinHeight);
    } else {
        [self startUpdate];
        self.preferredContentSize = CGSizeMake(maxSize.width, kPreferenceMaxHeight);
    }
    
    [self remakeContraints];
}
#endif


#pragma mark - Response Methods

- (void)authorGateway {
    [_gatewayButton startAnimatingWithTitle:NSLocalizedString(@"TodayExtensionGatewayTitleLoading", nil)];
    [_gatewayButton performSelector:@selector(stopAnimating) withObject:nil afterDelay:3];
}


- (void)queryDataLeft {
    [_dataButton startAnimatingWithTitle:NSLocalizedString(@"TodayExtensionDataLeftTitleLoading", nil)];
    [_dataButton performSelector:@selector(stopAnimating) withObject:nil afterDelay:3];
}


- (void)queryMoneyLeft {
    [_walletButton startAnimatingWithTitle:NSLocalizedString(@"TodayExtensionMoneyLeftTitleLoading", nil)];
    [_walletButton performSelector:@selector(stopAnimating) withObject:nil afterDelay:3];
}


- (void)queryLibraryBook {
    
}


- (void)queryScore {
    [_scoreButton startAnimatingWithTitle:NSLocalizedString(@"TodayExtensionQueryScoreTitleLoading", nil)];
    [_scoreButton performSelector:@selector(stopAnimating) withObject:nil afterDelay:3];
}

#pragma mark - Getter

- (GatewayModel *)gatewayModel {
    if (!_gatewayModel) {
        _gatewayModel = [[GatewayModel alloc] init];
        [_gatewayModel startMonitoring];
    }
    
    return _gatewayModel;
}


- (NEUTodayExtensionMarqueeView *)headerView {
    if (!_headerView) {
        _headerView = [[NEUTodayExtensionMarqueeView alloc] initWithTitles:@[] interval:3.0 infinited:NO];
        [self.view addSubview:_headerView];
    }
    
    return _headerView;
}


-  (UIView *)buttonView {
    if (!_buttonView) {
        _buttonView = [[UIView alloc] init];
        [self.view addSubview:_buttonView];
    }
    
    return _buttonView;
}


- (NEUTodayExtensionButton *)gatewayButton {
    if (!_gatewayButton) {
        _gatewayButton = [[NEUTodayExtensionButton alloc] initWithImage:[UIImage imageNamed:@"signal_large"] title:NSLocalizedString(@"TodayExtensionGatewayTitle", nil)];
        [_gatewayButton addTarget:self action:@selector(authorGateway)];
        [self.buttonView addSubview:_gatewayButton];
    }
    
    return _gatewayButton;
}


- (NEUTodayExtensionButton *)dataButton {
    if (!_dataButton) {
        _dataButton = [[NEUTodayExtensionButton alloc] initWithImage:[UIImage imageNamed:@"drop_large"] title:NSLocalizedString(@"TodayExtensionDataLeftTitle", nil)];
        [_dataButton addTarget:self action:@selector(queryDataLeft)];
        [self.buttonView addSubview:_dataButton];
    }
    
    return _dataButton;
}


- (NEUTodayExtensionButton *)walletButton {
    if (!_walletButton) {
        _walletButton = [[NEUTodayExtensionButton alloc] initWithImage:[UIImage imageNamed:@"wallet_large"] title:NSLocalizedString(@"TodayExtensionMoneyLeftTitle", nil)];
        [_walletButton addTarget:self action:@selector(queryMoneyLeft)];
        [self.buttonView addSubview:_walletButton];
    }
    
    return _walletButton;
}


- (NEUTodayExtensionButton *)libraryButton {
    if (!_libraryButton) {
        _libraryButton = [[NEUTodayExtensionButton alloc] initWithImage:[UIImage imageNamed:@"search_large"] title:NSLocalizedString(@"TodayExtensionFindBookTitle", nil)];
        [self.buttonView addSubview:_libraryButton];
    }
    
    return _libraryButton;
}


- (NEUTodayExtensionButton *)scoreButton {
    if (!_scoreButton) {
        _scoreButton = [[NEUTodayExtensionButton alloc] initWithImage:[UIImage imageNamed:@"paper_large"] title:NSLocalizedString(@"TodayExtensionQueryScoreTitle", nil)];
        [_scoreButton addTarget:self action:@selector(queryScore)];
        [self.buttonView addSubview:_scoreButton];
    }
    
    return _scoreButton;
}

@end
