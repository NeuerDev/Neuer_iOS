//
//  EcardViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardMyViewController.h"

#import "EcardModel.h"

@interface EcardMyViewController () <EcardLoginDelegate, EcardInfoDelegate, EcardServiceDelegate>
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) EcardModel *ecardModel;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UIImageView *cardAvatarImageView;

@property (nonatomic, strong) UILabel *cardInfoLabel;
@end

@implementation EcardMyViewController

#pragma mark - Init Methods

- (instancetype)initWithEcardModel:(EcardModel *)model {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的校园卡";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initConstraints];
    
    [self test];
}

- (void)test {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 300, 200, 50)];
    imageView.backgroundColor = [UIColor beautyBlue];
    [self.view addSubview:imageView];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 350, 200, 50)];
    _textField.backgroundColor = [UIColor beautyPurple];
    [self.view addSubview:_textField];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 400, 200, 50)];
    button.backgroundColor = [UIColor beautyGreen];
    [button setTitle:@"login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self.ecardModel getVerifyImage:^(UIImage *verifyImage, NSString *message) {
        imageView.image = verifyImage;
    }];
}

- (void)initConstraints {
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.and.right.and.bottom.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(16);
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.height.equalTo(self.cardView.mas_width).multipliedBy(431.0f/686.0f);
        
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16);
    }];
    
    [self.cardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cardView);
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
    
    [self.view layoutIfNeeded];
    
    [_cardImageView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(16, 16)];
}

- (void)login {
    [self.ecardModel authorUser:@"20144786" password:@"951202" verifyCode:_textField.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EcardLoginDelegate

- (void)loginSuccess:(BOOL)success error:(NSError *)error {
    if (success) {
        [self.ecardModel queryInfo];
        [self.ecardModel fetchAvatar];
    }
}

#pragma mark - EcardInfoDelegate

- (void)fetchAvatarSuccess:(BOOL)success error:(NSError *)error {
    if (success) {
        _cardAvatarImageView.image = _ecardModel.info.avatarImage;
    }
}

- (void)queryInfoSuccess:(BOOL)success error:(NSError *)error {
    if (success) {
        NSString *string = [NSString stringWithFormat:@"姓   名: %@\n学   号: %@\n性   别: %@\n学   院: %@\n专   业: %@",
                               _ecardModel.info.name,
                               _ecardModel.info.number,
                               _ecardModel.info.sex,
                               _ecardModel.info.campus,
                               _ecardModel.info.major];
        NSDictionary<NSAttributedStringKey, id> *attributes = @{NSTextEffectAttributeName:NSTextEffectLetterpressStyle,NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]};
        _cardInfoLabel.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    }
}

- (void)queryConsumeHistorySuccess:(BOOL)success error:(NSError *)error {
    
}

- (void)queryConsumeStatisicsSuccess:(BOOL)success error:(NSError *)error {
    
}

#pragma mark - EcardServiceDelegate

- (void)reportLostSuccess:(BOOL)success error:(NSError *)error {
    
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_scrollView];
    }
    
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        
        [self.scrollView addSubview:_contentView];
    }
    
    return _contentView;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.layer.shadowColor = [UIColor beautyBlue].CGColor;
        _cardView.layer.shadowRadius = 4;
        _cardView.layer.shadowOffset = CGSizeMake(0, 4);
        _cardView.layer.shadowOpacity = 0.5;
        
        [self.contentView addSubview:_cardView];
    }
    
    return _cardView;
}

- (UIImageView *)cardImageView {
    if (!_cardImageView) {
        _cardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_me_background"]];
        _cardImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.cardView addSubview:_cardImageView];
    }
    
    return _cardImageView;
}

- (UIImageView *)cardAvatarImageView {
    if (!_cardAvatarImageView) {
        _cardAvatarImageView = [[UIImageView alloc] init];
        _cardAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.cardImageView addSubview:_cardAvatarImageView];
    }
    
    return _cardAvatarImageView;
}

- (UILabel *)cardInfoLabel {
    if (!_cardInfoLabel) {
        _cardInfoLabel = [[UILabel alloc] init];
        _cardInfoLabel.numberOfLines = 0;
        
        [self.cardImageView addSubview:_cardInfoLabel];
    }
    
    return _cardInfoLabel;
}

- (EcardModel *)ecardModel {
    if (!_ecardModel) {
        _ecardModel = [[EcardModel alloc] init];
        _ecardModel.loginDelegate = self;
        _ecardModel.infoDelegate = self;
        _ecardModel.serviceDelegate = self;
    }
    
    return _ecardModel;
}

@end
