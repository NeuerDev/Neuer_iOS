//
//  MeAboutViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeAboutViewController.h"

@interface MeAboutViewController ()

@end

@implementation MeAboutViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

- (void)initData {
    self.title = NSLocalizedString(@"MeMenuAboutTitle", nil);
    self.view.dk_backgroundColorPicker = DKColorPickerWithKey(background);
}

- (void)initConstraints {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
