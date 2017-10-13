//
//  GatewayViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewayViewController.h"
#import "LoginViewController.h"

@interface GatewayViewController () <LoginViewControllerDelegate>
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIVisualEffectView *vibrancyEffectView;
@property (nonatomic, strong) LoginViewController *loginVC;
@property (nonatomic, strong) UIButton *quitBtn;
@property (strong, nonatomic) UIButton *btn;
@end

@implementation GatewayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    [self initConstraints];
    
}

- (void)initConstraints {
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.vibrancyEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.blurView);
    }];
    
    [self.quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.mas_equalTo(self.vibrancyEffectView).with.offset(30);
        make.height.and.width.mas_equalTo(25);
    }];
    
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.equalTo(self.vibrancyEffectView);
        make.height.and.width.equalTo(@100);
    }];
    
}


- (void)presentedVC {
    _loginVC = [[LoginViewController alloc] initWithLoginState:LoginStateNeverLoginWithVerificationCode];
    [_loginVC setUpWithLoginVerificationcodeImg:[UIImage imageNamed:@"verificationcode"]];
    _loginVC.delegate = self;
    [_loginVC setDidLoginWithSuccessMsg:^(NSArray *msgArr) {
        NSLog(@"%@", msgArr);
    } FailureMsg:^(NSString *msg) {
        NSLog(@"%@", msg);
    }];
    [self presentViewController:self.loginVC animated:YES completion:nil];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [UIView animateWithDuration:0.3 animations:^{
//        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - ResponseMethod
- (void)quitGatewayViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
        [self.view addSubview:_blurView];
    }
    
    return _blurView;
}

- (UIVisualEffectView *)vibrancyEffectView {
    if (!_vibrancyEffectView) {
        _vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]]];
    
        [self.blurView.contentView addSubview:_vibrancyEffectView];
    }
   return _vibrancyEffectView;
}

- (UIButton *)quitBtn {
    if (!_quitBtn) {
        _quitBtn = [[UIButton alloc] init];
        [_quitBtn setBackgroundImage:[UIImage imageNamed:@"quit"] forState:UIControlStateNormal];
        [_quitBtn addTarget:self action:@selector(quitGatewayViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.vibrancyEffectView.contentView addSubview:_quitBtn];
    }
    return _quitBtn;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [[UIButton alloc] init];
        [_btn setBackgroundColor:[UIColor redColor]];
        [_btn addTarget:self action:@selector(presentedVC) forControlEvents:UIControlEventTouchUpInside];
        [self.vibrancyEffectView.contentView addSubview:_btn];
    }
    return _btn;
}

@end
