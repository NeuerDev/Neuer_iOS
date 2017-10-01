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
#import "HomeComponentNewsView.h"

@interface HomeViewController ()
@property (nonatomic, strong) UILabel *calendarLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) HomeComponentCoverView *coverView;        // 封面
@property (nonatomic, strong) HomeComponentAccessView *accessView;      // 便捷访问
@property (nonatomic, strong) HomeComponentScheduleView *scheduleView;  // 课表
@property (nonatomic, strong) HomeComponentNewsView *newsView;          // 新闻
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"HomeNavigationBarTitle", nil);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.calendarLabel];
    [self initConstraints];
}

- (void)initConstraints {

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
    }];
    
    [self.newsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scheduleView.mas_bottom);
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

- (UILabel *)calendarLabel {
    if (!_calendarLabel) {
        _calendarLabel = [[UILabel alloc] init];
        _calendarLabel.text = @"Jun 14, Wed";
        _calendarLabel.text = @"12月02日 星期三";
//        _calendarLabel.text = @"在东大的第132天";
        _calendarLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _calendarLabel.textColor = [UIColor darkGrayColor];
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

- (HomeComponentNewsView *)newsView {
    if (!_newsView) {
        _newsView = [[HomeComponentNewsView alloc] init];
        [self.contentView addSubview:_newsView];
    }
    
    return _newsView;
}

@end
