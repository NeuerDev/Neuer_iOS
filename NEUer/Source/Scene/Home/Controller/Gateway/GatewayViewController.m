//
//  GatewayViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewayViewController.h"
#import "LoginViewController.h"
#import "UIColor+JHCategory.h"
#import "GatewayComponentInfoView.h"
#import "LYTool.h"
#import "MBProgressHUD.h"

@interface GatewayViewController () <GatewayModelDelegate>
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *quitBtn;
@property (nonatomic, strong) UIButton *logoutBtn;
@property (nonatomic, strong) UILabel *gatewayStatusLb;
@property (nonatomic, strong) GatewayComponentInfoView *infoView;

@property (nonatomic, strong) GatewayCenter *center;

@property (nonatomic, strong) GatewayModel *model;
@property (nonatomic, strong) GatewayBean *gatewayBean;

@end

@implementation GatewayViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self initData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initConstraints];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - Init Method
- (void)initData {
    
    if ([self.model hasUser]) {
        [self.model fetchGatewayData];
    }
    _center = [GatewayCenter defaultCenter];
    [self initNetworkStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGatewayNetworkStatusChangeNotification:) name:kGatewayNetworkStatusChangeNotification object:nil];
    
}

- (void)initNetworkStatus {
    //    首先判断校园网状态
    NSString *alertMessage = nil;
    if (self.center.networkEnable) {
        switch (_center.campusStatus) {
            case GatewayStatusYES:
            {
                if (_center.reachableStatus == GatewayStatusYES) {
                    alertMessage = @"正在使用校园网 Wi-Fi\n可访问外网";
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loginBtn setTitle:@"切换校园网账号" forState:UIControlStateNormal];
                        self.loginBtn.enabled = YES;
                    });
                } else if (_center.reachableStatus == GatewayStatusNO) {
                    alertMessage = @"已连接校园网 Wi-Fi\n点击登录网关";
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loginBtn setTitle:@"点击登录网关" forState:UIControlStateNormal];
                        self.loginBtn.enabled = YES;
                    });
                }
            }
                break;
            case GatewayStatusNO:
            {
                // 不在校园网环境
                if (_center.reachableStatus == GatewayStatusYES) {
                    if (_center.wifiStatus == GatewayStatusYES) {
                        // Wi-Fi
                        alertMessage = @"正在使用非校内 Wi-Fi\n校园卡等服务无法使用";
                        [self setLoginAndLogoutBtnHidden];
                    } else if (_center.wifiStatus == GatewayStatusNO) {
                        // 蜂窝数据
                        alertMessage = @"正在使用 蜂窝数据\n校园卡等服务无法使用";
                        [self setLoginAndLogoutBtnHidden];
                    }
                } else if (_center.reachableStatus == GatewayStatusNO) {
                    alertMessage = @"连接以太网超时(10s)";
                    [self setLoginAndLogoutBtnHidden];
                } else {
                    NSLog(@"网络状态未知");
                }
                
            }
                break;
            case GatewayStatusUnknown:
            {
                if (_center.wifiStatus == GatewayStatusYES) {
                    // Wi-Fi
                    alertMessage = @"正在使用 Wi-Fi";
                    [self setLoginAndLogoutBtnHidden];
                } else if (_center.wifiStatus == GatewayStatusNO) {
                    // 蜂窝数据
                    alertMessage = @"正在使用 蜂窝数据\n校园卡等服务无法使用";
                    [self setLoginAndLogoutBtnHidden];
                } else {
                    NSLog(@"网络状态未知");
                    [self setLoginAndLogoutBtnHidden];
                }
            }
                break;
            default:
                break;
        }
    } else {
        alertMessage = @"网络已断开";
        [self setLoginAndLogoutBtnHidden];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.gatewayStatusLb.text = alertMessage;
        CGSize size = [LYTool sizeWithString:_gatewayStatusLb.text font:_gatewayStatusLb.font];
        _gatewayStatusLb.bounds = CGRectMake(0, 0, size.width, size.height);
        
        CGSize loginBtnSize = [LYTool sizeWithString:_loginBtn.titleLabel.text font:_loginBtn.titleLabel.font];
        self.loginBtn.bounds = CGRectMake(0, 0, loginBtnSize.width, loginBtnSize.height);
        [self initConstraints];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    });
}

- (void)initConstraints {
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.mas_equalTo(self.blurView).with.offset(30);
        make.height.and.width.mas_equalTo(25);
    }];
    
    [self.gatewayStatusLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.quitBtn).with.offset(100);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.blurView);
        make.top.equalTo(self.gatewayStatusLb.mas_bottom).with.offset(30);
        make.bottom.equalTo(self.blurView.mas_bottom);
    }];
    
    if (_center.networkEnable == YES && _center.reachableStatus == YES) {
        [self.infoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.view).multipliedBy(0.3);
            make.width.equalTo(self.view);
            make.centerX.equalTo(self.gatewayStatusLb);
            make.top.equalTo(self.cardView);
        }];
        
        [self.loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.gatewayStatusLb);
            make.top.equalTo(self.infoView.mas_bottom).with.offset(40);
        }];
        
        [self.logoutBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.gatewayStatusLb);
            make.top.equalTo(self.loginBtn.mas_bottom).with.offset(20);
        }];
    } else if (_center.networkEnable == YES && _center.reachableStatus == NO) {
        
        [self.loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.gatewayStatusLb);
            make.top.equalTo(self.infoView.mas_bottom).with.offset(40);
        }];
    } else {
        
    }
    
}


#pragma mark - Private Method

- (void)setLoginAndLogoutBtnHidden {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginBtn setTitle:@"" forState:UIControlStateNormal];
        self.loginBtn.enabled = NO;
        [self.logoutBtn setTitle:@"" forState:UIControlStateNormal];
        self.logoutBtn.enabled = NO;
    });
}

#pragma mark - Notification
- (void)didGatewayNetworkStatusChangeNotification:(NSNotification *)notification {
    [self initNetworkStatus];
}

#pragma mark - GatewayModel delegate
- (void)fetchGatewayDataFailureWithMsg:(NSString *)msg {
//    在这个方法中处理登录失败信息
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:3 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            若登录信息失败，并且连接了网关，则显示登录按钮，隐藏退出按钮
            if (_center.campusStatus == YES && _center.reachableStatus == NO) {
                [self.loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.gatewayStatusLb);
                    make.top.equalTo(self.infoView.mas_bottom).with.offset(40);
                }];
                //  通知不会及时更新文字，手动更新loginBtn的文字
                self.loginBtn.titleLabel.text = @"点击登录网关";
                self.loginBtn.enabled = YES;
                [_logoutBtn setTitle:@"" forState:UIControlStateNormal];
                _logoutBtn.enabled = NO;
            } else {
//                若未连接校园网WiFi，则登录和退出按钮都不显示
                [self setLoginAndLogoutBtnHidden];
            }
        } completion:nil];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    });
}

- (void)fetchGatewayDataSuccess {
//    在这个方法中处理登录成功信息
    if ([self.model gatewayInfo]) {
        _gatewayBean = [self.model gatewayInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:4 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.infoView setUpWithGatewayBean:self.gatewayBean];

                [self.infoView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(self.view).multipliedBy(0.3);
                    make.width.equalTo(self.view);
                    make.centerX.equalTo(self.gatewayStatusLb);
                    make.top.equalTo(self.cardView);
                }];
                [self.loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.gatewayStatusLb);
                    make.top.equalTo(self.infoView.mas_bottom).with.offset(40);
                }];
                
//                通知不会及时更新文字，手动更新gatewayStatusLb和loginBtn的文字
                self.gatewayStatusLb.text = @"正在使用校园网 Wi-Fi\n可访问外网";
                self.loginBtn.titleLabel.text = @"切换校园网账号";
                self.loginBtn.enabled = YES;
                CGSize loginBtnSize = [LYTool sizeWithString:_loginBtn.titleLabel.text font:_loginBtn.titleLabel.font];
                self.loginBtn.bounds = CGRectMake(0, 0, loginBtnSize.width, loginBtnSize.height);
                [_logoutBtn setTitle:@"点此退出校园网" forState:UIControlStateNormal];
                _logoutBtn.enabled = YES;
                [self.logoutBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.gatewayStatusLb);
                    make.top.equalTo(self.loginBtn.mas_bottom).with.offset(20);
                }];
            } completion:nil];
        });
    } else {
        NSLog(@"赋值失败");
    }
}

- (void)didGatewayLogoutSuccess:(BOOL)isLogout {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (isLogout) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"退出校园网成功！" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.gatewayStatusLb setText:@"已退出校园网 Wi-Fi\n点击登录网关"];
            [_logoutBtn setTitle:@"" forState:UIControlStateNormal];
            _logoutBtn.enabled = NO;
        });
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您似乎未曾连接校园网！" preferredStyle:UIAlertControllerStyleAlert];
        alertController.view.alpha = 0.8;
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_logoutBtn setTitle:@"" forState:UIControlStateNormal];
            _logoutBtn.enabled = NO;
            CGSize size = [LYTool sizeWithString:_logoutBtn.titleLabel.text font:_logoutBtn.titleLabel.font];
            _logoutBtn.bounds = CGRectMake(0, 0, size.width, size.height);
            [self.view layoutIfNeeded];
        });
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - ResponseMethod
- (void)quitGatewayViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentNoVerificationCodeVC {
    LoginViewController *loginVC2 = [LoginViewController shareLoginViewController];
    [loginVC2 setUpWithLoginInfoViewType:LoginComponentInfoViewTypeDefault withLoginVerificationCodeImg:nil];
    [self presentViewController:loginVC2 animated:YES completion:nil];
}

- (void)didLogoutBtnClicked {
    [self.model quitTheGateway];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [UIView animateWithDuration:0.3 animations:^{
        //        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }];
}

#pragma mark - Getter

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];

        [self.view addSubview:_blurView];
    }

    return _blurView;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [UIColor clearColor];
        [self.blurView.contentView addSubview:_cardView];
    }
    return _cardView;
}

- (UIButton *)quitBtn {
    if (!_quitBtn) {
        _quitBtn = [[UIButton alloc] init];
        [_quitBtn setBackgroundImage:[UIImage imageNamed:@"quit"] forState:UIControlStateNormal];
        [_quitBtn addTarget:self action:@selector(quitGatewayViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.blurView.contentView addSubview:_quitBtn];
    }
    return _quitBtn;
}

- (GatewayModel *)model {
    if (!_model) {
        _model = [[GatewayModel alloc] init];
        _model.delegate = self;
    }
    return _model;
}

- (GatewayBean *)gatewayBean {
    if (!_gatewayBean) {
        _gatewayBean = [[GatewayBean alloc] init];
    }
    return _gatewayBean;
}

- (UILabel *)gatewayStatusLb {
    if (!_gatewayStatusLb) {
        _gatewayStatusLb = [[UILabel alloc] init];
        _gatewayStatusLb.textColor = [UIColor grayColor];
        _gatewayStatusLb.textAlignment = NSTextAlignmentCenter;
        _gatewayStatusLb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        _gatewayStatusLb.numberOfLines = 0;
        [self.blurView.contentView addSubview:_gatewayStatusLb];
    }
    return _gatewayStatusLb;
}

- (GatewayComponentInfoView *)infoView {
    if (!_infoView) {
        _infoView = [[GatewayComponentInfoView alloc] init];
        [self.cardView addSubview:_infoView];
    }
    
    return _infoView;
}

- (UIButton *)logoutBtn {
    if (!_logoutBtn) {
        _logoutBtn = [[UIButton alloc] init];
        [_logoutBtn setTitle:@"点此退出校园网" forState:UIControlStateNormal];
        _logoutBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        CGSize size = [LYTool sizeWithString:_logoutBtn.titleLabel.text font:_logoutBtn.titleLabel.font];
        _logoutBtn.bounds = CGRectMake(0, 0, size.width, size.height);
        [_logoutBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        [_logoutBtn addTarget:self action:@selector(didLogoutBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.cardView addSubview:_logoutBtn];
    }
    return _logoutBtn;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] init];
        [_loginBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        
        [_loginBtn addTarget:self action:@selector(presentNoVerificationCodeVC) forControlEvents:UIControlEventTouchUpInside];
        [self.cardView addSubview:_loginBtn];
    }
    return _loginBtn;
}

@end
