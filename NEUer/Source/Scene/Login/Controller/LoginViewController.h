//
//  LoginViewController.h
//  NEUer
//
//  Created by lanya on 2017/9/27.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SuccessWithMsg)(NSArray *msgArr);
typedef void(^FailureWithMsg)(NSString *msg);

typedef NS_ENUM(NSInteger, LoginState) {
    LoginStateNeverLogin,
    LoginStateHadLogin,
    LoginStateNeverLoginWithVerificationCode,
    LoginStateHadLoginWithVerificationCode,
};

@interface LoginViewController : UIViewController

@property (strong, nonatomic) SuccessWithMsg successMsg;
@property (strong, nonatomic) FailureWithMsg failureMsg;

- (instancetype)initWithLoginState:(LoginState)loginState;
- (void)setUpWithLoginVerificationcodeImg:(UIImage *)image;
//- (void)setUpWithStudentNumber:(NSString *)studentNumStr;
- (void)setDidLoginWithSuccessMsg:(SuccessWithMsg)successMsg FailureMsg:(FailureWithMsg)failureMsg;
@end
