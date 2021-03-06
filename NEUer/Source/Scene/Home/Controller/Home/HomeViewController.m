//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "TelevisionWallViewController.h"

#import "HomeComponentCoverView.h"
#import "HomeComponentAccessView.h"
#import "HomeComponentActivityView.h"
#import "HomeComponentScheduleView.h"
#import "HomeComponentNewsView.h"

@interface HomeViewController ()
@property (nonatomic, strong) UILabel *calendarLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) HomeComponentCoverView *coverView;        // 封面
@property (nonatomic, strong) HomeComponentAccessView *accessView;      // 便捷访问
@property (nonatomic, strong) HomeComponentActivityView *activityView;  // 特色活动
@property (nonatomic, strong) HomeComponentScheduleView *scheduleView;  // 课表
@property (nonatomic, strong) HomeComponentNewsView *newsView;          // 新闻

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"HomeNavigationBarTitle", nil);
    [self initConstraints];
}

- (void)initConstraints {

    self.scrollView.frame = self.view.frame;

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
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accessView.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
    }];

    [self.scheduleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.activityView.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
    }];

    [self.newsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scheduleView.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

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

- (HomeComponentActivityView *)activityView {
    if (!_activityView) {
        _activityView = [[HomeComponentActivityView alloc] init];
        [self.contentView addSubview:_activityView];
    }
    
    return _activityView;
}

- (HomeComponentNewsView *)newsView {
    if (!_newsView) {
        _newsView = [[HomeComponentNewsView alloc] init];
        [self.contentView addSubview:_newsView];
    }

    return _newsView;
}

@end
