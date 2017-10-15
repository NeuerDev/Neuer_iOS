//
//  LoginViewController.h
//  NEUer
//
//  Created by lanya on 2017/9/27.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GatewayModel.h"

typedef NS_ENUM(NSInteger, LoginState) {
    LoginStateLogin,
    LoginStateLoginWithVerificationCode,
};

@protocol LoginViewControllerDelegate <NSObject>

@optional
- (id<UIViewControllerInteractiveTransitioning>)interactiveTransitioningPresent;
- (void)personalInformationArray:(NSArray <NSString *>*)info withloginState:(LoginState)loginState;
- (BOOL)didSuccessLogin;
@end

@interface LoginViewController : UIViewController

@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

+ (instancetype)shareLoginViewController;
- (void)setUpWithLoginState:(LoginState)loginState withLoginVerificationCodeImg:(UIImage *)image;

@end
