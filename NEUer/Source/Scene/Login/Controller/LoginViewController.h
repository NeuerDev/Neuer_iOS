//
//  LoginViewController.h
//  NEUer
//
//  Created by lanya on 2017/9/27.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, LoginComponentInfoViewType) {
    LoginComponentInfoViewTypeDefault              = 1 << 0,
    LoginComponentInfoViewTypeIDCard               = 1 << 1,
    LoginComponentInfoViewTypeVerificationcode     = 1 << 2,
};

typedef NSString * LoginKey NS_EXTENSIBLE_STRING_ENUM;

@protocol LoginViewControllerDelegate <NSObject>

@required

/**
 将个人信息传递给model
 @prama info : 信息
 */
- (void)personalInformationWithDic:(NSDictionary <LoginKey, NSString *>*)info;

@end


@interface LoginViewController : UIViewController

@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

+ (instancetype)shareLoginViewController;

//初始化类型
- (void)setUpWithLoginInfoViewType:(LoginComponentInfoViewType)infoViewType;

/**
 初始化验证码
 */
- (void)setUpWithVerificationcode:(UIImage *)verificationcode;

/**
 结束登陆动画，若登录成功则dismissLoginViewController
 */
- (void)stopVerifyWithSuccess:(BOOL)success;

@end
