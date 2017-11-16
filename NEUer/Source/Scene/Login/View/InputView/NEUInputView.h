//
//  LoginInputView.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/12.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - LoginInputView

typedef void(^NEUInputViewActionBlock)(void);

typedef NS_OPTIONS(NSUInteger, NEUInputType) {
    NEUInputTypeDefault         = 0,
    NEUInputTypeAccount         = 1 << 0,
    NEUInputTypeIdentityNumber  = 1 << 1,
    NEUInputTypePassword        = 1 << 2,
    NEUInputTypeNewPassword     = 1 << 3,
    NEUInputTypeRePassword      = 1 << 4,
    NEUInputTypeVerifyCode      = 1 << 5,
};

@interface NEUInputView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *verifyImageView;
@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) NEUInputViewActionBlock actionBlock;
@property (nonatomic, assign) NEUInputType type;

- (instancetype)initWithInputType:(NEUInputType)type;
- (instancetype)initWithInputType:(NEUInputType)type content:(NSString *)content;
- (instancetype)initWithInputType:(NEUInputType)type content:(NSString *)content actionBlock:(NEUInputViewActionBlock)actionBlock;
- (void)refreshViewState;
- (BOOL)legal;

@end
