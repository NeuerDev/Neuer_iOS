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
#import "UIColor+JHCategory.h"

#import "LYAnimatedTransitioning.h"
#import "LYInteractiveTransition.h"

static LoginViewController *_sigletonLoginViewController = nil;

@interface LoginViewController ()<UITextFieldDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) UIView *cardView;

@property (strong, nonatomic) LYTextField *accountTF;
@property (strong, nonatomic) LYTextField *passwordTF;
@property (strong, nonatomic) LYTextField *verificationTF;
@property (strong, nonatomic) LYTextField *IDNumberTF;

@property (strong, nonatomic) UILabel *loginLb;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UILabel *alertLb;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) UIImage *verificationCode;
@property (strong, nonatomic) LYInteractiveTransition *interactiveDismiss;

@property (assign, nonatomic) LoginComponentInfoViewType infoViewType;

@end

@implementation LoginViewController
{
    NSUserDefaults *userDefault;
}
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

- (void)viewWillAppear:(BOOL)animated {
    if ([userDefault objectForKey:@"account"]) {
        _accountTF.text = [userDefault objectForKey:@"account"];
    }
    if ([userDefault objectForKey:@"password"]) {
        _passwordTF.text = [userDefault objectForKey:@"password"];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)setUpWithLoginInfoViewType:(LoginComponentInfoViewType)infoViewType {
    self.infoViewType = infoViewType;
}

- (void)setUpWithVerificationcode:(UIImage *)verificationcode {
    self.verificationCode = verificationcode;
}

- (void)initData {
    
    userDefault = [NSUserDefaults standardUserDefaults];
    
//    设置手势交互为YES
    self.interactiveDismiss.interactive = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self registerForKeyboardNotification];
    //    设置代理
    self.transitioningDelegate = self;
    self.modalTransitionStyle = UIModalPresentationCustom;
    
    switch (self.infoViewType) {
        case 1:
        {
//            暂时存到偏好设置
            if ([userDefault objectForKey:@"account"] != nil && ![[userDefault objectForKey:@"account"] isEqualToString:@""]) {
                if ([userDefault objectForKey:@"password"] != nil && ![[userDefault objectForKey:@"password"] isEqualToString:@""]) {
                    [self setLoginBtnEnable];
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
    
    [self.loginLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).with.offset(30);
        make.top.equalTo(self.cardView).with.offset(40);
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
    //        有身份证一定有验证码，有验证码不一定有身份证
    if (self.infoViewType & LoginComponentInfoViewTypeVerificationcode) {
        if (self.infoViewType & LoginComponentInfoViewTypeIDCard) {
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
        } else {
//            没idnumber
            [self.verificationTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(self.accountTF);
                make.top.equalTo(self.passwordTF.mas_bottom).with.offset(40);
                make.height.equalTo(@45);
            }];
        }
        
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.verificationTF.mas_bottom).with.offset(30);
            make.height.equalTo(@45);
        }];
    } else {
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.passwordTF.mas_bottom).with.offset(30);
            make.height.equalTo(@45);
        }];
    }
    
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loginBtn.mas_centerX);
        make.centerY.equalTo(self.loginBtn.mas_centerY);
    }];
    
    [self.alertLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.left.and.right.equalTo(self.loginBtn);
        make.top.equalTo(self.loginBtn.mas_bottom).with.offset(20);
    }];
    
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
//- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
//    if (self.delegate && [_delegate respondsToSelector:@selector(interactiveTransitioningPresent)]) {
//        LYInteractiveTransition *interactiveTransitionPresent = [self.delegate interactiveTransitioningPresent];
//        return interactiveTransitionPresent.isInteractive ? interactiveTransitionPresent : nil;
//    }
//    return nil;
//}

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
    if ([self.IDNumberTF isFirstResponder]) {
        [self.IDNumberTF resignFirstResponder];
    }
    
    [self didVerifiedLoginBtnEnaled];

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *regexString = nil;
    switch (textField.tag) {
        case 00:
        {
            regexString = @"^\\d{0,8}$";
        }
            break;
        case 01:
        {
//            密码6-18位
            regexString = @"^([A-Z]|[a-z]|[0-9]|[`~!@#$%^&*()+=|{}':;',\\\\[\\\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“'。，、？]){0,18}$";
        }
            break;
        case 02:
        {
//            只能输入数字
            regexString = @"^\\d{0,4}$";
        }
            break;
        case 03:
        {
//            只允许输入身份证信息
            regexString = @"^\\d{0,18}[0-9Xx]?$";
        }
            break;
        default:
            break;
    }
    
    NSString *currentText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    return [regexTest evaluateWithObject:currentText] || currentText.length == 0;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 00:
        {
            if (textField.text.length < 4) {
                [self showAlertWithMessage:@"账号至少输入4位"];
                [self setLoginBtnDisable];
                return;
            }
        }
            break;
        case 01:
        {
            if (textField.text.length < 6) {
                [self showAlertWithMessage:@"密码至少输入6位"];
                [self setLoginBtnDisable];
                return;
            }
            if (self.infoViewType == LoginComponentInfoViewTypeDefault) {
                [self setLoginBtnEnable];
            }
        }
            break;
        case 02:
        {
            if (textField.text.length < 4) {
                [self showAlertWithMessage:@"验证码至少输入4位"];
                [self setLoginBtnDisable];
                return;
            }
            if (self.infoViewType == 5) {
                [self setLoginBtnEnable];
            }
        }
            break;
        case 03:
        {
            if (textField.text.length != 18) {
                [self showAlertWithMessage:@"请注意身份证的位数"];
                [self setLoginBtnDisable];
            } else {
                if (self.infoViewType == 7) {
                    [self setLoginBtnEnable];
                }
            }
        }
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
    [self didVerifiedLoginBtnEnaled];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    if ([touches anyObject].view != self.view) {
//        UIView *touchView = [touches anyObject].view;
////        NSLog(@"%@", view);
//        for (UIView *view in self.view.subviews) {
//            if (view.subviews.count > 0) {
//                for (UIView *subView in view.subviews) {
//                    //                NSLog(@"%@", subView);
//                    if (touchView == subView) {
//                        return;
//                    }
//                }
//            }
//            if (touchView == view) {
//                return;
//            }
//        }
//
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
    //获取所有的触摸位置
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
//    从右下角开始画图
    CGPathMoveToPoint(pathRef, NULL, self.view.frame.size.width, self.view.frame.size.height);
//    (0,height)
    CGPathAddLineToPoint(pathRef, NULL, 0, self.view.frame.size.height);
//    当前视图原点,设置点击边框也能返回上一视图
    CGPathAddLineToPoint(pathRef, NULL, 0, 20);
    CGPathAddLineToPoint(pathRef, NULL, self.view.frame.size.width, 20);
//    NSLog(@"%f", self.view.frame.origin.y);
    CGPathCloseSubpath(pathRef);
    
    if (CGPathContainsPoint(pathRef, NULL, point, NO)) {
//        如果在这个区域中就什么都不做
    } else {
//        如果超出了这个区域，则返回上一界面
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didClickedLoginBtn {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:0];
    [param setObject:self.accountTF.text forKey:@"account"];
    [param setObject:self.passwordTF.text forKey:@"password"];
    
    if ([self.delegate respondsToSelector:@selector(personalInformationWithDic:)]) {
        switch (self.infoViewType) {
            case 3:
            {
                [param setObject:self.IDNumberTF.text forKey:@"idnumber"];
            }
                break;
            case 5:
            {
                [param setObject:self.verificationTF.text forKey:@"verificationcode"];
            }
                break;
            case 7:
            {
                [param setObject:self.IDNumberTF.text forKey:@"idnumber"];
                [param setObject:self.verificationTF.text forKey:@"verificationcode"];
            }
                break;
            default:
                break;
        }
        [self.delegate personalInformationWithDic:param];
    }
    
    [self.indicatorView startAnimating];
    [self setUserInteractionEnable:NO];
    [self.loginBtn setTitle:@"" forState:UIControlStateNormal];

}

- (void)stopVerifyWithSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (success) {
            if ([self.indicatorView isAnimating]) {
                [self.indicatorView stopAnimating];
            }
            [self setUserInteractionEnable:YES];
        //    临时的数据,只有登录成功才存储数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [userDefault setObject:self.accountTF.text forKey:@"account"];
                [userDefault setObject:self.passwordTF.text forKey:@"password"];
            });

            [self dismissViewControllerAnimated:YES completion:^{
                [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
            }];
            
        } else {

            if ([self.indicatorView isAnimating]) {
                [self.indicatorView stopAnimating];
            }
            [self setUserInteractionEnable:YES];

            [self showAlertWithMessage:@"登录失败！请检查您的账号密码"];
            [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        }
    });
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


#pragma mark - Private Method
- (void)setLoginBtnEnable {
    self.loginBtn.enabled = YES;
    self.loginBtn.alpha = 1;
}

- (void)setLoginBtnDisable {
    self.loginBtn.enabled = NO;
    self.loginBtn.alpha = 0.4;
}

- (void)didVerifiedLoginBtnEnaled {
    if (self.infoViewType & LoginComponentInfoViewTypeVerificationcode) {
        //        先设置为yes，若其他项未满足，再设为no
        if (![self.accountTF.text isEqualToString:@""] && ![self.passwordTF.text isEqualToString:@""]) {
            //        有身份证一定有验证码，有验证码不一定有身份证
            if (self.infoViewType & LoginComponentInfoViewTypeVerificationcode) {
                if (self.infoViewType & LoginComponentInfoViewTypeIDCard) {
                    if (![self.verificationTF.text isEqualToString:@""] && ![self.IDNumberTF.text isEqualToString:@""]) {
                        [self setLoginBtnEnable];
                    } else {
                        [self setLoginBtnDisable];
                    }
                } else {
                    if (![self.verificationTF.text isEqualToString:@""]) {
                        [self setLoginBtnEnable];
                    }
                }
            } else {
                [self setLoginBtnEnable];
            }
        }
    }
}

//设置子视图是否可交互
- (void)setUserInteractionEnable:(BOOL)enable {
    for (UIView *view in self.view.subviews) {
        if (view.subviews.count > 0) {
            for (UIView *subView in view.subviews) {
                [subView setUserInteractionEnabled:enable];
//                NSLog(@"%@", subView);
            }
        }
    }
}

- (void)showAlertWithMessage:(NSString *)msg {
    self.alertLb.alpha = 1;
    self.alertLb.text = msg;
    [UIView animateWithDuration:4 animations:^{
        self.alertLb.alpha = 0;
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
        _accountTF.delegate = self;
        [self.cardView addSubview:_accountTF];
    }
    return _accountTF;
}

- (LYTextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypePassword withVerificationCodeImg:nil];
        _passwordTF.delegate = self;
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
        _loginBtn.alpha = 0.4;
        [self.cardView addSubview:_loginBtn];
    }
    return _loginBtn;
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
    }
    return _interactiveDismiss;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView  = [[UIActivityIndicatorView alloc] init];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self.loginBtn addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UILabel *)alertLb {
    if (!_alertLb) {
        _alertLb = [[UILabel alloc] init];
        _alertLb.textColor = [UIColor beautyRed];
        _alertLb.textAlignment = NSTextAlignmentCenter;
        _alertLb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self.view addSubview:_alertLb];
    }
    return _alertLb;
}

@end


