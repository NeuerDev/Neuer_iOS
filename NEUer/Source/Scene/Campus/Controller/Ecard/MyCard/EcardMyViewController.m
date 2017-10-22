//
//  MyCardViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardMyViewController.h"
#import "EcardModel.h"

#import <Photos/Photos.h>

@interface EcardMyViewController ()
@property (nonatomic, copy) EcardInfoBean *infoBean;
@property (nonatomic, copy) EcardModel *ecardModel;

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UIImageView *cardAvatarImageView;
@property (nonatomic, strong) UILabel *cardInfoLabel;

@property (nonatomic, strong) UIActivityIndicatorView *cardAvatarIndicator;
@property (nonatomic, strong) UIButton *tipsButton;

@end

@implementation EcardMyViewController

#pragma mark - Life Circle

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
    
    WS(ws);
    [self.ecardModel fetchAvatarComplete:^(BOOL success, NSError *error) {
        if (success) {
            ws.cardAvatarImageView.image = ws.infoBean.image;
        }
    }];
    
    NSString *string = [NSString stringWithFormat:@"姓   名: %@\n学   号: %@\n性   别: %@\n学   院: %@\n专   业: %@",
                        self.infoBean.name,
                        self.infoBean.number,
                        self.infoBean.sex,
                        self.infoBean.campus,
                        self.infoBean.major];
    NSDictionary<NSAttributedStringKey, id> *attributes = @{NSTextEffectAttributeName:NSTextEffectLetterpressStyle,NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]};
    _cardInfoLabel.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
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
    
    [self.cardAvatarIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.cardAvatarImageView);
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
    
    [self.tipsButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    UIImage *image = [JHTool createImageWithView:self.cardImageView];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
//                [_tipsButton setTitle:@"保存成功，点击打开相册" forState:UIControlStateNormal];
                [_tipsButton setTitle:@"已保存到系统相册" forState:UIControlStateNormal];
//                [_tipsButton addTarget:self action:@selector(openGallary) forControlEvents:UIControlEventTouchUpInside];
            } else {
//                [_tipsButton setTitle:@"保存失败，点击检查是否开启相册访问权限" forState:UIControlStateNormal];
                [_tipsButton setTitle:@"保存失败，请检查是否开启相册访问权限" forState:UIControlStateNormal];
//                [_tipsButton addTarget:self action:@selector(openSetting) forControlEvents:UIControlEventTouchUpInside];
            }
        });
    }];
}

- (void)onBlurViewTapped:(UITapGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)openGallary {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"Photos://"] options:@{} completionHandler:nil];
}

- (void)openSetting {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"] options:@{} completionHandler:nil];
}

#pragma mark - Getter

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
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
        _cardAvatarImageView.image = self.infoBean.image;
        [self.cardImageView addSubview:_cardAvatarImageView];
    }
    
    return _cardAvatarImageView;
}

- (UILabel *)cardInfoLabel {
    if (!_cardInfoLabel) {
        _cardInfoLabel = [[UILabel alloc] init];
        _cardInfoLabel.numberOfLines = 0;
        
        NSString *string = @"姓   名: \n学   号: \n性   别: \n学   院: \n专   业: ";
        NSDictionary<NSAttributedStringKey, id> *attributes = @{NSTextEffectAttributeName:NSTextEffectLetterpressStyle,NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]};
        _cardInfoLabel.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        [self.cardImageView addSubview:_cardInfoLabel];
    }
    
    return _cardInfoLabel;
}

- (UIActivityIndicatorView *)cardAvatarIndicator {
    if (!_cardAvatarIndicator) {
        _cardAvatarIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_cardAvatarIndicator startAnimating];
        [self.cardImageView addSubview:_cardAvatarIndicator];
    }
    
    return _cardAvatarIndicator;
}

- (UIButton *)tipsButton {
    if (!_tipsButton) {
        _tipsButton = [[UIButton alloc] init];
        _tipsButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        [_tipsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _tipsButton.alpha = 0.7;
        [_tipsButton setTitle:@"长按校园卡保存到相册" forState:UIControlStateNormal];
        [self.view addSubview:_tipsButton];
    }
    
    return _tipsButton;
}

- (EcardInfoBean *)infoBean {
    if (!_infoBean) {
        _infoBean = self.ecardModel.info;
    }
    return _infoBean;
}

- (EcardModel *)ecardModel {
    if (!_ecardModel) {
        _ecardModel = [[EcardCenter defaultCenter] currentModel];
    }
    
    return _ecardModel;
}

@end
