//
//  LoginViewController.h
//  NEUer
//
//  Created by lanya on 2017/9/27.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GatewayModel.h"

//typedef NS_ENUM(NSInteger, LoginState) {
//    LoginStateLogin,
//    LoginStateLoginWithVerificationCode,
//};

typedef NS_OPTIONS(NSUInteger, LoginComponentInfoViewType) {
    LoginComponentInfoViewTypeDefault              = 1 << 0,
    LoginComponentInfoViewTypeIDCard               = 1 << 1,
    LoginComponentInfoViewTypeVerificationcode     = 1 << 2,
};

@protocol LoginViewControllerDelegate <NSObject>

@required
- (void)personalInformationArray:(NSArray <NSString *>*)info withloginInfoViewType:(LoginComponentInfoViewType)infoViewType;
- (BOOL)didSuccessLogin;

@optional
- (id<UIViewControllerInteractiveTransitioning>)interactiveTransitioningPresent;
//自动填充验证码
- (NSString *)setUpWithVerificationCode;

@end


@interface LoginViewController : UIViewController

@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

+ (instancetype)shareLoginViewController;
- (void)setUpWithLoginInfoViewType:(LoginComponentInfoViewType)infoViewType withLoginVerificationCodeImg:(UIImage *)image;

@end
