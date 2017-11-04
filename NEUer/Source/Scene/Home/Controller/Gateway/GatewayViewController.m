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
#import "LYTool.h"

#import "GatewayComponentInfoView.h"
#import "GatewaySelfServiceMenuModel.h"

@interface GatewayViewController ()
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *quitBtn;
@property (nonatomic, strong) UILabel *gatewayStatusLb;
@property (nonatomic, strong) GatewayComponentInfoView *infoView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) GatewayCenter *center;

@property (nonatomic, strong) GatewayModel *model;
@property (nonatomic, strong) GatewaySelfServiceMenuModel *serviceModel;
@property (nonatomic, strong) GatewayBean *gatewayBean;

@end

@implementation GatewayViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self initData];
    [self initConstraints];
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateConstraints];
//    [UIView animateWithDuration:10 animations:^{
//        [self.view layoutIfNeeded];
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Init Method
- (void)initData {
    
    _center = [GatewayCenter defaultCenter];
//    self.model.delegate = self;

//    当进入界面时发现已经联网了，则先退出再请求才能正常显示数据
//    if ([self.model hasUser] && _center.networkEnable == YES && _center.campusStatus == YES) {
//        [self.model quitTheGateway];
//        [self.model fetchGatewayData];
//        [self.indicatorView startAnimating];
//    }
    [self initNetworkStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGatewayNetworkStatusChangeNotification:) name:kGatewayNetworkStatusChangeNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentLoginVC];
    });

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
                        [self.loginBtn setTitle:@"登录网关" forState:UIControlStateNormal];
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
                        [self setLoginBtnHidden];
                    } else if (_center.wifiStatus == GatewayStatusNO) {
                        // 蜂窝数据
                        alertMessage = @"正在使用 蜂窝数据\n校园卡等服务无法使用";
                        [self setLoginBtnHidden];
                    }
                } else if (_center.reachableStatus == GatewayStatusNO) {
                    alertMessage = @"连接以太网超时(10s)";
                    [self setLoginBtnHidden];
                } else {
                    NSLog(@"网络状态未知");
                }
            }
                break;
            case GatewayStatusUnknown:
            {
                alertMessage = @"正在检测网络环境...";
                [self setLoginBtnHidden];
            }
                break;
            default:
                break;
        }
    } else {
        alertMessage = @"网络已断开";
        [self setLoginBtnHidden];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.gatewayStatusLb.text = alertMessage;
        CGSize size = [LYTool sizeWithString:_gatewayStatusLb.text font:_gatewayStatusLb.font];
        _gatewayStatusLb.bounds = CGRectMake(0, 0, size.width, size.height);
        
        CGSize loginBtnSize = [LYTool sizeWithString:_loginBtn.titleLabel.text font:_loginBtn.titleLabel.font];
        self.loginBtn.bounds = CGRectMake(0, 0, loginBtnSize.width, loginBtnSize.height);
        [self updateConstraints];
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

}

- (void)updateConstraints {
    
    [self.gatewayStatusLb mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.quitBtn).with.offset(120);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.cardView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.blurView);
        make.top.equalTo(self.gatewayStatusLb.mas_bottom).with.offset(20);
        make.bottom.equalTo(self.blurView.mas_bottom);
    }];
    
    if (_center.networkEnable == YES && _center.reachableStatus == YES) {
        [self.infoView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(self.view).multipliedBy(0.3);
            make.width.equalTo(self.view);
            make.centerX.equalTo(self.gatewayStatusLb);
            make.top.equalTo(self.cardView);
        }];
        
        [self.loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.gatewayStatusLb);
            make.top.equalTo(self.infoView.mas_bottom).with.offset(20);
        }];
        
    } else if (_center.networkEnable == YES && _center.reachableStatus == NO) {
        
        [self.loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.gatewayStatusLb);
            make.top.equalTo(self.infoView.mas_bottom).with.offset(20);
        }];
    } else {
        
    }
    
}


#pragma mark - Private Method

- (void)setLoginBtnHidden {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginBtn setTitle:@"" forState:UIControlStateNormal];
        self.loginBtn.enabled = NO;
    });
}

#pragma mark - Notification
- (void)didGatewayNetworkStatusChangeNotification:(NSNotification *)notification {
    [self initNetworkStatus];
}

#pragma mark - GatewaySelfServiceModelDelegate
- (void)fetchSelfServiceMenuFailureWithMessage:(NSString *)msg {
    
}

- (void)fetchSelfServiceMenuSuccess {
    
}



#pragma mark - GatewayModel delegate
//- (void)fetchGatewayDataFailureWithMsg:(NSString *)msg {
////    在这个方法中处理登录失败信息
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([[LYTool getPresentedViewController] isKindOfClass:[LoginViewController class]]) {
////            [self.loginVC stopVerifyWithSuccess:NO];
//        }
//        //            若登录信息失败，并且连接了网关，则显示登录按钮，隐藏退出按钮
//        if (_center.campusStatus == YES && _center.reachableStatus == NO) {
//            [self.loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self.gatewayStatusLb);
//                make.top.equalTo(self.infoView.mas_bottom).with.offset(20);
//            }];
//            //  通知不会及时更新文字，手动更新loginBtn的文字
//            self.gatewayStatusLb.text = @"校园网密码认证失败\n请确保账号密码正确";
//            self.loginBtn.enabled = YES;
//            [self.loginBtn setTitle:@"登陆校园网" forState:UIControlStateNormal];
//
//        } else if (_center.campusStatus == YES && _center.reachableStatus == YES){
//            [self.loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self.gatewayStatusLb);
//                make.top.equalTo(self.infoView.mas_bottom).with.offset(20);
//            }];
//            //  通知不会及时更新文字，手动更新loginBtn的文字
//            self.loginBtn.enabled = YES;
//            self.gatewayStatusLb.text = @"校园网密码认证失败\n请确保账号密码正确";
//            [self.loginBtn setTitle:@"登陆校园网" forState:UIControlStateNormal];
//
//            CGSize size = [LYTool sizeWithString:self.gatewayStatusLb.text font:_gatewayStatusLb.font];
//            _gatewayStatusLb.bounds = CGRectMake(0, 0, size.width, size.height);
//            CGSize loginBtnSize = [LYTool sizeWithString:self.loginBtn.titleLabel.text font:_loginBtn.titleLabel.font];
//            self.loginBtn.bounds = CGRectMake(0, 0, loginBtnSize.width, loginBtnSize.height);
//        } else {
//            [self setLoginBtnHidden];
//        }
//
//        [self.indicatorView stopAnimating];
//        [self.view layoutIfNeeded];
////        [UIView animateWithDuration:5 animations:^{
////            [self.indicatorView stopAnimating];
////            [self.view layoutIfNeeded];
////        }];
//    });
//}
//
//- (void)fetchGatewayDataSuccess {
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        if ([[LYTool getPresentedViewController] isKindOfClass:[LoginViewController class]]) {
////            [self.loginVC stopVerifyWithSuccess:YES];
//        }
////        NSLog(@"%@", [LYTool getPresentedViewController]);
//
//        //    在这个方法中处理登录成功信息
//        _gatewayBean = [self.model gatewayInfo];
//
//        [self.infoView setUpWithGatewayBean:self.gatewayBean];
//
//        [self.infoView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(self.view).multipliedBy(0.25);
//            make.width.equalTo(self.view);
//            make.centerX.equalTo(self.gatewayStatusLb);
//            make.top.equalTo(self.cardView);
//        }];
//        [self.loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.gatewayStatusLb);
//            make.top.equalTo(self.infoView.mas_bottom).with.offset(20);
//        }];
//
//        //                通知不会及时更新文字，手动更新gatewayStatusLb和loginBtn的文字
//        self.gatewayStatusLb.text = @"正在使用校园网 Wi-Fi\n可访问外网";
//        [self.loginBtn setTitle:@"切换校园网账号" forState: UIControlStateNormal];
//        self.loginBtn.enabled = YES;
//
//
//        CGSize loginBtnSize = [LYTool sizeWithString:_loginBtn.titleLabel.text font:_loginBtn.titleLabel.font];
//        self.loginBtn.bounds = CGRectMake(0, 0, loginBtnSize.width, loginBtnSize.height);
//
//        [self.indicatorView stopAnimating];
//        [self.view layoutIfNeeded];
////        [UIView animateWithDuration:5 animations:^{
////            [self.indicatorView stopAnimating];
////            [self.view layoutIfNeeded];
////        }];
//    });
//}

#pragma mark - ResponseMethod
- (void)quitGatewayViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentLoginVC {
    WS(ws);
    User *currentUser = [UserCenter defaultCenter].currentUser;
    NSString *account = currentUser.number ? : @"";
    NSString *password = [currentUser.keychain passwordForKeyType:UserKeyTypeIPGW] ? : @"";
    
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    loginViewController.modalPresentationStyle = UIModalPresentationCustom;
    loginViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [loginViewController setupWithTitle:@"IP网关" inputType:LoginInputTypeAccount|LoginInputTypePassword|LoginInputTypeVerifyCode
                        contents:@{
                                   @(LoginInputTypeAccount):@"20154883",
                                   @(LoginInputTypePassword):@"123456"
                                   }
                     resultBlock:^(NSDictionary<NSNumber *,NSString *> *result, BOOL complete) {
                         if (complete) {
                             NSString *account = result[@(LoginInputTypeAccount)] ? : @"";
                             NSString *password = result[@(LoginInputTypePassword)] ? : @"";
                             NSString *verifycode = result[@(LoginInputTypeVerifyCode)] ? : @"";
                              [ws loginWithAccount:account password:password verifyCode:verifycode];
                         }
    }];
    [self presentViewController:loginViewController animated:NO completion:^{
        [ws.serviceModel getVerifyImage:^(UIImage *verifyImage, NSString *msg) {
            loginViewController.verifyImage = verifyImage;
        }];
    }];
    
//    修改验证码
    __weak LoginViewController *weakLoginViewController = loginViewController;
    loginViewController.changeVerifyImageBlock = ^{
        [ws.serviceModel getVerifyImage:^(UIImage *verifyImage, NSString *msg) {
            weakLoginViewController.verifyImage = verifyImage;
        }];
    };
}

- (void)loginWithAccount:(NSString *)account password:(NSString *)password verifyCode:(NSString *)verifyCode {
    WS(ws);
    [self.serviceModel loginGatewaySelfServiceMenuWithUser:account password:password verifyCode:verifyCode loginState:^(BOOL success, NSString *msg) {
        if (success) {
//            [ws.serviceModel queryUserOnlineLogDetailListComplete:^(BOOL success, NSString *data) {
//
//            }];
//            [ws.serviceModel queryUserOnlineFinancialPayListComplete:^(BOOL success, NSString *data) {
//
//            }];
            [ws.serviceModel queryUserFinancialCheckOutListComlete:^(BOOL success, NSString *data) {
                NSLog(@"%@", data);
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws.serviceModel queryUserFinancialCheckOutListComlete:^(BOOL success, NSString *data) {
                    NSLog(@"%@", data);
                }];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws.serviceModel queryUserFinancialCheckOutListComlete:^(BOOL success, NSString *data) {
                    NSLog(@"%@", data);
                }];
            });
            
            [self.serviceModel refreshData];
        }
    }];
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
        _cardView.center = CGPointMake(self.view.center.x, self.view.frame.size.height);
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
//        _model.delegate = self;
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
        _gatewayStatusLb.center = CGPointMake(self.view.center.x, self.view.frame.size.height);
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
//        _infoView.center = CGPointMake(self.view.center.x, self.view.frame.size.height);
        [self.cardView addSubview:_infoView];
    }
    
    return _infoView;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] init];
        _loginBtn.center = CGPointMake(self.view.center.x, self.view.frame.size.height);
        [_loginBtn setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor beautyTealBlue] forState:UIControlStateHighlighted];
        _loginBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        
        [_loginBtn addTarget:self action:@selector(presentLoginVC) forControlEvents:UIControlEventTouchUpInside];
        [self.cardView addSubview:_loginBtn];
    }
    return _loginBtn;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView  = [[UIActivityIndicatorView alloc] init];
        _indicatorView.center = CGPointMake(self.view.center.x, self.view.center.y);
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self.blurView.contentView addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (GatewaySelfServiceMenuModel *)serviceModel {
    if (!_serviceModel) {
        _serviceModel = [[GatewaySelfServiceMenuModel alloc] init];
    }
    return _serviceModel;
}

@end
