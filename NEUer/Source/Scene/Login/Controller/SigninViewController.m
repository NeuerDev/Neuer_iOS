//
//  SigninViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SigninViewController.h"

typedef void(^SigninInputViewActionBlock)(void);

@interface SigninInputView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *verifyImageView;
@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) SigninInputViewActionBlock actionBlock;
@property (nonatomic, assign) SigninInputType type;

- (instancetype)initWithInputType:(SigninInputType)type;
- (instancetype)initWithInputType:(SigninInputType)type content:(NSString *)content;
- (instancetype)initWithInputType:(SigninInputType)type content:(NSString *)content actionBlock:(SigninInputViewActionBlock)actionBlock;

- (BOOL)legal;

@end

@implementation SigninInputView

#pragma mark - Init Methods

- (instancetype)initWithInputType:(SigninInputType)type {
    return [self initWithInputType:type content:nil actionBlock:nil];
}

- (instancetype)initWithInputType:(SigninInputType)type content:(NSString *)content {
    return [self initWithInputType:type content:content actionBlock:nil];
}

- (instancetype)initWithInputType:(SigninInputType)type content:(NSString *)content actionBlock:(SigninInputViewActionBlock)actionBlock {
    if (self = [super init]) {
        _type = type;
        _actionBlock = actionBlock;
        self.textField.text = content?:@"";
        [self initViews];
        [self initConstraints];
    }
    
    return self;
}

- (void)initViews {
    switch (_type) {
        case SigninInputTypeAccount:
        {
            self.titleLabel.text = @"学号";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
//            self.textField.textContentType = UITextContentTypeUsername;
//            self.textField.placeholder = @"请输入学号";
        }
            break;
        case SigninInputTypeIdentityNumber:
        {
            self.titleLabel.text = @"身份证";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
//            self.textField.placeholder = @"请输入身份证";
        }
            break;
        case SigninInputTypePassword:
        {
            self.titleLabel.text = @"密码";
            self.textField.secureTextEntry = YES;
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
//            self.textField.textContentType = UITextContentTypePassword;
            [self.actionButton setTitle:@"显示" forState:UIControlStateNormal];
            [self.actionButton setTitle:@"隐藏" forState:UIControlStateSelected];
//            self.textField.placeholder = @"请输入学号";
        }
            break;
        case SigninInputTypeNewPassword:
        {
            self.titleLabel.text = @"新密码";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            self.textField.secureTextEntry = YES;
//            self.textField.textContentType = UITextContentTypePassword;
            [self.actionButton setTitle:@"显示" forState:UIControlStateNormal];
            [self.actionButton setTitle:@"隐藏" forState:UIControlStateSelected];
//            self.textField.placeholder = @"请输入新密码";
        }
            break;
        case SigninInputTypeRePassword:
        {
            self.titleLabel.text = @"确认密码";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            self.textField.secureTextEntry = YES;
//            self.textField.textContentType = UITextContentTypePassword;
            [self.actionButton setTitle:@"显示" forState:UIControlStateNormal];
            [self.actionButton setTitle:@"隐藏" forState:UIControlStateSelected];
//            self.textField.placeholder = @"再次输入新密码";
        }
            break;
        case SigninInputTypeVerifyCode:
        {
            self.titleLabel.text = @"验证码";
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            [self.actionButton setTitle:@"刷新" forState:UIControlStateNormal];
//            self.textField.placeholder = @"";
        }
            break;
            
        default:
            break;
    }
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self);
    }];
    
    if (_type&SigninInputTypePassword
         || _type&SigninInputTypeRePassword
         || _type&SigninInputTypeVerifyCode) {
        [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.lastBaseline.equalTo(self.titleLabel.mas_lastBaseline);
            make.right.equalTo(self.mas_right);
        }];
    }
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(8);
        make.left.equalTo(self);
        if (_type&SigninInputTypeVerifyCode) {
            make.right.equalTo(self.verifyImageView.mas_left).with.offset(-8);
        } else {
            make.right.equalTo(self);
        }
    }];
    
    if (_type&SigninInputTypeVerifyCode) {
        [self.verifyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textField).with.offset(-4);
            make.bottom.equalTo(self.textField.mas_bottom).with.offset(4);
            make.right.equalTo(self);
            make.width.mas_equalTo(@(96));
        }];
    }
    
    [self.seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textField.mas_bottom).with.offset(4);
        make.left.and.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(@(1));
    }];
        
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
    if (_type&SigninInputTypePassword
           || _type&SigninInputTypeRePassword
           || _type&SigninInputTypeVerifyCode) {
        _textField.secureTextEntry = !_textField.secureTextEntry;
        _actionButton.selected = !_actionButton.selected;
    }
    
    if (_type&SigninInputTypeVerifyCode) {
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

@interface SigninViewController () <UITextFieldDelegate>
@property (nonatomic, strong) SigninResultBlock resultBlock;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIVisualEffectView *maskView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSArray<SigninInputView *> *inputViews;
@property (nonatomic, strong) UIButton *loginButton;
@end

@implementation SigninViewController {
    CGFloat _originY;
    CGFloat _viewBeginY;
    CGFloat _touchBeginY;
    CGFloat _contentHeight;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _contentHeight = SCREEN_HEIGHT_ACTUAL*0.9;
    _originY = SCREEN_HEIGHT_ACTUAL - _contentHeight;
    self.maskView.frame = CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL);
    self.contentView.frame = CGRectMake(8, SCREEN_HEIGHT_ACTUAL, SCREEN_WIDTH_ACTUAL-16, SCREEN_HEIGHT_ACTUAL);
    self.titleLabel.text = self.title;
    
    [self initConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showContentView];
    [self refreshViewState];
}

- (void)initConstraints {
    UIView *lastView = [_inputViews firstObject];
    [self.contentView addSubview:lastView];
    if (lastView) {
        [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(128);
            make.left.equalTo(self.contentView.mas_left).with.offset(24);
            make.right.equalTo(self.contentView.mas_right).with.offset(-24);
        }];
        
        for (NSInteger index = 1; index<_inputViews.count; index++) {
            UIView *view = _inputViews[index];
            [self.contentView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastView.mas_bottom).with.offset(24);
                make.left.and.right.equalTo(lastView);
            }];
            lastView = view;
        }
    }
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(24);
        make.top.equalTo(self.contentView.mas_top).with.offset(64);
    }];
    
    lastView = lastView ? : self.titleLabel;
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(24);
        make.right.equalTo(self.contentView.mas_right).with.offset(-24);
        make.top.equalTo(lastView.mas_bottom).with.offset(48);
        make.height.mas_equalTo(@(44));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Public Methods

- (void)setupWithTitle:(NSString *)title inputType:(SigninInputType)inputType resultBlock:(SigninResultBlock)resultBlock {
    [self setupWithTitle:title inputType:inputType contents:nil resultBlock:resultBlock];
}

- (void)setupWithTitle:(NSString *)title inputType:(SigninInputType)inputType contents:(NSDictionary<NSNumber *,NSString *> *)contents resultBlock:(SigninResultBlock)resultBlock {
    WS(ws);
    _resultBlock = resultBlock;
    NSDictionary *dictionary = contents?:@{};
    NSMutableArray<SigninInputView *> *inputViews = @[].mutableCopy;
    if (inputType & SigninInputTypeAccount) {
        [inputViews addObject:[[SigninInputView alloc] initWithInputType:SigninInputTypeAccount content:dictionary[@(SigninInputTypeAccount)]]];
    }
    if (inputType & SigninInputTypeIdentityNumber) {
        [inputViews addObject:[[SigninInputView alloc] initWithInputType:SigninInputTypeIdentityNumber content:dictionary[@(SigninInputTypeIdentityNumber)]]];
    }
    if (inputType & SigninInputTypePassword) {
        [inputViews addObject:[[SigninInputView alloc] initWithInputType:SigninInputTypePassword content:dictionary[@(SigninInputTypePassword)]]];
    }
    if (inputType & SigninInputTypeNewPassword) {
        [inputViews addObject:[[SigninInputView alloc] initWithInputType:SigninInputTypeNewPassword content:dictionary[@(SigninInputTypeNewPassword)]]];
    }
    if (inputType & SigninInputTypeRePassword) {
        [inputViews addObject:[[SigninInputView alloc] initWithInputType:SigninInputTypeRePassword content:dictionary[@(SigninInputTypeRePassword)]]];
    }
    if (inputType & SigninInputTypeVerifyCode) {
        [inputViews addObject:[[SigninInputView alloc] initWithInputType:SigninInputTypeVerifyCode content:dictionary[@(SigninInputTypeVerifyCode)] actionBlock:^{
            if (ws.changeVerifyImageBlock) {
                ws.changeVerifyImageBlock();
            }
        }]];
    }
    self.title = title;
    self.inputViews = inputViews;
}

#pragma mark - Touches Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
    [self expandHeader];
    _touchBeginY = [[touches anyObject] locationInView:self.view].y;
    _viewBeginY = CGRectGetMinY(self.contentView.frame);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    CGFloat currentY = [[touches anyObject] locationInView:self.view].y;
    CGFloat offset = _touchBeginY - currentY;
    self.contentView.frame = ({
        CGRect frame = self.contentView.frame;
        CGPoint origin = self.contentView.frame.origin;
        if (origin.y > _originY) {
            origin.y = _viewBeginY - offset;
        } else {
            origin.y = _viewBeginY - offset*pow(0.3, (offset+_contentHeight)/_contentHeight);
        }
        frame.origin = origin;
        frame;
    });
    CGFloat percent = (SCREEN_HEIGHT_ACTUAL - CGRectGetMinY(self.contentView.frame))/_contentHeight;
    self.maskView.alpha = percent;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    CGFloat currentY = CGRectGetMinY(self.contentView.frame);
    if (currentY > _originY+_contentHeight/5) {
        [self.contentView.layer removeAllAnimations];
        [self hideContentView];
    } else {
        [self showContentView];
    }
}

#pragma mark - Private Methods

- (void)showContentView {
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        self.maskView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.maskView.alpha = 1;
        self.contentView.frame = CGRectMake(8, SCREEN_HEIGHT_ACTUAL-_contentHeight, SCREEN_WIDTH_ACTUAL-16, SCREEN_HEIGHT_ACTUAL);
    } completion:nil];
}

- (void)hideContentView {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.maskView.alpha = 0;
        self.contentView.frame = CGRectMake(8, SCREEN_HEIGHT_ACTUAL, SCREEN_WIDTH_ACTUAL-16, SCREEN_HEIGHT_ACTUAL);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
        [self clear];
    }];
}

- (void)collapseHeader {
    UIView *lastView = [_inputViews firstObject];
    if (lastView) {
        [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(24);
        }];
    }
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(16);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.titleLabel.alpha = 0;
    } completion:nil];
}

- (void)expandHeader {
    UIView *lastView = [_inputViews firstObject];
    if (lastView) {
        [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(128);
        }];
    }
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(64);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.titleLabel.alpha = 1;
    } completion:nil];
}

- (void)clear {
    if (_inputViews) {
        for (SigninInputView *view in _inputViews) {
            [view removeFromSuperview];
        }
    }
}

- (void)refreshViewState {
    BOOL isLegal = YES;
    for (SigninInputView *inputView in _inputViews) {
        if (inputView.legal) {
            continue;
        } else {
            isLegal = NO;
            break;
        }
    }
    
    if (isLegal) {
        _loginButton.enabled = YES;
        _loginButton.backgroundColor = [UIColor beautyBlue];
    } else {
        _loginButton.enabled = NO;
        _loginButton.backgroundColor = [[UIColor beautyBlue] colorWithAlphaComponent:0.5];
    }
    
    for (SigninInputView *inputView in _inputViews) {
        if ([inputView.textField isFirstResponder]) {
            inputView.textField.textColor = [UIColor blackColor];
            inputView.seperatorLine.backgroundColor = [UIColor blackColor];
        } else {
            inputView.textField.textColor = [UIColor lightGrayColor];
            inputView.seperatorLine.backgroundColor = [UIColor lightGrayColor];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_inputViews.lastObject.textField]) {
        [textField resignFirstResponder];
        [self expandHeader];
    } else {
        for (NSInteger index = 0; index<_inputViews.count; index++) {
            if ([textField isEqual:_inputViews[index].textField]) {
                [_inputViews[index+1].textField becomeFirstResponder];
                break;
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self collapseHeader];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self refreshViewState];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self refreshViewState];
}

#pragma mark - Respond Methods

- (void)didMaskViewTapped:(UITapGestureRecognizer *)tap {
    [self hideContentView];
    // 用户关闭登录框
    if (_resultBlock) {
        _resultBlock(nil, NO);
    }
}

- (void)didLoginButtonTapped:(id)sender {
    [self hideContentView];
    // 点击登录
    if (_resultBlock) {
        NSMutableDictionary<NSNumber *, NSString *> *result = @{}.mutableCopy;
        for (SigninInputView *inputView in _inputViews) {
            [result setObject:inputView.textField.text?:@"" forKey:@(inputView.type)];
        }
        _resultBlock(result.copy, YES);
    }
}

#pragma mark - Setter

- (void)setInputViews:(NSArray<SigninInputView *> *)inputViews {
    _inputViews = inputViews;
    for (SigninInputView *inputView in inputViews) {
        inputView.textField.delegate = self;
        if ([inputView isEqual:inputViews.lastObject]) {
            inputView.textField.returnKeyType = UIReturnKeyDone;
        } else {
            inputView.textField.returnKeyType = UIReturnKeyNext;
        }
    }
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 8;
        [self.view addSubview:_contentView];
    }
    
    return _contentView;
}

- (UIVisualEffectView *)maskView {
    if (!_maskView) {
        _maskView = [[UIVisualEffectView alloc] init];
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didMaskViewTapped:)]];
        [self.view addSubview:_maskView];
    }
    
    return _maskView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle];
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [[UIButton alloc] init];
        [_loginButton setTitle:@"确认" forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(didLoginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_loginButton];
    }
    
    return _loginButton;
}

@end
