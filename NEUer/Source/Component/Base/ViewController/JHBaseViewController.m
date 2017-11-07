//
//  JHBaseViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHBaseViewController.h"

@interface JHBaseViewController ()

@end

@implementation JHBaseViewController

#pragma mark - Init Methods

- (instancetype)initWithUrl:(NSURL *)url params:(NSDictionary *)params {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)handleUrl:(NSURL *)url params:(NSDictionary *)params {
    
}

- (void)initConstraints {
    [self.placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(SCREEN_WIDTH_ACTUAL);
        make.top.equalTo(self.view.mas_centerY);
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.placeholderView.mas_top);
        make.width.mas_equalTo(self.placeholderView);
        make.height.mas_equalTo(30);
    }];

    [self.detailLaebl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.label.mas_bottom).with.offset(10);
        make.left.equalTo(self.placeholderView.mas_left).with.offset(50);
        make.right.equalTo(self.placeholderView.mas_right).with.offset(-50);
        make.height.mas_equalTo(60);
    }];

    [self.retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.detailLaebl.mas_bottom).with.offset(30);
        make.height.mas_equalTo(50);
        make.width.equalTo(self.detailLaebl.mas_width).with.multipliedBy(0.5);
        make.centerX.equalTo(self.placeholderView);
        make.bottom.equalTo(self.placeholderView.mas_bottom);
    }];
}


#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Public Methods
- (void)showPlaceHolder {
    self.placeholderView.hidden = NO;
    self.activityIndicatorView.hidden = YES;
}

- (void)hidePlaceHolder {
    self.placeholderView.hidden = YES;
    self.activityIndicatorView.hidden = NO;
}

#pragma mark - Respond Methods
- (void)retry:(UIButton *)sender {
 
}

#pragma mark - Getter
- (UIView *)placeholderView {
    if (!_placeholderView) {
        _placeholderView = [[UIView alloc] init];
        [self.view addSubview:_placeholderView];
    }
   return _placeholderView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightRegular];
        _label.text = @"Page Not Found";
        [self.placeholderView addSubview:_label];
    }
   return _label;
}

- (UILabel *)detailLaebl {
    if (!_detailLaebl) {
        _detailLaebl = [[UILabel alloc] init];
        _detailLaebl.numberOfLines = 0;
        _detailLaebl.text = @"The page you are looking for doesn't seem to exist...";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_detailLaebl.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:8.0];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _detailLaebl.text.length)];
        _detailLaebl.attributedText = attributedString;
        _detailLaebl.textAlignment = NSTextAlignmentCenter;
        [self.placeholderView addSubview:_detailLaebl];
    }
   return _detailLaebl;
}

- (UIButton *)retryBtn {
    if (!_retryBtn) {
        _retryBtn = [[UIButton alloc] init];
        [_retryBtn setTitle:@"重    试" forState:UIControlStateNormal];
        [_retryBtn setBackgroundColor:[UIColor colorWithRed:0.45 green:0.58 blue:0.92 alpha:1.0]];
        _retryBtn.layer.cornerRadius = 25.0;
        [self.placeholderView addSubview:_retryBtn];
    }
   return _retryBtn;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        _activityIndicatorView.hidden = YES;
        [self.view addSubview:_activityIndicatorView];
    }
   return _activityIndicatorView;
}
@end
