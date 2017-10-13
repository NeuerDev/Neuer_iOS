//
//  SearchViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchLibraryViewController.h"
#import "LibraryBookDetailModel.h"
#import "LibraryLoginModel.h"


@interface SearchViewController ()

@property (nonatomic, strong) LibraryBookDetailModel *model;
@property (nonatomic, strong) LibraryLoginModel *loginModel;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SearchNavigationBarTitle", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"press me" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor blueColor];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.frame = CGRectMake(100, 300, 200, 100);
}

- (void)push {
    [self.navigationController pushViewController:[[SearchLibraryViewController alloc] init] animated:YES];
//    [self.model showDetail];
//    [self.loginModel login];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (LibraryBookDetailModel *)model{
    if (!_model) {
        _model = [[LibraryBookDetailModel alloc] init];
    }
   return _model;
}

- (LibraryLoginModel *)loginModel {
    if (!_loginModel) {
        _loginModel = [[LibraryLoginModel alloc] init];
    }
   return _loginModel;
}


@end
