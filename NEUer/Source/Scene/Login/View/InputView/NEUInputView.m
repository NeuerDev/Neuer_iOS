//
//  LoginInputView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/12.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NEUInputView.h"

@implementation NEUInputView

#pragma mark - Init Methods

- (instancetype)init {
    return [self initWithInputType:NEUInputTypeDefault];
}

- (instancetype)initWithInputType:(NEUInputType)type {
    return [self initWithInputType:type content:nil actionBlock:nil];
}

- (instancetype)initWithInputType:(NEUInputType)type content:(NSString *)content {
    return [self initWithInputType:type content:content actionBlock:nil];
}

- (instancetype)initWithInputType:(NEUInputType)type content:(NSString *)content actionBlock:(NEUInputViewActionBlock)actionBlock {
    if (self = [super init]) {
        _type = type;
        _actionBlock = actionBlock;
        self.textField.text = content;
        if (type==NEUInputTypeAccount && content.length>0) {
            self.textField.enabled = NO;
        }
        [self initViews];
        [self initConstraints];
    }
    
    return self;
}

- (void)initViews {
    switch (_type) {
        case NEUInputTypeAccount:
        {
            self.titleLabel.text = @"学号";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
        }
            break;
        case NEUInputTypeIdentityNumber:
        {
            self.titleLabel.text = @"身份证";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
        }
            break;
        case NEUInputTypePassword:
        {
            self.titleLabel.text = @"密码";
            self.textField.secureTextEntry = YES;
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            [self.actionButton setTitle:@"显示" forState:UIControlStateNormal];
            [self.actionButton setTitle:@"隐藏" forState:UIControlStateSelected];
            //            self.textField.placeholder = @"请输入学号";
        }
            break;
        case NEUInputTypeNewPassword:
        {
            self.titleLabel.text = @"新密码";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            self.textField.secureTextEntry = YES;
            [self.actionButton setTitle:@"显示" forState:UIControlStateNormal];
            [self.actionButton setTitle:@"隐藏" forState:UIControlStateSelected];
            //            self.textField.placeholder = @"请输入新密码";
        }
            break;
        case NEUInputTypeRePassword:
        {
            self.titleLabel.text = @"确认密码";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            self.textField.secureTextEntry = YES;
            [self.actionButton setTitle:@"显示" forState:UIControlStateNormal];
            [self.actionButton setTitle:@"隐藏" forState:UIControlStateSelected];
        }
            break;
        case NEUInputTypeVerifyCode:
        {
            self.titleLabel.text = @"验证码";
            self.infoLabel.text = @"尽力识别了_(:з」∠)_";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            [self.actionButton setTitle:@"换一张" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).with.offset(8);
        make.lastBaseline.equalTo(self.titleLabel.mas_lastBaseline);
    }];
    
    if (_type&NEUInputTypePassword
        || _type&NEUInputTypeRePassword
        || _type&NEUInputTypeVerifyCode) {
        [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.lastBaseline.equalTo(self.titleLabel.mas_lastBaseline);
            make.right.equalTo(self.mas_right);
        }];
    }
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(8);
        make.left.equalTo(self);
        if (_type&NEUInputTypeVerifyCode) {
            make.right.equalTo(self.verifyImageView.mas_left).with.offset(-8);
        } else {
            make.right.equalTo(self);
        }
    }];
    
    if (_type&NEUInputTypeVerifyCode) {
        [self.verifyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textField).with.offset(-4);
            make.bottom.equalTo(self.textField.mas_bottom).with.offset(8);
            make.right.equalTo(self);
            make.width.mas_equalTo(@(96));
        }];
        [self.seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textField.mas_bottom).with.offset(4);
            make.left.equalTo(self);
            make.right.equalTo(self.verifyImageView.mas_left).with.offset(-8);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(@(1));
        }];
    } else {
        [self.seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textField.mas_bottom).with.offset(4);
            make.left.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(@(1));
        }];
    }
}

#pragma mark - Public Methods

- (BOOL)legal {
    BOOL legal = NO;
    
    if (_textField.text.length>0) {
        legal = YES;
    }
    
    return legal;
}

#pragma mark - Response Methods

- (void)onActionButtonClicked:(id)sender {
    if (_type&NEUInputTypePassword
        || _type&NEUInputTypeRePassword
        || _type&NEUInputTypeNewPassword) {
        _textField.secureTextEntry = !_textField.secureTextEntry;
        _actionButton.selected = !_actionButton.selected;
    }
    
    if (_type&NEUInputTypeVerifyCode) {
        if (_actionBlock) {
            _actionBlock();
        }
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _titleLabel.textColor = [UIColor colorWithHexStr:@"#4C4C4C"];
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _infoLabel.textColor = [UIColor colorWithHexStr:@"#5C5C5C"];
        [self addSubview:_infoLabel];
    }
    
    return _infoLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        _actionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        [_actionButton addTarget:self action:@selector(onActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setTitleColor:[UIColor colorWithHexStr:@"#4C4C4C"] forState:UIControlStateNormal];
        [self addSubview:_actionButton];
    }
    
    return _actionButton;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.smartDashesType = UITextSmartDashesTypeNo;
        _textField.smartQuotesType = UITextSmartQuotesTypeNo;
        _textField.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
        [self addSubview:_textField];
    }
    
    return _textField;
}

- (UIImageView *)verifyImageView {
    if (!_verifyImageView) {
        _verifyImageView = [[UIImageView alloc] init];
        _verifyImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_verifyImageView];
    }
    
    return _verifyImageView;
}

- (UIView *)seperatorLine {
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = [UIColor colorWithHexStr:@"#EDECED"];
        [self addSubview:_seperatorLine];
    }
    
    return _seperatorLine;
}

@end
