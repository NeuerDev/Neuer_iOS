//
//  LYTextField.m
//  LYLogin
//
//  Created by lanya on 2017/9/28.
//  Copyright © 2017年 lanya. All rights reserved.
//

#import "LYTextField.h"
@interface LYTextField ()
@property (assign, nonatomic) loginTextFieldType type;
@property (strong, nonatomic) UIImage *verificationcodeImg;

@property (strong, nonatomic) UIButton *eyesBtn;
@end

@implementation LYTextField

#pragma mark - Init
- (instancetype)initWithLoginTextFieldType:(loginTextFieldType)type {
    if (self = [super init]) {
        _type = type;
        switch (type) {
            case loginTextFieldTypePassword:
                [self initData];
                break;
            case loginTextFieldTypeAccount:
                [self initData];
                break;
            case loginTextFieldTypeVerificationcode:
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)setUpWithVerificationCodeImg:(UIImage *)img {
    _verificationcodeImg = img;
    [self initData];
}

- (void)initData {
    self.borderStyle = UITextBorderStyleRoundedRect;
    switch (self.type) {
        case loginTextFieldTypeAccount:
        {
            self.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"账号"]];
            self.leftViewMode = UITextFieldViewModeAlways;
            self.layer.cornerRadius = 2;
            self.placeholder = @"请输入学号";
            self.tag = 00;
            self.keyboardType = UIKeyboardTypeNumberPad;
        }
            break;
        case loginTextFieldTypePassword:
        {
            self.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"密码"]];
            self.leftViewMode = UITextFieldViewModeAlways;
            self.placeholder = @"请输入密码";
            self.layer.cornerRadius = 2;
            self.secureTextEntry = YES;
            self.rightView = self.eyesBtn;
            self.tag = 01;
            self.rightViewMode = UITextFieldViewModeAlways;
        }
            break;
        case loginTextFieldTypeVerificationcode:
        {
            self.rightView = [[UIImageView alloc] initWithImage:self.verificationcodeImg];
            self.rightViewMode = UITextFieldViewModeAlways;
            self.layer.cornerRadius = 3;
            self.tag = 02;
            self.keyboardType = UIKeyboardTypeNumberPad;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Override
//  重写leftView的X值
- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.size.height = 25;
    iconRect.size.width = 25;
    iconRect.origin.x += 15;
    iconRect.origin.y += 0;
    return iconRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    if (_type == loginTextFieldTypeVerificationcode) {
        CGRect verificationcodeRect = [super rightViewRectForBounds:bounds];
        verificationcodeRect.size.height = bounds.size.height - 5;
        //        verificationcodeRect.origin.y += 0;
        verificationcodeRect.size.width = 150;
        return verificationcodeRect;
    } else {
        CGRect passwordeyesRect = [super rightViewRectForBounds:bounds];
        passwordeyesRect.size.height = 15;
        passwordeyesRect.size.width = 25;
        passwordeyesRect.origin.x -= 8;
        return passwordeyesRect;
    }
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect placeholderRect = [super placeholderRectForBounds:bounds];
    placeholderRect.origin.x += 10;
    return placeholderRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect editRect = [super editingRectForBounds:bounds];
    editRect.origin.x += 10;
    return editRect;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect textRect = [super textRectForBounds:bounds];
    textRect.origin.x += 10;
    return textRect;
}

- (CGRect)borderRectForBounds:(CGRect)bounds {
    if (self.type == loginTextFieldTypeVerificationcode) {
        CGRect borderRect = [super borderRectForBounds:bounds];
        borderRect.size.width -= 50;
        return borderRect;
    }
    return bounds;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    ////    创建画布
    //    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    ////    设置填充颜色
    //    CGContextSetFillColorWithColor(contextRef, [UIColor lightGrayColor].CGColor);
    ////    设置边界
    //    CGContextFillRect(contextRef, CGRectMake(35, self.frame.size.height - 0.5, self.frame.size.width - 35, 0.5));
}

#pragma mark - response Method
- (void)didClickedEyesBtn {
    self.secureTextEntry = !self.secureTextEntry;
}

#pragma mark - GETTER
- (UIButton *)eyesBtn {
    if (!_eyesBtn) {
        _eyesBtn = [[UIButton alloc] init];
        [_eyesBtn setBackgroundImage:[UIImage imageNamed:@"eyes"] forState:UIControlStateNormal];
        [_eyesBtn setBackgroundImage:[UIImage imageNamed:@"eyesHighLight"] forState:UIControlStateHighlighted];
        [_eyesBtn addTarget:self action:@selector(didClickedEyesBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_eyesBtn];
    }
    return _eyesBtn;
}

@end

