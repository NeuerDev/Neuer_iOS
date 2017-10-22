//
//  LoginComponentInfoView.h
//  NEUer
//
//  Created by lanya on 2017/10/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LYTextField;

typedef NS_OPTIONS(NSUInteger, LoginComponentInfoViewType) {
    LoginComponentInfoViewTypeDefault              = 1 << 0,
    LoginComponentInfoViewTypeVerificationcode     = 1 << 1,
    LoginComponentInfoViewTypeIDCard               = 1 << 2,
};

@interface LoginComponentInfoView : UIView

@property (strong, nonatomic) LYTextField *accountTF;
@property (strong, nonatomic) LYTextField *passwordTF;
@property (strong, nonatomic) LYTextField *verificationTF;
@property (strong, nonatomic) LYTextField *IDCardTF;

- (instancetype)initWithLoginComponentInfoViewType:(LoginComponentInfoViewType)infoViewType withVerificationImg:(UIImage *)verificationcode;

@end
