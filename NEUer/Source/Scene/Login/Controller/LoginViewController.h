//
//  SigninViewController.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEUInputView.h"

typedef void(^SigninResultBlock)(NSDictionary<NSNumber *, NSString *> *result, BOOL complete);
typedef void(^SigninChangeVerifyImageBlock)(void);

@interface LoginViewController : UIViewController

@property (nonatomic, strong) UIImage *verifyImage;
@property (nonatomic, strong) SigninChangeVerifyImageBlock changeVerifyImageBlock;

- (void)setupWithTitle:(NSString *)title inputType:(NEUInputType)inputType resultBlock:(SigninResultBlock)resultBlock;
- (void)setupWithTitle:(NSString *)title inputType:(NEUInputType)inputType contents:(NSDictionary<NSNumber *, NSString *> *)contents resultBlock:(SigninResultBlock)resultBlock;

@end
