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
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@(SCREEN_WIDTH_ACTUAL));
        make.height.mas_equalTo(@(44));
    }];
    
    [self.calendarLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleView).with.offset(8);
        make.bottom.equalTo(self.titleView);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.and.right.and.bottom.equalTo(self.view);
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
        _titleView = [[UIView alloc] init];
    }
    
    return _titleView;
}

- (UILabel *)calendarLabel {
    if (!_calendarLabel) {
        _calendarLabel = [[UILabel alloc] init];
        _calendarLabel.text = @"Jun 14, Wed";
        _calendarLabel.text = @"12月02日 星期三";
//        _calendarLabel.text = @"在东大的第132天";
        _calendarLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        [self.titleView addSubview:_calendarLabel];
    }
    
    return _calendarLabel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_scrollView];
    }
    
    return _scrollView;
}

@end
