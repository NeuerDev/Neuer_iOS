//
//  JHBaseViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHBaseViewController.h"

@interface JHBaseViewController ()
@property (nonatomic, strong) UIImageView *baseImageView;
@property (nonatomic, strong) UIView *basePlaceholderView;
@end

@implementation JHBaseViewController

#pragma mark - Init Methods

- (instancetype)initWithUrl:(NSURL *)url params:(NSDictionary *)params {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)handleUrl:(NSURL *)url params:(NSDictionary *)params {
    
}

- (void)initData {
    
}

- (void)initConstraints {
    
}

- (void)initBaseConstraints {
    [self.baseContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.basePlaceholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.baseContentView).with.insets(UIEdgeInsetsMake(64, 0, 0, 0));
    }];
    
    [self.baseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.basePlaceholderView);
        make.width.and.height.mas_equalTo(@(CGRectGetWidth(UIScreen.mainScreen.bounds)));
    }];
    
    [self.baseStateTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.baseImageView.mas_bottom);
        make.left.and.right.equalTo(self.basePlaceholderView);
    }];
    
    [self.baseStateDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.baseStateTitleLabel.mas_bottom).with.offset(16);
        make.centerX.equalTo(self.basePlaceholderView);
        make.width.equalTo(self.basePlaceholderView).multipliedBy(3.0f/4.0f);
    }];
    
    [self.baseRetryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.baseStateDetailLabel.mas_bottom).with.offset(32);
        make.height.mas_equalTo(@44);
        make.width.mas_equalTo(@90);
        make.centerX.equalTo(self.basePlaceholderView);
        make.bottom.equalTo(self.basePlaceholderView.mas_bottom);
    }];
    
    [self.navigationBarBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideTop);
    }];
}


#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
    [self initBaseConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Override Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[DKNightVersionManager sharedManager].themeVersion isEqualToString:@"NIGHT"] ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

#pragma mark - Public Methods

- (void)showPlaceHolder {
    [self.view bringSubviewToFront:self.baseContentView];
    self.baseContentView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.baseContentView.alpha = 1;
    }];
}

- (void)hidePlaceHolder {
    [self.view bringSubviewToFront:self.baseContentView];
    [UIView animateWithDuration:0.3 animations:^{
        self.baseContentView.alpha = 0;
    } completion:^(BOOL finished) {
        self.baseContentView.hidden = YES;
    }];
}

#pragma mark - Respond Methods

- (void)onBaseRetryButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setter

- (void)setBaseViewState:(JHBaseViewState)baseViewState {
    _baseViewState = baseViewState;
    switch (baseViewState) {
        case JHBaseViewStateNormal:
        {
            [self hidePlaceHolder];
        }
            break;
        case JHBaseViewStateRemainsToDo:
        {
            self.baseImageView.image = [UIImage imageNamed:@"base_placeholder_empty"];
            self.baseStateTitleLabel.text = NSLocalizedString(@"JHBaseViewControllerRemainsToDoTitle", nil);
            self.baseStateDetailLabel.text = NSLocalizedString(@"JHBaseViewControllerRemainsToDoDetail", nil);
            [self.baseRetryButton setTitle:NSLocalizedString(@"JHBaseViewControllerBack", nil) forState:UIControlStateNormal];
            [self showPlaceHolder];
        }
            break;
        case JHBaseViewStateEmptyContent:
        {
            self.baseImageView.image = [UIImage imageNamed:@"base_placeholder_empty"];
            [self showPlaceHolder];
        }
            break;
        case JHBaseViewStateLoadingContent:
        {
            self.baseImageView.image = [UIImage imageNamed:@"base_placeholder_empty"];
            [self showPlaceHolder];
        }
            break;
        case JHBaseViewStateConnectionLost:
        {
            self.baseImageView.image = [UIImage imageNamed:@"base_placeholder_empty"];
            [self.baseRetryButton setTitle:NSLocalizedString(@"JHBaseViewControllerRetry", nil) forState:UIControlStateNormal];
            [self showPlaceHolder];
        }
            break;
        case JHBaseViewStateNetworkUnavailable:
        {
            self.baseImageView.image = [UIImage imageNamed:@"base_placeholder_empty"];
            [self.baseRetryButton setTitle:NSLocalizedString(@"JHBaseViewControllerRetry", nil) forState:UIControlStateNormal];
            [self showPlaceHolder];
        }
            break;
        case JHBaseViewStateRequireCameraAccess:
        {
            self.baseImageView.image = [UIImage imageNamed:@"base_placeholder_camera"];
            [self.baseRetryButton setTitle:NSLocalizedString(@"JHBaseViewControllerEnable", nil) forState:UIControlStateNormal];
            self.baseStateTitleLabel.text = NSLocalizedString(@"JHBaseViewControllerRequireCameraAccessTitle", nil);
            self.baseStateDetailLabel.text = NSLocalizedString(@"JHBaseViewControllerRequireCameraAccessDetail", nil);
            [self showPlaceHolder];
        }
            break;
        case JHBaseViewStateRequireLocationAccess:
        {
            self.baseImageView.image = [UIImage imageNamed:@"base_placeholder_location"];
            [self.baseRetryButton setTitle:NSLocalizedString(@"JHBaseViewControllerEnable", nil) forState:UIControlStateNormal];
            self.baseStateTitleLabel.text = NSLocalizedString(@"JHBaseViewControllerRequireLocationAccessTitle", nil);
            self.baseStateDetailLabel.text = NSLocalizedString(@"JHBaseViewControllerRequireLocationAccessDetail", nil);
            [self showPlaceHolder];
        }
            break;
        case JHBaseViewStateError:
        {
            self.baseImageView.image = [UIImage imageNamed:@"base_placeholder_error1"];
            [self.baseRetryButton setTitle:NSLocalizedString(@"JHBaseViewControllerBack", nil) forState:UIControlStateNormal];
            [self showPlaceHolder];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Getter

- (UIView *)baseContentView {
    if (!_baseContentView) {
        _baseContentView = [[UIView alloc] init];
        _baseContentView.hidden = YES;
        _baseContentView.alpha = 0;
        //        _baseContentView.backgroundColor = [UIColor colorWithHexStr:@"#EFF1F3"];
        [self.view addSubview:_baseContentView];
    }
    return _baseContentView;
}

- (UIView *)basePlaceholderView {
    if (!_basePlaceholderView) {
        _basePlaceholderView = [[UIView alloc] init];
        [self.baseContentView addSubview:_basePlaceholderView];
    }
    return _basePlaceholderView;
}

- (UIImageView *)baseImageView {
    if (!_baseImageView) {
        _baseImageView = [[UIImageView alloc] init];
        [self.basePlaceholderView addSubview:_baseImageView];
    }
    
    return _baseImageView;
}

- (UILabel *)baseStateTitleLabel {
    if (!_baseStateTitleLabel) {
        _baseStateTitleLabel = [[UILabel alloc] init];
        _baseStateTitleLabel.textAlignment = NSTextAlignmentCenter;
        _baseStateTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        _baseStateTitleLabel.dk_textColorPicker = DKColorPickerWithKey(title);
        [self.basePlaceholderView addSubview:_baseStateTitleLabel];
    }
    return _baseStateTitleLabel;
}

- (UILabel *)baseStateDetailLabel {
    if (!_baseStateDetailLabel) {
        _baseStateDetailLabel = [[UILabel alloc] init];
        _baseStateDetailLabel.numberOfLines = 0;
        _baseStateDetailLabel.textAlignment = NSTextAlignmentCenter;
        _baseStateDetailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _baseStateDetailLabel.dk_textColorPicker = DKColorPickerWithKey(subtitle);
        [self.basePlaceholderView addSubview:_baseStateDetailLabel];
    }
    return _baseStateDetailLabel;
}

- (UIButton *)baseRetryButton {
    if (!_baseRetryButton) {
        _baseRetryButton = [[UIButton alloc] init];
        _baseRetryButton.dk_backgroundColorPicker = DKColorPickerWithKey(accent);
        _baseRetryButton.titleLabel.dk_textColorPicker = DKColorPickerWithKey(accenttext);
        _baseRetryButton.layer.cornerRadius = 22;
        _baseRetryButton.layer.dk_shadowColorPicker = DKColorPickerWithKey(accent);
        _baseRetryButton.layer.shadowOffset = CGSizeMake(0, 2);
        _baseRetryButton.layer.shadowRadius = 4;
        _baseRetryButton.layer.shadowOpacity = 0.5;
        [_baseRetryButton setTitleColor:DKColorPickerWithKey(accenttext)(DKNightVersionManager.sharedManager.themeVersion) forState:UIControlStateNormal];
        [_baseRetryButton addTarget:self action:@selector(onBaseRetryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.basePlaceholderView addSubview:_baseRetryButton];
    }
    
    return _baseRetryButton;
}

- (UIActivityIndicatorView *)baseActivityIndicatorView {
    if (!_baseActivityIndicatorView) {
        _baseActivityIndicatorView = [[UIActivityIndicatorView alloc] init];
        _baseActivityIndicatorView.hidden = YES;
        [self.view addSubview:_baseActivityIndicatorView];
    }
    return _baseActivityIndicatorView;
}

- (UIView *)navigationBarBackgroundView {
    if (!_navigationBarBackgroundView) {
        _navigationBarBackgroundView = [[UIView alloc] init];
        _navigationBarBackgroundView.dk_backgroundColorPicker = DKColorPickerWithKey(background);
        [self.view addSubview:_navigationBarBackgroundView];
    }
    
    return _navigationBarBackgroundView;
}

@end
