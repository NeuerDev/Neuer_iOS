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
        self.searchBar.placeholder = NSLocalizedString(@"SearchLibrarySearchBarPlaceholder", nil);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
