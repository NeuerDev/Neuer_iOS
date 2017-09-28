//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeViewController.h"

#import "TelevisionWallViewController.h"

@interface HomeComponentBaseView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIView *bodyView;

@end

@implementation HomeComponentBaseView

- (instancetype)init {
    if (self = [super init]) {
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(self).with.offset(16);
        make.right.equalTo(self).with.offset(-16);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subTitleLabel.mas_bottom).with.offset(4);
        make.left.and.right.equalTo(self.subTitleLabel);
    }];
    
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.subTitleLabel);
        make.centerY.equalTo(self.titleLabel);
    }];
    
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(32);
        make.left.and.right.equalTo(self.subTitleLabel);
        make.bottom.equalTo(self.mas_bottom).with.offset(-16);
    }];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle];
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        [self addSubview:_subTitleLabel];
    }
    
    return _subTitleLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        [self addSubview:_actionButton];
    }
    
    return _actionButton;
}

- (UIView *)bodyView {
    return nil;
}

@end

@interface HomeComponentAccessView : HomeComponentBaseView
@property (nonatomic, strong) UIView *contentView;
@end

@implementation HomeComponentAccessView

- (UIView *)bodyView {
    return self.contentView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 355, 375)];
        
        UIView *view1 = [[UIView alloc] init];
        view1.backgroundColor = [UIColor beautyRed];
        UIView *view2 = [[UIView alloc] init];
        view2.backgroundColor = [UIColor beautyBlue];
        UIView *view3 = [[UIView alloc] init];
        view3.backgroundColor = [UIColor beautyGreen];
        UIView *view4 = [[UIView alloc] init];
        view4.backgroundColor = [UIColor beautyPurple];
        [_contentView addSubview:view1];
        [_contentView addSubview:view2];
        [_contentView addSubview:view3];
        [_contentView addSubview:view4];
        [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(_contentView);
            make.width.mas_equalTo(@(150));
            make.height.mas_equalTo(@(90));
            make.bottom.equalTo(view3.mas_top).with.offset(-16);
        }];
        [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.equalTo(_contentView);
            make.width.mas_equalTo(@(150));
            make.height.mas_equalTo(@(90));
        }];
        [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.left.equalTo(_contentView);
            make.width.mas_equalTo(@(150));
            make.height.mas_equalTo(@(90));
        }];
        [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.right.equalTo(_contentView);
            make.width.mas_equalTo(@(150));
            make.height.mas_equalTo(@(90));
        }];
        [self addSubview:_contentView];
    }
    
    return _contentView;
}

@end

@interface HomeViewController ()
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *calendarLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) HomeComponentAccessView *accessView;       // 便捷访问
@property (nonatomic, strong) HomeComponentBaseView *scheduleView;     // 课表
@property (nonatomic, strong) HomeComponentBaseView *galleryView;
@property (nonatomic, strong) HomeComponentBaseView *newsView;
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
    
//    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_topLayoutGuide);
//        make.left.and.right.equalTo(self.view);
//        make.height.equalTo(self.backgroundImageView.mas_width).multipliedBy(9.0f/16.0f);
//    }];
//
//    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_topLayoutGuide);
//        make.left.and.right.and.bottom.equalTo(self.view);
//    }];
//
//    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.scrollView);
//        make.width.equalTo(self.view);
//    }];
//
//    [self.accessView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.contentView.mas_top).with.offset(300);
//        make.left.and.right.equalTo(self.contentView);
//        make.bottom.equalTo(self.contentView);
//    }];
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

//- (UIView *)scheduleView {
//
//}
//
//- (UIView *)galleryView {
//
//}
//
//- (UIView *)newsView {
//
//}

@end
