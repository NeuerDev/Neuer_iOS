//
//  AaoClassDetailViewController.m
//  NEUer
//
//  Created by lanya on 2017/12/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoClassDetailViewController.h"
#import "AaoTimeTableDetailView.h"
#import "AaoModel.h"

@interface AaoClassDetailViewController ()

@property (nonatomic, strong) UIVisualEffectView *maskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *classTitleLabel;
@property (nonatomic, strong) AaoTimeTableDetailView *detailView;

@end

@implementation AaoClassDetailViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
//    [self initConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Init

- (void)initData {
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
}

- (void)initConstraints {
    self.maskView.frame = self.view.frame;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.45);
        make.width.equalTo(self.view).multipliedBy(0.8);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(16);
        make.centerX.equalTo(self.contentView);
    }];
    [self.classTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(8);
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.left.equalTo(self.contentView).with.offset(16);
        make.right.equalTo(self.contentView).with.offset(-16);
    }];
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.classTitleLabel.mas_bottom).with.offset(16);
        make.centerX.equalTo(self.titleLabel);
        make.left.equalTo(self.contentView).with.offset(16);
        make.right.equalTo(self.contentView).with.offset(-16);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16);
    }];
}

#pragma mark - Response

- (void)didClickedMaskView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setBean:(AaoStudentScheduleBean *)bean {
    _bean = bean;
    
    [self initConstraints];
    self.detailView.bean = bean;
    self.classTitleLabel.text = _bean.schedule_courceName;
    
}

#pragma mark - Getter

- (UIVisualEffectView *)maskView {
    if (!_maskView) {
        _maskView = [[UIVisualEffectView alloc] init];
        _maskView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedMaskView)]];
        [self.view addSubview:_maskView];
    }
    return _maskView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        _contentView.layer.cornerRadius = 16;
        [self.maskView.contentView addSubview:_contentView];
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"课程详情";
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [_titleLabel sizeToFit];
        _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (AaoTimeTableDetailView *)detailView {
    if (!_detailView) {
        _detailView = [[AaoTimeTableDetailView alloc] init];
        [self.contentView addSubview:_detailView];
    }
    return _detailView;
}

- (UILabel *)classTitleLabel {
    if (!_classTitleLabel) {
        _classTitleLabel = [[UILabel alloc] init];
        _classTitleLabel.textAlignment = NSTextAlignmentCenter;
        _classTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        _classTitleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_classTitleLabel];
    }
    return _classTitleLabel;
}

@end
