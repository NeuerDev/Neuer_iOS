//
//  EcardViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoViewController.h"
#import "LoginViewController.h"
#import "AaoTrainingPlanViewController.h"
#import "AaoStudentScoreViewController.h"

#import "AaoComponentAccessView.h"
#import "AaoComponentTimetableView.h"

#import "AaoModel.h"

@interface AaoViewController ()
@property (nonatomic, strong) AaoModel *model;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) AaoComponentAccessView *accessView;
@property (nonatomic, strong) AaoComponentTimetableView *timeTableView;

@end

@implementation AaoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initConstaints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Init

- (void)didReceiveCellDidClickedNotification:(NSNotification *)noti {
    NSString *params = noti.userInfo[@"param"];
    
    id viewController = [[NSClassFromString(params) alloc] init];
    NSAssert(viewController != nil, @"error with viewController");
    
    if ([viewController isKindOfClass:[AaoTrainingPlanViewController class]]) {
        ((AaoTrainingPlanViewController *)viewController).model = self.model;
    } else if ([viewController isKindOfClass:[AaoStudentScoreViewController class]]) {
        ((AaoStudentScoreViewController *)viewController).model = self.model;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)initData {
    self.title = @"教务处";
    [self showLoginBoxWithQueryType:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCellDidClickedNotification:) name:kAaoComponentCellDidClickedNotification object:nil];
}

- (void)initConstaints {
    self.scrollView.frame = self.view.frame;
    
    [self.accessView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.equalTo(@(64));
        make.centerX.and.width.equalTo(self.view);
    }];
}

//- (void)checkLoginState {
//    User *user = [UserCenter defaultCenter].currentUser;
//    NSString *account = user.number ? : @"";
//    NSString *password = [user.keychain passwordForKeyType:UserKeyTypeAAO] ? : @"";
//    if (![account isEqualToString:@""] && ![password isEqualToString:@""]) {
//
//    }
//}

- (void)showLoginBoxWithQueryType:(AaoAtionQueryType)queryType {
    User *user = [UserCenter defaultCenter].currentUser;
    NSString *account = user.number ? : @"";
    NSString *password = [user.keychain passwordForKeyType:UserKeyTypeAAO] ? : @"";
    
    WS(ws);
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.modalPresentationStyle = UIModalPresentationCustom;
    loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [loginVC setupWithTitle:@"欢迎登陆教务处" inputType:NEUInputTypeAccount | NEUInputTypePassword | NEUInputTypeVerifyCode contents:@{
                              @(NEUInputTypeAccount) : account,
                              @(NEUInputTypePassword) : password
                            } resultBlock:^(NSDictionary<NSNumber *,NSString *> *result, BOOL complete) {
                                if (complete) {
                                    NSString *number = [result objectForKey:@(NEUInputTypeAccount)];
                                    NSString *password = [result objectForKey:@(NEUInputTypePassword)];
                                    NSString *verifycode = [result objectForKey:@(NEUInputTypeVerifyCode)];
                                    [ws loginWithUserNumber:number password:password verifycode:verifycode queryType:queryType];
                                }
    }];
    [self presentViewController:loginVC animated:YES completion:^{
        [ws.model getVerifyImage:^(BOOL success, UIImage *verifyImage) {
            if (success) {
                [loginVC setVerifyImage:verifyImage];
            }
        }];
    }];

    __weak LoginViewController *weakLoginVC = loginVC;
    loginVC.changeVerifyImageBlock = ^{
        [ws.model getVerifyImage:^(BOOL success, UIImage *verifyImage) {
            if (success) {
                weakLoginVC.verifyImage = verifyImage;
            }
        }];
    };
}

- (void)loginWithUserNumber:(NSString *)number password:(NSString *)password verifycode:(NSString *)verifycode queryType:(AaoAtionQueryType)queryType {
    WS(ws);
    [self.model authorUser:number password:password verifyCode:verifycode queryType:queryType callBack:^(BOOL success, NSString *message) {
        if (success) {
            NSLog(@"%@", message);
            [[UserCenter defaultCenter] setAccount:number password:password forKeyType:UserKeyTypeAAO];
            
//            [ws.model queryStudentStatusWithBlock:^(BOOL success, NSString *message) {
//
//            }];
            
//            [ws.model queryTrainingPlanWithBlock:^(BOOL success, NSString *message) {
//                NSLog(@"%@", message);
//            }];
//
//            [ws.model querySchoolPrecautionWithBlock:^(BOOL success, NSString *message) {
//                if (success) {
//                    NSLog(@"%@", message);
//                }
//            }];
            
//            [ws.model queryExaminationScheduleWithBlock:^(BOOL success, NSString *message) {
//                if (success) {
//                    NSLog(@"%@", message);
//                }
//            }];
            
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [ws showLoginBoxWithQueryType:0];
            }]];
            
            [ws presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

#pragma mark - Getter

- (AaoModel *)model {
    if (!_model) {
        _model = [[AaoModel alloc] init];
    }
    return _model;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (AaoComponentAccessView *)accessView {
    if (!_accessView) {
        _accessView = [[AaoComponentAccessView alloc] init];
        [self.view addSubview:_accessView];
    }
    
    return _accessView;
}

- (UIView *)timeTableView {
    if (!_timeTableView) {
        _timeTableView = [[AaoComponentTimetableView alloc] init];
        [self.view addSubview:_timeTableView];
    }
    return _timeTableView;
}

@end
