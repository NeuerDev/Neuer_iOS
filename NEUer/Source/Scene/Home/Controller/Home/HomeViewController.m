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
#import "HomeComponentScheduleView.h"
#import "HomeComponentNewsView.h"



@interface HomeViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UILabel *calendarLabel;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *memorialLabel;
//@property (nonatomic, strong) HomeComponentCoverView *coverView;        // 封面
//@property (nonatomic, strong) HomeComponentAccessView *accessView;      // 便捷访问
//@property (nonatomic, strong) HomeComponentScheduleView *scheduleView;  // 课表
//@property (nonatomic, strong) HomeComponentNewsView *newsView;          // 新闻

@end

@implementation HomeViewController {
    CGFloat _headerHeight;
    CGFloat _headerWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"HomeNavigationBarTitle", nil);
    
    [self initData];
    [self initConstraints];
}

- (void)initData {
    _headerHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44 + SCREEN_WIDTH_ACTUAL * 9.0f / 16.0f;
    NSLog(@"%f %f", _headerHeight, SCREEN_WIDTH_ACTUAL);
    _headerWidth = SCREEN_WIDTH_ACTUAL;
    
    self.view.backgroundColor = [UIColor colorWithHexStr:@"#F4F5FB"];
    self.navigationController
    .navigationBar
    .largeTitleTextAttributes = @{
                                  NSForegroundColorAttributeName:UIColor.clearColor,
                                  };
    [self setNavigationBarBackgroundColor:UIColor.clearColor];
}

- (void)initConstraints {
    
    self.scrollView.frame = self.view.frame;
    self.headerImageView.frame = CGRectMake(0, 0, _headerWidth, _headerHeight);
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(@9999);
    }];
    
    [self.memorialLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView.mas_left).with.offset(16);
        make.bottom.equalTo(self.headerImageView.mas_bottom).with.offset(-16);
    }];
}

- (void)push {
    [self.navigationController pushViewController:[[TelevisionWallViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 控制导航栏底色
    CGFloat minAlphaOffset = SCREEN_WIDTH_ACTUAL * 9.0f / 16.0f;
    CGFloat maxAlphaOffset = _headerHeight;
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat alpha = (offset - minAlphaOffset) / (maxAlphaOffset - minAlphaOffset);
    [self setNavigationBarBackgroundColor:[[UIColor colorWithHexStr:@"#F4F5FB"] colorWithAlphaComponent:alpha]];
    
    // 控制header透明度
    minAlphaOffset = 0;
    maxAlphaOffset = SCREEN_WIDTH_ACTUAL * 9.0f / 16.0f;
    offset = scrollView.contentOffset.y;
    alpha = (offset - minAlphaOffset) / (maxAlphaOffset - minAlphaOffset);
    self.headerImageView.alpha = 1 - alpha;
    
    CGFloat diff = -self.scrollView.contentOffset.y;
    
    if (self.scrollView.contentOffset.y < 0) {
        CGFloat newH = _headerHeight + diff;
        CGFloat newW = _headerWidth * newH/_headerHeight;
        
        self.headerImageView.frame = CGRectMake(0, 0, newW, newH);
        self.headerImageView.center = CGPointMake(_headerWidth/2.0f, (_headerHeight-diff)/2.0f);
    }
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.delegate = self;
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

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home"]];
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headerImageView.layer.masksToBounds = YES;
        [self.scrollView addSubview:_headerImageView];
    }
    
    return _headerImageView;
}

- (UILabel *)memorialLabel {
    if (!_memorialLabel) {
        _memorialLabel = [[UILabel alloc] init];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 2;
        shadow.shadowOffset = CGSizeMake(0, 1);
        _memorialLabel.attributedText = [[NSAttributedString alloc] initWithString:@"在东大的987天"
                                                                        attributes:@{
                                                                                     NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleTitle1],
                                                                                     NSForegroundColorAttributeName:UIColor.whiteColor,
                                                                                     NSShadowAttributeName:shadow}];
        [self.headerImageView addSubview:_memorialLabel];
    }
    
    return _memorialLabel;
}

@end

//@interface HomeViewController () <UIScrollViewDelegate>
//@property (nonatomic, strong) UILabel *calendarLabel;
//@property (nonatomic, strong) UIImageView *backgroundImageView;
//@property (nonatomic, strong) UIScrollView *scrollView;
//@property (nonatomic, strong) UIView *contentView;
//@property (nonatomic, strong) HomeComponentCoverView *coverView;        // 封面
//@property (nonatomic, strong) HomeComponentAccessView *accessView;      // 便捷访问
//@property (nonatomic, strong) HomeComponentScheduleView *scheduleView;  // 课表
//@property (nonatomic, strong) HomeComponentNewsView *newsView;          // 新闻
//
//@end

//@implementation HomeViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    self.title = NSLocalizedString(@"HomeNavigationBarTitle", nil);
//
//    [self initConstraints];
//}
//
//- (void)initConstraints {
//
//    self.scrollView.frame = self.view.frame;
//
//    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.scrollView);
//        make.width.equalTo(self.view);
//    }];
//
//    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.contentView.mas_top);
//        make.left.and.right.equalTo(self.contentView);
//    }];
//
//    [self.accessView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.coverView.mas_bottom);
//        make.left.and.right.equalTo(self.contentView);
//    }];
//
//    [self.scheduleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.accessView.mas_bottom);
//        make.left.and.right.equalTo(self.contentView);
//    }];
//
//    [self.newsView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.scheduleView.mas_bottom);
//        make.left.and.right.equalTo(self.contentView);
//        make.bottom.equalTo(self.contentView);
//    }];
//}
//
//- (void)push {
//    [self.navigationController pushViewController:[[TelevisionWallViewController alloc] init] animated:YES];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//
//}
//
//#pragma mark - UIScrollViewDelegate
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%f", scrollView.contentOffset.y);
//    CGFloat minAlphaOffset = 0;
//    CGFloat maxAlphaOffset = 120;
//    CGFloat offset = scrollView.contentOffset.y;
//    CGFloat alpha = (offset - minAlphaOffset) / (maxAlphaOffset - minAlphaOffset);
//    [self setNavigationBarBackgroundColor:[UIColor.whiteColor colorWithAlphaComponent:alpha]];
//}
//
//#pragma mark - Getter
//
//- (UIScrollView *)scrollView {
//    if (!_scrollView) {
//        _scrollView = [[UIScrollView alloc] init];
//        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        _scrollView.showsVerticalScrollIndicator = NO;
//        _scrollView.delegate = self;
//        [self.view addSubview:_scrollView];
//    }
//
//    return _scrollView;
//}
//
//- (UIView *)contentView {
//    if (!_contentView) {
//        _contentView = [[UIView alloc] init];
//        [self.scrollView addSubview:_contentView];
//    }
//
//    return _contentView;
//}
//
//- (UIImageView *)backgroundImageView {
//    if (!_backgroundImageView) {
//        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home"]];
//        [self.view addSubview:_backgroundImageView];
//    }
//
//    return _backgroundImageView;
//}
//
//- (HomeComponentAccessView *)accessView {
//    if (!_accessView) {
//        _accessView = [[HomeComponentAccessView alloc] init];
//        [self.contentView addSubview:_accessView];
//    }
//
//    return _accessView;
//}
//
//- (HomeComponentCoverView *)coverView {
//    if (!_coverView) {
//        _coverView = [[HomeComponentCoverView alloc] init];
//        [self.contentView addSubview:_coverView];
//    }
//
//    return _coverView;
//}
//
//- (HomeComponentScheduleView *)scheduleView {
//    if (!_scheduleView) {
//        _scheduleView = [[HomeComponentScheduleView alloc] init];
//        [self.contentView addSubview:_scheduleView];
//    }
//
//    return _scheduleView;
//}
//
//- (HomeComponentNewsView *)newsView {
//    if (!_newsView) {
//        _newsView = [[HomeComponentNewsView alloc] init];
//        [self.contentView addSubview:_newsView];
//    }
//
//    return _newsView;
//}
//
//@end

