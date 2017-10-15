//
//  LYTextField.h
//  LYLogin
//
//  Created by lanya on 2017/9/28.
//  Copyright © 2017年 lanya. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, loginTextFieldType) {
    loginTextFieldTypeAccount,
    loginTextFieldTypePassword,
    loginTextFieldTypeVerificationcode
};

@interface LYTextField : UITextField

/**
 选择textField类型并传递验证码图片
 */
- (instancetype)initWithLoginTextFieldType:(loginTextFieldType)type withVerificationCodeImg:(UIImage *)img;

@end
