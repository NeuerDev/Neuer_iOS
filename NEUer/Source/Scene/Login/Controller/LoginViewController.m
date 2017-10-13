//
//  LoginViewController.m
//  NEUer
//
//  Created by lanya on 2017/9/27.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LoginViewController.h"
#import "LYTextField.h"
#import "Masonry.h"
#import "JHTool.h"
#import "LYAnimatedTransitioning.h"
#import "LYInteractiveTransition.h"

@interface LoginViewController ()<UITextFieldDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) UIView *cardView;

@property (strong, nonatomic) LYTextField *accountTF;
@property (strong, nonatomic) LYTextField *passwordTF;
@property (strong, nonatomic) LYTextField *verificationTF;

@property (strong, nonatomic) UILabel *loginLb;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *quitBtn;

@property (strong, nonatomic) UIImage *verificationCode;
@property (strong, nonatomic) LYInteractiveTransition *interactiveDismiss;

@property (assign, nonatomic) LoginState loginState;

@end

@implementation LoginViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initConstaints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init
- (instancetype)initWithLoginState:(LoginState)loginState {
    if (self = [super init]) {
        _loginState = loginState;
    }
    return self;
}

- (void)initData {
    self.view.backgroundColor = [UIColor whiteColor];
    [self registerForKeyboardNotification];
    //    设置代理
    self.transitioningDelegate = self;
    self.modalTransitionStyle = UIModalPresentationCustom;
}

- (void)initConstaints {
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).with.offset(30);
        make.top.equalTo(self.cardView).with.offset(40);
        make.width.and.height.equalTo(@20);
    }];
    
    [self.loginLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.quitBtn);
        make.top.equalTo(self.quitBtn.mas_bottom).with.offset(10);
        make.height.and.width.equalTo(@100);
    }];
    
    [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loginLb);
        make.top.equalTo(self.loginLb.mas_bottom).with.offset(30);
        make.height.equalTo(@45);
        make.right.equalTo(self.cardView).with.offset(-30);
    }];
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.accountTF);
        make.top.equalTo(self.accountTF.mas_bottom).with.offset(40);
        make.height.equalTo(@45);
    }];
    
    
    switch (self.loginState) {
        case LoginStateHadLogin:
        case LoginStateNeverLogin:
            break;
        case LoginStateHadLoginWithVerificationCode:
        case LoginStateNeverLoginWithVerificationCode:
        {
            [self.verificationTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(self.accountTF);
                make.top.equalTo(self.passwordTF.mas_bottom).with.offset(20);
                make.height.equalTo(@45);
            }];
        }
            break;
        default:
            break;
    }
    
    if (self.loginState == LoginStateNeverLogin || self.loginState == LoginStateHadLogin) {
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.passwordTF.mas_bottom).with.offset(30);
            make.height.equalTo(@45);
        }];
    } else {
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.verificationTF.mas_bottom).with.offset(30);
            make.height.equalTo(@45);
        }];
    }
}

#pragma mark - SetUp Method
- (void)setUpWithLoginVerificationcodeImg:(UIImage *)image {
    self.verificationCode = image;
}

- (void)setDidLoginWithSuccessMsg:(SuccessWithMsg)successMsg FailureMsg:(FailureWithMsg)failureMsg {
    self.successMsg = successMsg;
    self.failureMsg = failureMsg;
}

#pragma mark - UIViewControllerTransitioningDelegate
//实现转场动画方法
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [LYAnimatedTransitioning transitionWithTransitioningType:LYAnimatedTransitioningTypePresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [LYAnimatedTransitioning transitionWithTransitioningType:LYAnimatedTransitioningTypeDismiss];
}

//实现添加手势方法
//如果有需要，可以在present的时候添加上滑手势
- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    if (self.delegate && [_delegate respondsToSelector:@selector(interactiveTransitioningPresent)]) {
        LYInteractiveTransition *interactiveTransitionPresent = [self.delegate interactiveTransitioningPresent];
        return interactiveTransitionPresent.isInteractive ? interactiveTransitionPresent : nil;
    }
    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.interactiveDismiss.isInteractive ? self.interactiveDismiss : nil;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.accountTF isFirstResponder]) {
        [self.accountTF resignFirstResponder];
    }
    if ([self.passwordTF isFirstResponder]) {
        [self.passwordTF resignFirstResponder];
    }
    if ([self.verificationTF isFirstResponder]) {
        [self.verificationTF resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    switch (textField.tag) {
        case 00:
        {
            for (int i = 0; i < string.length; ++i) {
                unichar character = [string characterAtIndex:i];
                if (character < 48 || character > 57) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"账号只允许输入数字" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return NO;
                }
            }
            if (string.length + range.location + range.length > 8) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"账号最多只能输入8位" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
                return NO;
            }
        }
            break;
        case 01:
        {
            if (string.length + range.location + range.length > 18) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"密码最多只能输入18位" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
                return NO;
            }
        }
            break;
        case 02:
        {
            if (string.length + range.location + range.length > 4) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"验证码最多只能输入4位" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
                return NO;
            }
        }
            break;
        default:
            break;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSUserDefaults standardUserDefaults] setObject:self.accountTF.text forKey:@"account"];
    switch (textField.tag) {
        case 00:
        {
            if (textField.text.length < 4) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"账号至少输入4位" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = 0.4;
                return;
            }
//            当用户不按顺序填写时
            if (self.loginState == LoginStateHadLogin || self.loginState == LoginStateNeverLogin) {
                if (![self.passwordTF.text isEqualToString:@""] && ![textField.text isEqualToString:@""]) {
                    self.loginBtn.enabled = YES;
                    self.loginBtn.alpha = 1;
                }
            } else {
                if (![self.passwordTF.text isEqualToString:@""] && ![textField.text isEqualToString:@""] && ![self.verificationTF.text isEqualToString:@""]) {
                    self.loginBtn.enabled = YES;
                    self.loginBtn.alpha = 1;
                }
            }
        }
            break;
        case 01:
        {
            if (textField.text.length < 6) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"密码至少输入6位" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = 0.4;
                return;
            }
            if (self.loginState == LoginStateNeverLogin || self.loginState == LoginStateHadLogin) {
                self.loginBtn.enabled = YES;
                self.loginBtn.alpha = 1;
            }
        }
            break;
        case 02:
        {
            if (textField.text.length < 4) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"验证码至少输入4位" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = 0.4;
                return;
            }
            if (self.loginState == LoginStateHadLoginWithVerificationCode || self.loginState == LoginStateNeverLoginWithVerificationCode) {
                self.loginBtn.enabled = YES;
                self.loginBtn.alpha = 1;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - register keyboard Notification
- (void)registerForKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - ResponseMethod
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

- (void)didClickedLoginBtn {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.accountTF.text forKey:@"account"];
    
    switch (self.loginState) {
        case LoginStateHadLoginWithVerificationCode:
        {
            //    账号密码验证码都是必须的,其中账号可以预填
            if (![self.passwordTF.text isEqualToString:@""] && ![self.verificationTF.text isEqualToString:@""]) {
                self.successMsg(@[@"123455", self.passwordTF.text, self.verificationTF.text]);
            } else {
                if ([self.passwordTF.text isEqualToString:@""]) {
                    self.failureMsg(@"密码未填写");
                } else {
                    self.failureMsg(@"验证码未填写");
                }
            }
        }
            break;
        case LoginStateNeverLoginWithVerificationCode:
        {
            //    账号密码验证码都是必须的,其中账号可以预填
            if (![self.accountTF.text isEqualToString:@""] && ![self.passwordTF.text isEqualToString:@""] && ![self.verificationTF.text isEqualToString:@""]) {
                self.successMsg(@[self.accountTF.text, self.passwordTF.text, self.verificationTF.text]);
            } else {
                if ([self.accountTF.text isEqualToString:@""]) {
                    self.failureMsg(@"账号未填写");
                } else if ([self.passwordTF.text isEqualToString:@""]) {
                    self.failureMsg(@"密码未填写");
                } else {
                    self.failureMsg(@"验证码未填写");
                }
            }
        }
            break;
        case LoginStateHadLogin:
        {
            if (![self.passwordTF.text isEqualToString:@""]) {
                self.successMsg(@[@"123456", self.passwordTF.text]);
            } else {
                self.failureMsg(@"请输入密码");
            }
        }
            break;
        case LoginStateNeverLogin:
        {
            //    账号密码是必须的,其中账号可以预填
            if (![self.accountTF.text isEqualToString:@""] && ![self.passwordTF.text isEqualToString:@""]) {
                self.successMsg(@[self.accountTF.text, self.passwordTF.text]);
            } else {
                if ([self.accountTF.text isEqualToString:@""]) {
                    self.failureMsg(@"账号未填写");
                } else {
                    self.failureMsg(@"密码未填写");
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)didClickedQuitBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIKeyboardNotification
- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    //    计算键盘弹出动画的时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat y2 = self.view.frame.size.height - keyboardHeight;
    CGFloat y1 = self.loginBtn.frame.size.height + self.loginBtn.frame.origin.y - 8;
    CGFloat offset = y1 - y2 + 16;
    if (offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            [self.cardView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).with.offset(-offset);
                make.bottom.equalTo(self.view).with.offset(-offset);
            }];
            [self.view layoutIfNeeded];
            
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self.cardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self.view);
        }];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - GETTER
- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_cardView];
    }
    return _cardView;
}

- (LYTextField *)accountTF {
    if (!_accountTF) {
        _accountTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypeAccount];
        _accountTF.delegate = self;
        [self.cardView addSubview:_accountTF];
    }
    return _accountTF;
}

- (LYTextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypePassword];
        _passwordTF.delegate = self;
        [self.cardView addSubview:_passwordTF];
    }
    return _passwordTF;
}

- (LYTextField *)verificationTF {
    if (!_verificationTF) {
        _verificationTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypeVerificationcode];
        [_verificationTF setUpWithVerificationCodeImg:self.verificationCode];
        _verificationTF.delegate = self;
        _verificationTF.text = @"";
        [self.cardView addSubview:_verificationTF];
    }
    return _verificationTF;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] init];
        
        [_loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [_loginBtn setBackgroundColor:[JHTool colorWithHexStr:@"#3a99d9"]];
        [_loginBtn.layer setCornerRadius:2];
        _loginBtn.layer.shadowOffset =  CGSizeMake(1, 1);
        _loginBtn.layer.shadowOpacity = 0.5;
        _loginBtn.layer.shadowColor =  [UIColor blackColor].CGColor;
        [_loginBtn addTarget:self action:@selector(didClickedLoginBtn) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.enabled = NO;
        _loginBtn.alpha = 0.4;
        [self.cardView addSubview:_loginBtn];
    }
    return _loginBtn;
}

- (UIButton *)quitBtn {
    if (!_quitBtn) {
        _quitBtn = [[UIButton alloc] init];
        [_quitBtn setBackgroundImage:[UIImage imageNamed:@"quit"] forState:UIControlStateNormal];
        [_quitBtn addTarget:self action:@selector(didClickedQuitBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.cardView addSubview:_quitBtn];
    }
    return _quitBtn;
}

- (UILabel *)loginLb {
    if (!_loginLb) {
        _loginLb = [[UILabel alloc] init];
        [_loginLb setTextColor:[UIColor blackColor]];
        [_loginLb setText:@"Log In"];
        [_loginLb setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle]];
        _loginLb.textAlignment = NSTextAlignmentLeft;
        [self.cardView addSubview:_loginLb];
    }
    return _loginLb;
}

//添加dismiss手势
- (LYInteractiveTransition *)interactiveDismiss {
    if (!_interactiveDismiss) {
        _interactiveDismiss = [LYInteractiveTransition interactiveTrainsitionWithTransitionType:LYInteractiveTransitionTypeDismiss GestureDirection:LYInteractiveTransitionGestureDirectionDown];
        [_interactiveDismiss addPanGestureToViewController:self];
        _interactiveDismiss.interactive = YES;
    }
    return _interactiveDismiss;
}

@end


