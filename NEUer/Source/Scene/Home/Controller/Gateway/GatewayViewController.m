//
//  GatewayViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewayViewController.h"
#import "LoginViewController.h"

@interface GatewayViewController () <GatewayModelDelegate>
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIVisualEffectView *vibrancyEffectView;
@property (nonatomic, strong) LoginViewController *loginVC;
@property (nonatomic, strong) GatewayModel *model;
@property (nonatomic, strong) GatewayBean *gatewayBean;
@property (nonatomic, strong) UIButton *quitBtn;

@end

@implementation GatewayViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    [self initData];
    [self initConstraints];
}

#pragma mark - Init Method
- (void)initData {

    if ([self.model hasUser]) {
        [self.model fetchGatewayData];
    } else {
        UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 100, 100)];
        [btn2 setBackgroundColor:[UIColor greenColor]];
        [self.vibrancyEffectView.contentView addSubview:btn2];
        [btn2 addTarget:self action:@selector(presentNoVerificationCodeVC) forControlEvents:UIControlEventTouchUpInside];
    }
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 100, 100)];
    [btn2 setBackgroundColor:[UIColor greenColor]];
    [self.vibrancyEffectView.contentView addSubview:btn2];
    [btn2 addTarget:self action:@selector(presentNoVerificationCodeVC) forControlEvents:UIControlEventTouchUpInside];
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
    
}


- (void)presentNoVerificationCodeVC {
    LoginViewController *loginVC2 = [LoginViewController shareLoginViewController];
    [loginVC2 setUpWithLoginState:LoginStateLogin withLoginVerificationCodeImg:nil];
    [self presentViewController:loginVC2 animated:YES completion:nil];
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

#pragma mark - GatewayModel delegate
- (void)fetchGatewayDataFailureWithMsg:(NSString *)msg {
//    在这个方法中处理登录失败信息
    NSLog(@"登录失败");
}

- (void)fetchGatewayDataSuccess {
//    在这个方法中处理登录成功信息
    _gatewayBean = [self.model gatewayInfo];
    NSLog(@"gatewayBean = %@", _gatewayBean.balance);
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

@end
