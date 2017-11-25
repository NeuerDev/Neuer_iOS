//
//  MeAboutViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeAboutViewController.h"

@interface MeAboutViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *sentenceLabel;
@property (nonatomic, strong) UIButton *joinGroupButton;
@end

@implementation MeAboutViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.6 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.sentenceLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 animations:^{
            self.joinGroupButton.alpha = 1;
        }];
    }];
}

- (void)initData {
    self.title = NSLocalizedString(@"MeMenuAboutTitle", nil);
    self.view.dk_backgroundColorPicker = DKColorPickerWithKey(background);
}

- (void)initConstraints {
    self.scrollView.frame = self.view.frame;
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.sentenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(48);
        make.left.equalTo(self.contentView.mas_left).with.offset(32);
        make.right.equalTo(self.contentView.mas_right).with.offset(-32);
    }];
    
    [self.joinGroupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(32);
        make.right.equalTo(self.contentView.mas_right).with.offset(-32);
        make.top.equalTo(self.sentenceLabel.mas_bottom).with.offset(48);
        make.height.mas_equalTo(@(44));
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-64);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Response Methods

- (void)onJoinGroupButtonClicked:(id)sender {
    if (![self joinGroup]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AboutJoinQQGroupFailTitle", nil) message:NSLocalizedString(@"AboutJoinQQGroupFailMessage", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"AboutJoinQQGroupFailAction", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
}

#pragma mark - Private

- (BOOL)joinGroup {
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", @"293552375", @"bce74527f493a756059fa4a535bf90240552905fb3d9dfe52516e61306c99652"];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
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

- (UILabel *)sentenceLabel {
    if (!_sentenceLabel) {
        _sentenceLabel = [[UILabel alloc] init];
        _sentenceLabel.numberOfLines = 0;
        _sentenceLabel.alpha = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *string = @"人生而不同，对世界的感恩之心也折射在不同的角落，创造美好，并示之世人，是其中一种。\n在这个创造美好的过程中，如果你投入了大量的情感，投入对世人的关心和爱，尽管你和他们从未见过、从未握手，也从未互相分享过各自的故事。\n但不知何故，当人们拿到产品时，会感受到其背后的情感流动。\n这就是我们表达对世界感恩的方式。\n所以，我们要坦诚面对自我，并记住，是什么让我们生而不同。";
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyle.lineSpacing = 8.0;
            paragraphStyle.paragraphSpacing = 16;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName:DKColorPickerWithKey(title)(DKNightVersionManager.sharedManager.themeVersion), NSTextEffectAttributeName:NSTextEffectLetterpressStyle, NSParagraphStyleAttributeName:paragraphStyle}];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle1] range:NSMakeRange(0, 1)];
//            [attributedString addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2] range:NSMakeRange(42, 1)];
//            [attributedString addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2] range:NSMakeRange(108, 1)];
//            [attributedString addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2] range:NSMakeRange(137, 1)];
//            [attributedString addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle2] range:NSMakeRange(154, 1)];
            _sentenceLabel.attributedText = attributedString;
        });
        [self.contentView addSubview:_sentenceLabel];
    }
    
    return _sentenceLabel;
}

- (UIButton *)joinGroupButton {
    if (!_joinGroupButton) {
        _joinGroupButton = [[UIButton alloc] init];
        _joinGroupButton.layer.cornerRadius = 44.0f/2.0f;
        _joinGroupButton.layer.shadowOffset = CGSizeMake(0, 2);
        _joinGroupButton.layer.shadowRadius = 4;
        _joinGroupButton.layer.shadowOpacity = 0.5;
        _joinGroupButton.layer.dk_shadowColorPicker = DKColorPickerWithKey(accent);
        _joinGroupButton.dk_backgroundColorPicker = DKColorPickerWithKey(accent);
        [_joinGroupButton setTitleColor:DKColorPickerWithKey(accenttext)(DKNightVersionManager.sharedManager.themeVersion) forState:UIControlStateNormal];
        _joinGroupButton.alpha = 0;
        [_joinGroupButton setTitle:NSLocalizedString(@"AboutJoinQQGroup", nil) forState:UIControlStateNormal];
        [_joinGroupButton addTarget:self action:@selector(onJoinGroupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_joinGroupButton];
    }
    
    return _joinGroupButton;
}

@end
