//
//  MeHomepageViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeHomepageViewController.h"

@interface MeHomepageViewController ()

@end

@implementation MeHomepageViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.baseViewState = JHBaseViewStateRemainsToDo;
}

- (void)initData {
    self.title = NSLocalizedString(@"MeMenuCustomizeHomeTitle", nil);
    self.view.dk_backgroundColorPicker = DKColorPickerWithKey(background);
}

- (void)initConstraints {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
