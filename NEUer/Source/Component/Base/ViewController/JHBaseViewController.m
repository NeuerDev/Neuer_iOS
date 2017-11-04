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
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.mas_equalTo(SCREEN_WIDTH_ACTUAL);
        make.height.mas_equalTo(60);
    }];
    
    [self.detailLaebl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.label);
        make.top.equalTo(self.label.mas_bottom);
        make.width.height.equalTo(self.label);
    }];
    
    [self.retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.detailLaebl);
        make.top.equalTo(self.detailLaebl.mas_bottom);
        make.width.height.equalTo(self.detailLaebl);
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
- (void)showLabel {
    _label.hidden = NO;
    _detailLaebl.hidden = NO;
    _retryBtn.hidden = NO;
}

- (void)hideLabel {
    _label.hidden = YES;
    _detailLaebl.hidden = YES;
    _retryBtn.hidden = YES;
}

#pragma mark - Respond Methods
- (void)retry:(UIButton *)sender {
   
}

#pragma mark - Getter
- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.hidden = YES;
        [self.view addSubview:_label];
    }
   return _label;
}

- (UILabel *)detailLaebl {
    if (!_detailLaebl) {
        _detailLaebl = [[UILabel alloc] init];
        _detailLaebl.hidden = YES;
        [self.view addSubview:_detailLaebl];
    }
   return _detailLaebl;
}

- (UIButton *)retryBtn {
    if (!_retryBtn) {
        _retryBtn = [[UIButton alloc] init];
        _retryBtn.hidden = YES;
        [self.view addSubview:_retryBtn];
    }
   return _retryBtn;
}
@end
