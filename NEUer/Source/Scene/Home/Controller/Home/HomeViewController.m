//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeViewController.h"

#import "TelevisionWallViewController.h"

#import "HomeComponentCoverView.h"
#import "HomeComponentAccessView.h"
#import "HomeComponentScheduleView.h"

@interface HomeViewController ()
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *calendarLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) HomeComponentCoverView *coverView;        // 封面
@property (nonatomic, strong) HomeComponentAccessView *accessView;      // 便捷访问
@property (nonatomic, strong) HomeComponentScheduleView *scheduleView;  // 课表
//@property (nonatomic, strong) HomeComponentBaseView *galleryView;
//@property (nonatomic, strong) HomeComponentBaseView *newsView;
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
    
    // 导航栏约束
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

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.view);
    }];

    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.and.right.equalTo(self.contentView);
    }];
    
    [self.accessView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverView.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
    }];
    
    [self.scheduleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accessView.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
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
        _calendarLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _calendarLabel.textColor = [UIColor grayColor];
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

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self.scrollView addSubview:_contentView];
    }
    
    return _contentView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home"]];
        [self.view addSubview:_backgroundImageView];
    }
    
    return _backgroundImageView;
}

- (HomeComponentAccessView *)accessView {
    if (!_accessView) {
        _accessView = [[HomeComponentAccessView alloc] init];
        [self.contentView addSubview:_accessView];
    }
    
    return _accessView;
}

- (HomeComponentCoverView *)coverView {
    if (!_coverView) {
        _coverView = [[HomeComponentCoverView alloc] init];
        [self.contentView addSubview:_coverView];
    }
    
    return _coverView;
}

- (HomeComponentScheduleView *)scheduleView {
    if (!_scheduleView) {
        _scheduleView = [[HomeComponentScheduleView alloc] init];
        [self.contentView addSubview:_scheduleView];
    }
    
    return _scheduleView;
}

//- (UIView *)galleryView {
//
//}
//
//- (UIView *)newsView {
//
//}

@end
