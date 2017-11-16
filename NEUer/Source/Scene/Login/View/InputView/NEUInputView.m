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
    [self.textField addTarget:self action:@selector(onTextFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    self.titleLabel.alpha = self.textField.text.length > 0 ? 1 : 0;
    switch (_type) {
        case NEUInputTypeAccount:
        {
            self.titleLabel.text = NSLocalizedString(@"LoginAccountHint", nil);
            self.textField.placeholder = NSLocalizedString(@"LoginAccountHint", nil);
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
        }
            break;
        case NEUInputTypeIdentityNumber:
        {
            self.titleLabel.text = NSLocalizedString(@"LoginIdentityNumberHint", nil);
            self.textField.placeholder = NSLocalizedString(@"LoginIdentityNumberHint", nil);
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
        }
            break;
        case NEUInputTypePassword:
        {
            self.titleLabel.text = NSLocalizedString(@"LoginPasswordHint", nil);
            self.textField.placeholder = NSLocalizedString(@"LoginPasswordHint", nil);
            self.textField.secureTextEntry = YES;
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            [self.actionButton setTitle:NSLocalizedString(@"LoginActionTitleShow", nil) forState:UIControlStateNormal];
            [self.actionButton setTitle:NSLocalizedString(@"LoginActionTitleHide", nil) forState:UIControlStateSelected];
            //            self.textField.placeholder = @"请输入学号";
        }
            break;
        case NEUInputTypeNewPassword:
        {
            self.titleLabel.text = NSLocalizedString(@"LoginNewPasswordHint", nil);
            self.textField.placeholder = NSLocalizedString(@"LoginNewPasswordHint", nil);
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            self.textField.secureTextEntry = YES;
            [self.actionButton setTitle:NSLocalizedString(@"LoginActionTitleShow", nil) forState:UIControlStateNormal];
            [self.actionButton setTitle:NSLocalizedString(@"LoginActionTitleHide", nil) forState:UIControlStateSelected];
            //            self.textField.placeholder = @"请输入新密码";
        }
            break;
        case NEUInputTypeRePassword:
        {
            self.titleLabel.text = NSLocalizedString(@"LoginRePasswordHint", nil);
            self.textField.placeholder = NSLocalizedString(@"LoginRePasswordHint", nil);
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            self.textField.secureTextEntry = YES;
            [self.actionButton setTitle:NSLocalizedString(@"LoginActionTitleShow", nil) forState:UIControlStateNormal];
            [self.actionButton setTitle:NSLocalizedString(@"LoginActionTitleHide", nil) forState:UIControlStateSelected];
        }
            break;
        case NEUInputTypeVerifyCode:
        {
            self.titleLabel.text = NSLocalizedString(@"LoginVerifyCodeHint", nil);
            self.textField.placeholder = NSLocalizedString(@"LoginVerifyCodeHint", nil);
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            [self.actionButton setTitle:NSLocalizedString(@"LoginActionTitleRefresh", nil) forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        if (_textField.text.length>0) {
            make.lastBaseline.equalTo(self.mas_top).with.offset(16);
        } else {
            make.lastBaseline.equalTo(self.mas_top).with.offset(36);
        }
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).with.offset(8);
        make.lastBaseline.equalTo(self.mas_top).with.offset(16);
    }];
    
    if (_type&NEUInputTypePassword
        || _type&NEUInputTypeRePassword
        || _type&NEUInputTypeVerifyCode) {
        [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.lastBaseline.equalTo(self.mas_top).with.offset(16);
            make.right.equalTo(self.mas_right);
        }];
    }
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(24);
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

- (void)refreshViewState {
    if ([_textField isFirstResponder]) {
        [UIView animateWithDuration:0.3 animations:^{
            _textField.textColor = [UIColor blackColor];
            _titleLabel.textColor = [UIColor blackColor];
            _seperatorLine.backgroundColor = [UIColor blackColor];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _textField.textColor = [UIColor colorWithHexStr:@"9C9C9C"];
            _titleLabel.textColor = [UIColor colorWithHexStr:@"9C9C9C"];
            _seperatorLine.backgroundColor = [UIColor colorWithHexStr:@"9C9C9C"];
        }];
    }
    
    [self onTextFieldTextChange:_textField];
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

- (void)onTextFieldTextChange:(UITextField *)textField {
    if (textField.text.length>0) {
        [self showTitleLabelAnimated:YES];
    } else {
        [self hideTitleLabelAnimated:YES];
    }
}

#pragma mark - Private Methods

- (void)showTitleLabelAnimated:(BOOL)animated {
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.lastBaseline.equalTo(self.mas_top).with.offset(16);
    }];
    if (animated) {
        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _titleLabel.alpha = 1;
            [self layoutIfNeeded];
        } completion:nil];
    } else {
        _titleLabel.alpha = 1;
        [self layoutIfNeeded];
    }
}

- (void)hideTitleLabelAnimated:(BOOL)animated {
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.lastBaseline.equalTo(self.mas_top).with.offset(36);
    }];
    if (animated) {
        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _titleLabel.alpha = 0;
            [self layoutIfNeeded];
        } completion:nil];
    } else {
        _titleLabel.alpha = 0;
        [self layoutIfNeeded];
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _titleLabel.textColor = [UIColor colorWithHexStr:@"#9C9C9C"];
        _titleLabel.alpha = 0;
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _infoLabel.textColor = [UIColor colorWithHexStr:@"#9C9C9C"];
        [self addSubview:_infoLabel];
    }
    
    return _infoLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        _actionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        [_actionButton addTarget:self action:@selector(onActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setTitleColor:[UIColor colorWithHexStr:@"#9C9C9C"] forState:UIControlStateNormal];
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
        _textField.tintColor = [UIColor beautyBlue];
        if (@available(iOS 11.0, *)) {
            _textField.smartDashesType = UITextSmartDashesTypeNo;
            _textField.smartQuotesType = UITextSmartQuotesTypeNo;
            _textField.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
        }
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
