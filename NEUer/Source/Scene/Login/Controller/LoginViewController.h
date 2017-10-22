//
//  SigninViewController.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, LoginInputType) {
    LoginInputTypeAccount         = 1 << 0,
    LoginInputTypeIdentityNumber  = 1 << 1,
    LoginInputTypePassword        = 1 << 2,
    LoginInputTypeNewPassword     = 1 << 3,
    LoginInputTypeRePassword      = 1 << 4,
    LoginInputTypeVerifyCode      = 1 << 5,
};

typedef void(^SigninResultBlock)(NSDictionary<NSNumber *, NSString *> *result, BOOL complete);
typedef void(^SigninChangeVerifyImageBlock)(void);

@interface LoginViewController : UIViewController

@property (nonatomic, strong) UIImage *verifyImage;
@property (nonatomic, strong) SigninChangeVerifyImageBlock changeVerifyImageBlock;

- (void)setupWithTitle:(NSString *)title inputType:(LoginInputType)inputType resultBlock:(SigninResultBlock)resultBlock;
- (void)setupWithTitle:(NSString *)title inputType:(LoginInputType)inputType contents:(NSDictionary<NSNumber *, NSString *> *)contents resultBlock:(SigninResultBlock)resultBlock;

@end
