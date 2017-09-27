//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeViewController.h"

@interface MeViewController ()

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"HomeNavigationBarTitle", nil);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test_cctv"]];
    [self.view addSubview:imageView];
    imageView.center = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
