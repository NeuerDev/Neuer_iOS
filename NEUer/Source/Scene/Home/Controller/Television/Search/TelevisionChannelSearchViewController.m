//
//  TelevisionChannelSearchViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TelevisionChannelSearchViewController.h"

@interface TelevisionChannelSearchViewController ()

@end

@implementation TelevisionChannelSearchViewController

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super initWithSearchResultsController:nil]) {
        self.dimsBackgroundDuringPresentation = NO;
        self.obscuresBackgroundDuringPresentation = NO;
        self.searchBar.placeholder = NSLocalizedString(@"TelevisionChannelSearchBarPlaceholder", nil);
    }
    
    return self;
}

#pragma mark - LifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
