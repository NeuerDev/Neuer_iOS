//
//  MyCardViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardMyViewController.h"
#import "EcardModel.h"

@interface EcardMyViewController ()
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UIImageView *cardAvatarImageView;
@property (nonatomic, strong) UILabel *cardInfoLabel;

@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation EcardMyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self initConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [self showCard];
}

- (void)showCard {
    [_cardImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).with.offset(0);
    }];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
        _cardImageView.alpha = 1;
    } completion:nil];
}

- (void)initConstraints {
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.cardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).with.offset(270);
        make.width.mas_equalTo(@(SCREEN_WIDTH_ACTUAL-32));
        make.height.equalTo(self.cardImageView.mas_width).multipliedBy(431.0f/686.0f);
    }];
    
    [self.cardAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.cardImageView).multipliedBy(0.565);
        make.width.equalTo(self.cardAvatarImageView.mas_height).multipliedBy(0.75);
        make.left.equalTo(self.cardImageView.mas_right).multipliedBy(0.05);
        make.top.equalTo(self.cardImageView.mas_bottom).multipliedBy(0.2);
    }];
    
    [self.cardInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardAvatarImageView.mas_right).with.offset(8);
        make.centerY.equalTo(self.cardAvatarImageView);
        make.right.equalTo(self.cardImageView.mas_right).multipliedBy(0.95);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.cardImageView.mas_bottom).with.offset(16);
    }];
    
    [self.view layoutIfNeeded];
    
    [_cardImageView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(16, 16)];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [_cardImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).with.offset(270);
    }];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
        _cardImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [_cardImageView removeFromSuperview];
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Respond Methods

- (void)onCardImageViewLongPressed:(UILongPressGestureRecognizer *)recognizer {
    
}

- (void)onBlurViewTapped:(UITapGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Getter

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [_blurView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBlurViewTapped:)]];
        [self.view addSubview:_blurView];
    }
    
    return _blurView;
}

- (UIImageView *)cardImageView {
    if (!_cardImageView) {
        _cardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_me_background"]];
        _cardImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_cardImageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onCardImageViewLongPressed:)]];
        _cardImageView.userInteractionEnabled = YES;
        _cardImageView.alpha = 0;
        [self.view addSubview:_cardImageView];
    }
    
    return _cardImageView;
}

- (UIImageView *)cardAvatarImageView {
    if (!_cardAvatarImageView) {
        _cardAvatarImageView = [[UIImageView alloc] init];
        _cardAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _cardAvatarImageView.image = _infoBean.avatarImage;
        [self.cardImageView addSubview:_cardAvatarImageView];
    }
    
    return _cardAvatarImageView;
}

- (UILabel *)cardInfoLabel {
    if (!_cardInfoLabel) {
        _cardInfoLabel = [[UILabel alloc] init];
        _cardInfoLabel.numberOfLines = 0;
        
        NSString *string = [NSString stringWithFormat:@"姓   名: %@\n学   号: %@\n性   别: %@\n学   院: %@\n专   业: %@",
                            _infoBean.name,
                            _infoBean.number,
                            _infoBean.sex,
                            _infoBean.campus,
                            _infoBean.major];
        NSDictionary<NSAttributedStringKey, id> *attributes = @{NSTextEffectAttributeName:NSTextEffectLetterpressStyle,NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]};
        _cardInfoLabel.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        [self.cardImageView addSubview:_cardInfoLabel];
    }
    
    return _cardInfoLabel;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.alpha = 0.6;
        _tipsLabel.text = @"长按校园卡保存到相册";
        [self.view addSubview:_tipsLabel];
    }
    
    return _tipsLabel;
}

@end
