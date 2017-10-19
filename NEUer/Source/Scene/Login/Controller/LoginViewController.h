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
 @prama infoViewType : 信息类型
 */
- (void)personalInformationWithDic:(NSDictionary <LoginKey, NSString *>*)info loginInfoViewType:(LoginComponentInfoViewType)infoViewType;

/**
 登陆成功回调
 */
- (BOOL)didLoginSuccessed;

@end


@interface LoginViewController : UIViewController

@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

+ (instancetype)shareLoginViewController;
- (void)setUpWithLoginInfoViewType:(LoginComponentInfoViewType)infoViewType;

@end
