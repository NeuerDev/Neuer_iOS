//
//  AaoTrainingPlanViewController.m
//  NEUer
//
//  Created by lanya on 2017/12/7.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoTrainingPlanViewController.h"
#import "AaoComponentTimetableView.h"
#import "AaoModel.h"

#define isiPhoneX ([UIScreen instancesRespondToSelector: \
@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, \
2436), [[UIScreen mainScreen] currentMode].size) : NO) \

@interface AaoTrainingPlanViewController ()
@property (nonatomic, strong) AaoComponentTimetableView *timeTableView;
@property (nonatomic, strong) UIButton *weekButton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@end

@implementation AaoTrainingPlanViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initData {
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    self.navigationItem.titleView = self.weekButton;
    self.navigationItem.rightBarButtonItems = @[self.rightBarButtonItem];
    
    [self initConstraints];
}

- (void)initConstraints {
    if (isiPhoneX) {
        self.timeTableView.frame = CGRectMake(0, 88, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL - 88);
    } else {
        self.timeTableView.frame = CGRectMake(0, 64, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL - 64);
    }
}

- (void)setModel:(AaoModel *)model {
    _model = model;
    
    self.timeTableView.classInfoArray = model.scheduleInfoArray;
}

#pragma mark - Response Method

- (void)didClickedRightBarButtonItem {
    
}


#pragma mark - Getter

- (UIView *)timeTableView {
    if (!_timeTableView) {
        _timeTableView = [[AaoComponentTimetableView alloc] init];
        [self.view addSubview:_timeTableView];
    }
    return _timeTableView;
}

- (UIBarButtonItem *)rightBarButtonItem {
    if (!_rightBarButtonItem) {
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didClickedRightBarButtonItem)];
    }
    return _rightBarButtonItem;
}

- (UIButton *)weekButton {
    if (!_weekButton) {
        _weekButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_weekButton setTitle:@"本周" forState:UIControlStateNormal];
        [_weekButton setTitleColor:[UIColor beautyOrange] forState:UIControlStateNormal];
        _weekButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    }
    return _weekButton;
}
@end
