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
#import "CBWAlertSheet.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UIView *cardView;

@property (strong, nonatomic) LYTextField *accountTF;
@property (strong, nonatomic) LYTextField *passwordTF;
@property (strong, nonatomic) LYTextField *verificationTF;
@property (strong, nonatomic) UIImageView *iconImgView;

@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *quitBtn;
@property (strong, nonatomic) UIButton *moreBtn;

@property (strong, nonatomic) CBWAlertSheet *alertSheet;

@property (strong, nonatomic) UIImage *verificationCode;
@property (strong, nonatomic) UILabel *studentNumLb;

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
}

- (void)initConstaints {
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).with.offset(20);
        make.top.equalTo(self.cardView).with.offset(40);
        make.width.and.height.equalTo(@25);
    }];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.cardView).with.offset(-20);
        make.top.equalTo(self.quitBtn);
        make.width.and.height.equalTo(@25);
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cardView);
        make.top.equalTo(self.quitBtn.mas_bottom).with.offset(50);
        make.height.and.width.equalTo(@150);
    }];
    
    switch (self.loginState) {
        case LoginStateHadLogin:
        {
            [self.studentNumLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.iconImgView.mas_bottom);
                make.height.equalTo(@45);
                make.width.equalTo(self.cardView).with.multipliedBy(0.8);
            }];
            
            [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.studentNumLb.mas_bottom).with.offset(5);
                make.height.equalTo(@45);
                make.width.equalTo(self.cardView).with.multipliedBy(0.8);
            }];
        }
            break;
        case LoginStateNeverLogin:
        {
            [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.iconImgView.mas_bottom).with.offset(20);
                make.height.equalTo(@45);
                make.width.equalTo(self.cardView).with.multipliedBy(0.8);
            }];
            [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.accountTF.mas_bottom).with.offset(10);
                make.height.equalTo(@45);
                make.width.equalTo(self.cardView).with.multipliedBy(0.8);
            }];
            
        }
            break;
        case LoginStateHadLoginWithVerificationCode:
        {
            [self.studentNumLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.iconImgView.mas_bottom);
                make.height.equalTo(@45);
            }];
            
            [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.studentNumLb.mas_bottom).with.offset(5);
                make.height.equalTo(@45);
                make.width.equalTo(self.cardView).with.multipliedBy(0.8);
            }];
            
            [self.verificationTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.passwordTF.mas_bottom).with.offset(10);
                make.height.equalTo(@45);
                make.width.equalTo(self.cardView).with.multipliedBy(0.8);
            }];
        }
            break;
        case LoginStateNeverLoginWithVerificationCode:
        {
            [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.iconImgView.mas_bottom).with.offset(5);
                make.height.equalTo(@45);
                make.width.equalTo(self.cardView).with.multipliedBy(0.8);
            }];
            [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.accountTF.mas_bottom).with.offset(10);
                make.height.equalTo(@45);
                make.width.equalTo(self.cardView).with.multipliedBy(0.8);
            }];
            
            [self.verificationTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.cardView.mas_centerX);
                make.top.equalTo(self.passwordTF.mas_bottom).with.offset(10);
                make.height.equalTo(@45);
                make.width.equalTo(self.cardView).with.multipliedBy(0.8);
            }];
        }
            break;
        default:
            break;
    }
    
    if (self.loginState == LoginStateNeverLogin || self.loginState == LoginStateHadLogin) {
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.cardView);
            make.top.equalTo(self.passwordTF.mas_bottom).with.offset(20);
            make.height.equalTo(@45);
            make.width.equalTo(self.cardView).with.multipliedBy(0.8);
        }];
    } else {
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.cardView);
            make.top.equalTo(self.verificationTF.mas_bottom).with.offset(20);
            make.width.equalTo(self.cardView).with.multipliedBy(0.8);
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

- (void)setUpWithStudentNumber:(NSString *)studentNumStr {
    self.studentNumLb.text = studentNumStr;
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
    self.loginBtn.enabled = YES;
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
    if ([self.accountTF isFirstResponder]) {
        [self.accountTF resignFirstResponder];
    }
    if ([self.passwordTF isFirstResponder]) {
        [self.passwordTF resignFirstResponder];
    }
    if ([self.verificationTF isFirstResponder]) {
        [self.verificationTF resignFirstResponder];
    }
    
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

- (void)didClickedMoreBtn {
    switch (self.loginState) {
        case LoginStateHadLogin:
        case LoginStateHadLoginWithVerificationCode:
        {
            [self.alertSheet show];
        }
            break;
        case LoginStateNeverLogin:
        case LoginStateNeverLoginWithVerificationCode:
            break;
        default:
            break;
    }
}

- (void)didClickedQuitBtn {
    [self dismissViewControllerAnimated:YES completion:^{
        self.failureMsg(@"退出登录");
    }];
}

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

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.image = [UIImage imageNamed:@"icon"];
        [self.cardView addSubview:_iconImgView];
    }
    return _iconImgView;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc] init];
        
        [_loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [_loginBtn setBackgroundColor:[JHTool colorWithHexStr:@"#3a99d9"]];
        [_loginBtn.layer setCornerRadius:2];
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

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
        [_moreBtn setBackgroundImage:[UIImage imageNamed:@"ellipsis"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(didClickedMoreBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.cardView addSubview:_moreBtn];
    }
    return _moreBtn;
}

- (CBWAlertSheet *)alertSheet {
    if (!_alertSheet) {
        _alertSheet = [[CBWAlertSheet alloc] init];
        _alertSheet.type = CBWAlertSheetTypeCancelButton;
        _alertSheet.cancleButtonColor = [UIColor whiteColor];
        _alertSheet.cancleButtonTextColor = [UIColor blackColor];
        //        _alertSheet.messageTextColor = [UIColor blackColor];
//        __weak typeof(self) ws = self;
        [_alertSheet addSheetWithTitle:@"切换账号" color:[UIColor blackColor] handler:^(CBWAlertSheet *alertView) {
            
        }];
        [_alertSheet addSheetWithTitle:@"修改密码" color:[UIColor blackColor] handler:nil];
    }
    return _alertSheet;
}

- (UILabel *)studentNumLb {
    if (!_studentNumLb) {
        _studentNumLb = [[UILabel alloc] init];
        _studentNumLb.textColor = [UIColor blackColor];
        _studentNumLb.backgroundColor = [UIColor whiteColor];
        _studentNumLb.textAlignment = NSTextAlignmentCenter;
        _studentNumLb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"account"] != NULL) {
            _studentNumLb.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
        }
        [self.cardView addSubview:_studentNumLb];
    }
    return _studentNumLb;
}

@end


