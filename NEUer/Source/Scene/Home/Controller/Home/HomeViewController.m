//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeViewController.h"

#import "TelevisionWallViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *calendarLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"HomeNavigationBarTitle", nil);
    
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"校内电视" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor blueColor];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.frame = CGRectMake(100, 300, 200, 100);
    
    self.navigationItem.titleView = self.titleView;
    [self initConstraints];
}

- (void)initConstraints {
    [self.calendarLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleView).with.offset(8);
        make.bottom.equalTo(self.titleView);
    }];
}

- (void)push {
    [self.navigationController pushViewController:[[TelevisionWallViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Getter

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 44)];
    }
    
    return _titleView;
}

- (UILabel *)calendarLabel {
    if (!_calendarLabel) {
        _calendarLabel = [[UILabel alloc] init];
        _calendarLabel.text = @"Jun 14, Wed";
        _calendarLabel.text = @"12月02日 星期三";
        _calendarLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        [self.titleView addSubview:_calendarLabel];
    }
    
    return _calendarLabel;
}

@end
