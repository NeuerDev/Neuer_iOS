//
//  LoginComponentInfoView.m
//  NEUer
//
//  Created by lanya on 2017/10/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LoginComponentInfoView.h"
#import "LYTextField.h"
#import "Masonry.h"

@interface LoginComponentInfoView ()

@property (nonatomic, assign) LoginComponentInfoViewType infoViewType;
@property (nonatomic, strong) UIImage *verificationcode;
@end

@implementation LoginComponentInfoView

- (instancetype)initWithLoginComponentInfoViewType:(LoginComponentInfoViewType)infoViewType withVerificationImg:(UIImage *)verificationcode {
    if (self = [super init]) {
        _infoViewType = infoViewType;
        self.userInteractionEnabled = YES;
        _verificationcode = verificationcode;
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    
    [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(@45);
        make.right.equalTo(self);
    }];
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.top.equalTo(self.accountTF.mas_bottom).with.offset(40);
        make.height.equalTo(@45);
    }];

    if (self.infoViewType & LoginComponentInfoViewTypeIDCard) {
        [self.IDCardTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self.accountTF);
            make.top.equalTo(self.passwordTF.mas_bottom).with.offset(20);
            make.height.equalTo(@45);
        }];
        if (self.infoViewType & loginTextFieldTypeIDcard & loginTextFieldTypeVerificationcode) {
            [self.verificationTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.right.equalTo(self.accountTF);
                make.top.equalTo(self.IDCardTF.mas_bottom).with.offset(20);
                make.height.equalTo(@45);
            }];
        }
    } else if (self.infoViewType & loginTextFieldTypeVerificationcode) {
        [self.verificationTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(self);
            make.top.equalTo(self.passwordTF.mas_bottom).with.offset(20);
            make.height.equalTo(@45);
        }];
    } else {
        NSLog(@"只有账号密码");
    }
}


#pragma mark - GETTER
- (LYTextField *)accountTF {
    if (!_accountTF) {
        _accountTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypeAccount withVerificationCodeImg:nil];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"account"]) {
            _accountTF.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
        }
        [self addSubview:_accountTF];
    }
    return _accountTF;
}

- (LYTextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypePassword withVerificationCodeImg:nil];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"]) {
            _passwordTF.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        }
        [self addSubview:_passwordTF];
    }
    return _passwordTF;
}

- (LYTextField *)verificationTF {
    if (!_verificationTF) {
        _verificationTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypeVerificationcode withVerificationCodeImg:self.verificationcode];
        [self addSubview:_verificationTF];
    }
    return _verificationTF;
}

- (LYTextField *)IDCardTF {
    if (!_IDCardTF) {
        _IDCardTF = [[LYTextField alloc] initWithLoginTextFieldType:loginTextFieldTypeIDcard withVerificationCodeImg:nil];
        [self addSubview:_verificationTF];
    }
    return _verificationTF;
}
@end
