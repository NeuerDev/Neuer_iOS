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
#import "MBProgressHUD.h"
#import "JHTool.h"

#import "LYAnimatedTransitioning.h"
#import "LYInteractiveTransition.h"

static CGFloat DISABLEALPHA = 0.4;
static CGFloat ENABLEALPHA = 1;
static LoginViewController *_sigletonLoginViewController = nil;


@interface LoginViewController ()<UITextFieldDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) UIView *cardView;

@property (strong, nonatomic) LYTextField *accountTF;
@property (strong, nonatomic) LYTextField *passwordTF;
@property (strong, nonatomic) LYTextField *verificationTF;
@property (strong, nonatomic) LYTextField *IDNumberTF;

@property (strong, nonatomic) UILabel *loginLb;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *quitBtn;

@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIImage *verificationCode;
@property (strong, nonatomic) LYInteractiveTransition *interactiveDismiss;

@property (assign, nonatomic) LoginComponentInfoViewType infoViewType;

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

#pragma mark - Singleton
+ (instancetype)shareLoginViewController {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sigletonLoginViewController = [super allocWithZone:zone];
    });
    return _sigletonLoginViewController;
}


#pragma mark - Init
- (void)setUpWithLoginInfoViewType:(LoginComponentInfoViewType)infoViewType withLoginVerificationCodeImg:(UIImage *)image {
    _infoViewType  = infoViewType;
    if (image && (_infoViewType & LoginComponentInfoViewTypeVerificationcode)) {
        self.verificationCode = image;
    }
}

- (void)initData {
    self.view.backgroundColor = [UIColor whiteColor];
    [self registerForKeyboardNotification];
    //    设置代理
    self.transitioningDelegate = self;
    self.modalTransitionStyle = UIModalPresentationCustom;
    
    switch (self.infoViewType) {
        case 1:
        {
//            暂时存到偏好设置
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"account"] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"account"] isEqualToString:@""]) {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] isEqualToString:@""]) {
                    self.loginBtn.enabled = YES;
                    self.loginBtn.alpha = ENABLEALPHA;
                }
            }
        }
            break;
        case 3:
        {

        }
            break;
        case 5:
        {

        }
            break;
        case 7:
        {

        }
            break;
        default:
            break;
    }
}

- (void)initConstaints {
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).with.offset(30);
        make.top.equalTo(self.cardView).with.offset(40);
        make.width.and.height.equalTo(@25);
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
    
    if (self.infoViewType == 5) {
        [self.verificationTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.passwordTF.mas_bottom).with.offset(40);
            make.height.equalTo(@45);
        }];
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.verificationTF.mas_bottom).with.offset(30);
            make.height.equalTo(@45);
        }];


    } else if (self.infoViewType == 3) {
        [self.IDNumberTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.passwordTF.mas_bottom).with.offset(40);
            make.height.equalTo(@45);
        }];

        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.IDNumberTF.mas_bottom).with.offset(30);
            make.height.equalTo(@45);
        }];

    } else if (self.infoViewType == 7) {
        [self.IDNumberTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.passwordTF.mas_bottom).with.offset(40);
            make.height.equalTo(@45);
        }];
        [self.verificationTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.IDNumberTF.mas_bottom).with.offset(40);
            make.height.equalTo(@45);
        }];
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.verificationTF.mas_bottom).with.offset(40);
            make.height.equalTo(@45);
        }];
    } else {
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.passwordTF.mas_bottom).with.offset(30);
            make.height.equalTo(@45);
        }];
    }
}

#pragma mark - Override
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
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
    
    [self didVerifiedLoginBtnEnaled];

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    switch (textField.tag) {
        case 00:
        {
            for (int i = 0; i < string.length; ++i) {
                unichar character = [string characterAtIndex:i];
                if (character < 48 || character > 57) {
                    [self showAlertWithMessage:@"账号只允许输入数字"];
                    return NO;
                }
            }
            if (string.length + range.location + range.length > 8) {
                [self showAlertWithMessage:@"账号最多只能输入8位"];
                return NO;
            }
        }
            break;
        case 01:
        {
            if (string.length + range.location + range.length > 18) {
                [self showAlertWithMessage:@"密码最多只能输入18位"];
                return NO;
            }
        }
            break;
        case 02:
        {
            if (string.length + range.location + range.length > 4) {
                [self showAlertWithMessage:@"验证码最多只能输入4位"];
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
    switch (textField.tag) {
        case 00:
        {
            if (textField.text.length < 4) {
                [self showAlertWithMessage:@"账号至少输入4位"];
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = DISABLEALPHA;
                return;
            }
//            当用户不按顺序填写时
//            if (self.loginState == LoginStateLogin) {
//                if (![self.passwordTF.text isEqualToString:@""] && ![textField.text isEqualToString:@""]) {
//                    self.loginBtn.enabled = YES;
//                    self.loginBtn.alpha = ENABLEALPHA;
//                }
//            } else {
//                if (![self.passwordTF.text isEqualToString:@""] && ![textField.text isEqualToString:@""] && ![self.verificationTF.text isEqualToString:@""]) {
//                    self.loginBtn.enabled = YES;
//                    self.loginBtn.alpha = ENABLEALPHA;
//                }
//            }
        }
            break;
        case 01:
        {
            if (textField.text.length < 6) {
                [self showAlertWithMessage:@"密码至少输入6位"];
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = DISABLEALPHA;
                return;
            }
            if (self.infoViewType == LoginComponentInfoViewTypeDefault) {
                self.loginBtn.enabled = YES;
                self.loginBtn.alpha = ENABLEALPHA;
            }
        }
            break;
        case 02:
        {
            if (textField.text.length < 4) {
                [self showAlertWithMessage:@"验证码至少输入4位"];
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = DISABLEALPHA;
                return;
            }
            if (self.infoViewType & LoginComponentInfoViewTypeVerificationcode && !(self.infoViewType & LoginComponentInfoViewTypeIDCard)) {
                self.loginBtn.enabled = YES;
                self.loginBtn.alpha = ENABLEALPHA;
            }
        }
            break;
        case 03:
        {
            if (textField.text.length != 18) {
                [self showAlertWithMessage:@"请注意身份证的位数"];
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = DISABLEALPHA;
            } else {
                if (self.infoViewType & LoginComponentInfoViewTypeIDCard && (self.infoViewType & LoginComponentInfoViewTypeVerificationcode)) {
                    self.loginBtn.enabled = YES;
                    self.loginBtn.alpha = ENABLEALPHA;
                }
            }
        }
        default:
            break;
    }
}

#pragma mark - Private Method
- (void)didVerifiedLoginBtnEnaled {
    
    switch (self.infoViewType) {
        case 1:
        {
            if ([self.accountTF.text isEqualToString:@""] || [self.passwordTF.text isEqualToString:@""]) {
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = DISABLEALPHA;
            } else {
                self.loginBtn.enabled = YES;
                self.loginBtn.alpha = ENABLEALPHA;
            }
        }
            break;
        case 3:
        {
            if ([self.accountTF.text isEqualToString:@""] || [self.passwordTF.text isEqualToString:@""] || [self.IDNumberTF.text isEqualToString:@""]) {
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = DISABLEALPHA;
            } else {
                self.loginBtn.enabled = YES;
                self.loginBtn.alpha = ENABLEALPHA;
            }
        }
            break;
        case 5:
        {
            if ([self.accountTF.text isEqualToString:@""] || [self.passwordTF.text isEqualToString:@""] || [self.verificationTF.text isEqualToString:@""]) {
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = DISABLEALPHA;
            } else {
                self.loginBtn.enabled = YES;
                self.loginBtn.alpha = ENABLEALPHA;
            }
        }
            break;
        case 7:
        {
            if ([self.accountTF.text isEqualToString:@""] || [self.passwordTF.text isEqualToString:@""] || [self.IDNumberTF.text isEqualToString:@""] || [self.verificationTF.text isEqualToString:@""]) {
                self.loginBtn.enabled = NO;
                self.loginBtn.alpha = DISABLEALPHA;
            } else {
                self.loginBtn.enabled = YES;
                self.loginBtn.alpha = ENABLEALPHA;
            }
        }
            break;
        default:
            break;
    }
}

- (void)showAlertWithMessage:(NSString *)msg {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
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
    [self didVerifiedLoginBtnEnaled];
}

- (void)didClickedLoginBtn {
    
    switch (self.infoViewType) {
        case 1:
        {
            if ([self.delegate respondsToSelector:@selector(personalInformationArray:withloginInfoViewType:)]) {
                [self.delegate personalInformationArray:[NSArray arrayWithObjects:self.accountTF.text, self.passwordTF.text, nil] withloginInfoViewType:self.infoViewType];
            }
        }
            break;
        case 3:
        {
            if ([self.delegate respondsToSelector:@selector(personalInformationArray:withloginInfoViewType:)]) {
                [self.delegate personalInformationArray:[NSArray arrayWithObjects:self.accountTF.text, self.passwordTF.text, self.IDNumberTF.text, nil] withloginInfoViewType:self.infoViewType];
            }
        }
            break;
        case 5:
        {
            if ([self.delegate respondsToSelector:@selector(personalInformationArray:withloginInfoViewType:)]) {
                [self.delegate personalInformationArray:[NSArray arrayWithObjects:self.accountTF.text, self.passwordTF.text, self.verificationTF.text, nil] withloginInfoViewType:self.infoViewType];
            }
        }
            break;
        case 7:
        {
            if ([self.delegate respondsToSelector:@selector(personalInformationArray:withloginInfoViewType:)]) {
                [self.delegate personalInformationArray:[NSArray arrayWithObjects:self.accountTF.text, self.passwordTF.text, self.IDNumberTF.text, self.verificationTF.text, nil] withloginInfoViewType:self.infoViewType];
            }
        }
            break;
        default:
            break;
    }
    
//    [self.hud showAnimated:YES];
    self.hud = [MBProgressHUD showHUDAddedTo:self.loginBtn animated:YES];
    _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    _hud.bezelView.color = [UIColor colorWithWhite:0.f alpha:0];
    _hud.contentColor = [UIColor whiteColor];
    [self.loginBtn setTitle:@"" forState:UIControlStateNormal];
    
//    延迟三秒执行代理方法，不然无法返回正确的值
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
            if ([self.delegate respondsToSelector:@selector(didSuccessLogin)]) {
                
                BOOL isLogin = [self.delegate didSuccessLogin];
                if (isLogin) {
                    NSLog(@"登录成功");
                    //                [self.hud hideAnimated:YES];
                    [self.hud hideAnimated:YES];
                    
                    
                    //    临时的数据,只有登录成功才存储数据
                    [[NSUserDefaults standardUserDefaults] setObject:self.accountTF.text forKey:@"account"];
                    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTF.text forKey:@"password"];
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
                    }];
                    
                } else {
                    NSLog(@"登录失败");
                    //                [self.hud hideAnimated:YES];
                    
                    [MBProgressHUD hideHUDForView:self.loginBtn animated:YES];
                    [self showAlertWithMessage:@"登录失败！请检查您的账号密码输入是否正确"];
                    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
                }
            } else {
                NSLog(@"delegate = %@", self.delegate);
                NSLog(@"没进这个方法");
            }
        
    });
    
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
        _accountTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypeAccount withVerificationCodeImg:nil];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"account"]) {
            _accountTF.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
        }
        _accountTF.delegate = self;
        [self.cardView addSubview:_accountTF];
    }
    return _accountTF;
}

- (LYTextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypePassword withVerificationCodeImg:nil];
        _passwordTF.delegate = self;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"]) {
            _passwordTF.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        }
        [self.cardView addSubview:_passwordTF];
    }
    return _passwordTF;
}

- (LYTextField *)verificationTF {
    if (!_verificationTF) {
        _verificationTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypeVerificationcode withVerificationCodeImg:self.verificationCode];
        _verificationTF.delegate = self;
        _verificationTF.text = @"";
        [self.cardView addSubview:_verificationTF];
    }
    return _verificationTF;
}

- (LYTextField *)IDNumberTF {
    if (!_IDNumberTF) {
        _IDNumberTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypeIDcard withVerificationCodeImg:nil];
        _IDNumberTF.delegate = self;
        [self.cardView addSubview:_IDNumberTF];
    }
    return _IDNumberTF;
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
        _loginBtn.alpha = DISABLEALPHA;
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


