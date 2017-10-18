//
//  LYTextField.m
//  LYLogin
//
//  Created by lanya on 2017/9/28.
//  Copyright © 2017年 lanya. All rights reserved.
//

#import "LYTextField.h"
#import "JHTool.h"

@interface LYTextField ()
@property (assign, nonatomic) loginTextFieldType type;
@property (strong, nonatomic) UIImage *verificationcodeImg;

@property (strong, nonatomic) UILabel *accountLb;
@property (strong, nonatomic) UILabel *passwordLb;
@property (strong, nonatomic) UILabel *IDCardLb;
@property (strong, nonatomic) UIButton *eyesBtn;
@end

@implementation LYTextField

#pragma mark - Init
- (instancetype)initWithLoginTextFieldType:(loginTextFieldType)type withVerificationCodeImg:(UIImage *)img{
    if (self = [super init]) {
        _type = type;
        _verificationcodeImg = img;
        [self initData];
    }
    return self;
}

- (void)initData {
    switch (self.type) {
        case loginTextFieldTypeAccount:
        {
            self.leftView = self.accountLb;
            self.leftViewMode = UITextFieldViewModeAlways;
            self.placeholder = @"请输入学号";
            self.textContentType = UITextContentTypeUsername;
            self.tag = 00;
            self.keyboardType = UIKeyboardTypeNumberPad;
        }
            break;
        case loginTextFieldTypePassword:
        {
            self.leftView = self.passwordLb;
            self.leftViewMode = UITextFieldViewModeAlways;
            self.placeholder = @"请输入密码";
            self.secureTextEntry = YES;
            self.textContentType = UITextContentTypePassword;
            self.rightView = self.eyesBtn;
            self.tag = 01;
            self.rightViewMode = UITextFieldViewModeAlways;
        }
            break;
        case loginTextFieldTypeVerificationcode:
        {
            self.rightView = [[UIImageView alloc] initWithImage:self.verificationcodeImg];
            self.rightViewMode = UITextFieldViewModeAlways;
            self.tag = 02;
            self.keyboardType = UIKeyboardTypeNumberPad;
            self.placeholder = @"在此输入验证码";
        }
            break;
        case loginTextFieldTypeIDcard:
        {
            self.leftView = self.IDCardLb;
            self.leftViewMode = UITextFieldViewModeAlways;
            self.placeholder = @"请输入身份证号";
            self.tag = 03;
            self.keyboardType = UIKeyboardTypeNumberPad;
            
        }
        default:
            break;
    }
}

#pragma mark - Override
//  重写leftView的X值
- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.size.height = 25;
    iconRect.size.width = 100;
    iconRect.origin.y -= 30;
    return iconRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    if (_type == loginTextFieldTypeVerificationcode) {
        CGRect verificationcodeRect = [super rightViewRectForBounds:bounds];
        verificationcodeRect.size.height = bounds.size.height - 5;
        verificationcodeRect.size.width = 150;
        return verificationcodeRect;
    } else if (_type == loginTextFieldTypePassword) {
        CGRect passwordeyesRect = [super rightViewRectForBounds:bounds];
        passwordeyesRect.size.height = bounds.size.height - 5;
        passwordeyesRect.size.width = 100;
        passwordeyesRect.origin.y -= 25;
        passwordeyesRect.origin.x += 25;
        return passwordeyesRect;
    }
    return [super rightViewRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect placeholderRect = [super placeholderRectForBounds:bounds];
    placeholderRect.origin.x -= 0;
    return placeholderRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    switch (self.tag) {
        case 00:
        case 01:
        case 03:
        {
            CGRect editRect = [super editingRectForBounds:bounds];
            editRect.origin.x -= 100;
            editRect.size.width += 100;
            return editRect;
        }
            break;
        case 02:
        {
            return [super editingRectForBounds:bounds];
        }
        default:
            break;
    }
    return [super editingRectForBounds:bounds];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    switch (self.tag) {
        case 00:
        case 01:
        case 03:
        {
            CGRect textRect = [super textRectForBounds:bounds];
            textRect.origin.x -= 100;
            textRect.size.width += 100;
            return textRect;
        }
            break;
        case 02:
            break;
        default:
            break;
    }
    return [super textRectForBounds:bounds];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //    创建画布
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    //    设置填充颜色
    CGContextSetFillColorWithColor(contextRef, [UIColor lightGrayColor].CGColor);
    //    设置边界
    CGContextFillRect(contextRef, CGRectMake(0, self.frame.size.height - 0.5, self.frame.size.width, 0.5));
}

#pragma mark - response Method
- (void)didClickedEyesBtn {
    self.secureTextEntry = !self.secureTextEntry;
    if (!self.secureTextEntry) {
        [self.eyesBtn setTitle:@"Hide" forState:UIControlStateNormal];
    } else {
        [self.eyesBtn setTitle:@"Show" forState:UIControlStateNormal];
    }
}

#pragma mark - GETTER
- (UIButton *)eyesBtn {
    if (!_eyesBtn) {
        _eyesBtn = [[UIButton alloc] init];
        if (self.secureTextEntry) {
            [_eyesBtn setTitle:@"Show" forState:UIControlStateNormal];
        } else {
            [_eyesBtn setTitle:@"Hide" forState:UIControlStateNormal];
        }
        [_eyesBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_eyesBtn setTitleColor:[JHTool colorWithHexStr:@"#3a99d9"] forState:UIControlStateHighlighted];
        [_eyesBtn addTarget:self action:@selector(didClickedEyesBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_eyesBtn];
    }
    return _eyesBtn;
}

- (UILabel *)accountLb {
    if (!_accountLb) {
        _accountLb = [[UILabel alloc] init];
        [_accountLb setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
        [_accountLb setText:@"Account"];
        [_accountLb setTextColor:[UIColor grayColor]];
        [self addSubview:_accountLb];
    }
    return _accountLb;
}

- (UILabel *)passwordLb {
    if (!_passwordLb) {
        _passwordLb = [[UILabel alloc] init];
        [_passwordLb setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
        [_passwordLb setTextColor:[UIColor grayColor]];
        [_passwordLb setText:@"Password"];
        [self addSubview:_passwordLb];
    }
    return _passwordLb;
}

- (UILabel *)IDCardLb {
    if (!_IDCardLb) {
        _IDCardLb = [[UILabel alloc] init];
        [_IDCardLb setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
        [_IDCardLb setTextColor:[UIColor grayColor]];
        [_IDCardLb setText:@"ID Number"];
        [self addSubview:_IDCardLb];
    }
    return _IDCardLb;
}

@end

