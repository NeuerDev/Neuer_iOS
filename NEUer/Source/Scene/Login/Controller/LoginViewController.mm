//
//  SigninViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TesseractCenter.h"
#import "LoginViewController.h"

#pragma mark - LoginViewController

@interface LoginViewController () <UITextFieldDelegate, G8TesseractDelegate>
@property (nonatomic, strong) SigninResultBlock resultBlock;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIVisualEffectView *maskView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSArray<NEUInputView *> *inputViews;
@property (nonatomic, strong) UIButton *loginButton;
@end

@implementation LoginViewController {
    CGFloat _originY;
    CGFloat _viewBeginY;
    CGFloat _touchBeginY;
    CGFloat _contentHeight;
    BOOL _complete;
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
    [self refreshViewState];
}

- (void)viewDidAppear:(BOOL)animated {
    [self showContentView];
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
                make.left.right.equalTo(lastView);
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

- (void)setupWithTitle:(NSString *)title inputType:(NEUInputType)inputType resultBlock:(SigninResultBlock)resultBlock {
    [self setupWithTitle:title inputType:inputType contents:nil resultBlock:resultBlock];
}

- (void)setupWithTitle:(NSString *)title inputType:(NEUInputType)inputType contents:(NSDictionary<NSNumber *,NSString *> *)contents resultBlock:(SigninResultBlock)resultBlock {
    WS(ws);
    _resultBlock = resultBlock;
    NSDictionary *dictionary = contents?:@{};
    NSMutableArray<NEUInputView *> *inputViews = @[].mutableCopy;
    if (inputType & NEUInputTypeAccount) {
        [inputViews addObject:[[NEUInputView alloc] initWithInputType:NEUInputTypeAccount content:dictionary[@(NEUInputTypeAccount)]]];
    }
    if (inputType & NEUInputTypeIdentityNumber) {
        [inputViews addObject:[[NEUInputView alloc] initWithInputType:NEUInputTypeIdentityNumber content:dictionary[@(NEUInputTypeIdentityNumber)]]];
    }
    if (inputType & NEUInputTypePassword) {
        [inputViews addObject:[[NEUInputView alloc] initWithInputType:NEUInputTypePassword content:dictionary[@(NEUInputTypePassword)]]];
    }
    if (inputType & NEUInputTypeNewPassword) {
        [inputViews addObject:[[NEUInputView alloc] initWithInputType:NEUInputTypeNewPassword content:dictionary[@(NEUInputTypeNewPassword)]]];
    }
    if (inputType & NEUInputTypeRePassword) {
        [inputViews addObject:[[NEUInputView alloc] initWithInputType:NEUInputTypeRePassword content:dictionary[@(NEUInputTypeRePassword)]]];
    }
    if (inputType & NEUInputTypeVerifyCode) {
        NEUInputView *inputView = [[NEUInputView alloc] initWithInputType:NEUInputTypeVerifyCode content:dictionary[@(NEUInputTypeVerifyCode)] actionBlock:^{
            if (ws.changeVerifyImageBlock) {
                ws.changeVerifyImageBlock();
            }
        }];
        inputView.verifyImageView.image = _verifyImage;
        [inputViews addObject:inputView];
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
        [self dismissViewControllerAnimated:NO completion:^{
            [self clear];
            if (_complete) {
                // 点击登录
                if (_resultBlock) {
                    NSMutableDictionary<NSNumber *, NSString *> *result = @{}.mutableCopy;
                    for (NEUInputView *inputView in _inputViews) {
                        [result setObject:inputView.textField.text?:@"" forKey:@(inputView.type)];
                    }
                    _resultBlock(result.copy, YES);
                }
            } else {
                // 用户关闭登录框
                if (_resultBlock) {
                    _resultBlock(nil, NO);
                }
            }
        }];
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
        for (NEUInputView *view in _inputViews) {
            [view removeFromSuperview];
        }
    }
}

- (void)refreshViewState {
    BOOL isLegal = YES;
    for (NEUInputView *inputView in _inputViews) {
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
    
    for (NEUInputView *inputView in _inputViews) {
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
}

- (void)didLoginButtonTapped:(id)sender {
    _complete = YES;
    [self hideContentView];
}

#pragma mark - Setter

- (void)setInputViews:(NSArray<NEUInputView *> *)inputViews {
    _inputViews = inputViews;
    for (NEUInputView *inputView in inputViews) {
        inputView.textField.delegate = self;
        if ([inputView isEqual:inputViews.lastObject]) {
            inputView.textField.returnKeyType = UIReturnKeyDone;
        } else {
            inputView.textField.returnKeyType = UIReturnKeyNext;
        }
    }
}

- (void)setVerifyImage:(UIImage *)verifyImage {
    _verifyImage = verifyImage;
    for (NEUInputView *inputView in _inputViews) {
        if (inputView.type&NEUInputTypeVerifyCode) {
            inputView.verifyImageView.image = verifyImage;
            // try to use ocr
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                G8Tesseract *tesseract = [TesseractCenter defaultCenter].tesseract;
                tesseract.image = verifyImage;
                if ([tesseract recognize]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        inputView.textField.text = [[tesseract.recognizedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
                        [self refreshViewState];
                    });
                }
            });
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
