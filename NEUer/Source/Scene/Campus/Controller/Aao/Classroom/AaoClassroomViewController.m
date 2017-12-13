//
//  AaoClassroomViewController.m
//  NEUer
//
//  Created by lanya on 2017/12/7.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoClassroomViewController.h"

@interface AaoClassroomViewController ()

@end

@implementation AaoClassroomViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initData {
    self.title = @"教室查询";
}

- (void)initConstraints {
    
}

@end
