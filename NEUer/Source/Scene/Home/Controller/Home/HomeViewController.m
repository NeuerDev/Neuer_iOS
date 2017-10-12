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



@interface HomeViewController ()
@property (nonatomic, strong) UILabel *calendarLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) HomeComponentCoverView *coverView;        // 封面
@property (nonatomic, strong) HomeComponentAccessView *accessView;      // 便捷访问
@property (nonatomic, strong) HomeComponentScheduleView *scheduleView;  // 课表
@property (nonatomic, strong) HomeComponentNewsView *newsView;          // 新闻
@property (strong, nonatomic) LoginViewController *loginVC;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"HomeNavigationBarTitle", nil);
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.calendarLabel];
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
    
//    UIButton *button1 = [[UIButton alloc] init];
//    [button1 setTitle:@"有验证码未登录" forState:UIControlStateNormal];
//    button1.titleLabel.textColor = [UIColor blueColor];
//    button1.backgroundColor = [UIColor redColor];
//    [button1 addTarget:self action:@selector(pushLoginVC) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button1];
//    button1.frame = CGRectMake(100, 500, 200, 100);
    
//    NSString *searchText = @"<a href=\"http://202.118.8.7:8991/F/LEY3T5AGIRF63BPS1PLKUX1EPLYF8UDEQAH88FA3J15YAL86YR-83545?func=item-global&amp;doc_library=NEU01&amp;doc_number=000576232\" onmouseover=\"clearTimeout(tm);hint('<tr><td class=libnname><A HREF=http://202.118.8.7:8991/F/LEY3T5AGIRF63BPS1PLKUX1EPLYF8UDEQAH88FA3J15YAL86YR-83546?func=item-global&amp;doc_library=NEU01&amp;doc_number=000576232&amp;year=&amp;volume=&amp;sub_library=NHPTW >南湖普通外借</A></td><td class=bookid>TN929.53/665<td class=holding>     4/     0</td>',this)\" onmouseout=\"tm=setTimeout(function(){g('bubble2').style.display='none';},400)\">馆藏复本:     4，已出借复本:     0</a>";
//    NSError *error = NULL;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?:[^,])*\\." options:NSRegularExpressionCaseInsensitive error:&error];
//    NSTextCheckingResult *result = [regex firstMatchInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
//    if (result) {
//        NSLog(@"%@\n", [searchText substringWithRange:result.range]);
//    }
    [self.newsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scheduleView.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)push {
    [self.navigationController pushViewController:[[TelevisionWallViewController alloc] init] animated:YES];
}

- (void)pushLoginVC {
    [self presentViewController:self.loginVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (LoginViewController *)loginVC {
    if (!_loginVC) {
        _loginVC = [[LoginViewController alloc] initWithLoginState:LoginStateNeverLoginWithVerificationCode];
        [_loginVC setUpWithLoginVerificationcodeImg:[UIImage imageNamed:@"verificationcode"]];
        [_loginVC setDidLoginWithSuccessMsg:^(NSArray *msgArr) {
            NSLog(@"%@", msgArr);
        } FailureMsg:^(NSString *msg) {
            NSLog(@"%@", msg);
        }];
    }
    return _loginVC;
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
