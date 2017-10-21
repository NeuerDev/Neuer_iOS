//
//  SigninViewController.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, SigninInputType) {
    SigninInputTypeAccount         = 1 << 0,
    SigninInputTypeIdentityNumber  = 1 << 1,
    SigninInputTypePassword        = 1 << 2,
    SigninInputTypeNewPassword     = 1 << 3,
    SigninInputTypeRePassword      = 1 << 4,
    SigninInputTypeVerifyCode      = 1 << 5,
};

typedef void(^SigninResultBlock)(NSDictionary<NSNumber *, NSString *> *result, BOOL complete);
typedef void(^SigninChangeVerifyImageBlock)(void);

@interface SigninViewController : UIViewController

@property (nonatomic, strong) UIImage *verifyImage;
@property (nonatomic, strong) SigninChangeVerifyImageBlock changeVerifyImageBlock;

- (void)setupWithTitle:(NSString *)title inputType:(SigninInputType)inputType resultBlock:(SigninResultBlock)resultBlock;
- (void)setupWithTitle:(NSString *)title inputType:(SigninInputType)inputType contents:(NSDictionary<NSNumber *, NSString *> *)contents resultBlock:(SigninResultBlock)resultBlock;

@end
