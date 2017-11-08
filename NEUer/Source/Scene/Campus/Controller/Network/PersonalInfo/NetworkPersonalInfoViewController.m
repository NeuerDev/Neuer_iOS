//
//  NetworkPersonalInfoViewController.m
//  NEUer
//
//  Created by lanya on 2017/11/6.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkPersonalInfoViewController.h"

@interface NetworkPersonalInfoViewController ()

@end

@implementation NetworkPersonalInfoViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstaints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Init

- (void)initData {
    self.title = @"基本信息";
}

- (void)initConstaints {
    
}

@end
