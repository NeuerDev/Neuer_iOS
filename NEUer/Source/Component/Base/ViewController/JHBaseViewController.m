//
//  JHBaseViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHBaseViewController.h"

@interface JHBaseViewController ()

@end

@implementation JHBaseViewController

#pragma mark - Init Methods

- (instancetype)initWithUrl:(NSURL *)url params:(NSDictionary *)params {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)handleUrl:(NSURL *)url params:(NSDictionary *)params {
    
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self fixShadowImageInView:UIApplication.sharedApplication.keyWindow];
}

#pragma mark - Private Methods

- (void)fixShadowImageInView:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class]) {
        CGFloat height = view.bounds.size.height;
        if (height < 1 && height > 0 && view.subviews.count == 0) {
            NSLog(@"removed");
            UIView *maskView = [[UIView alloc] init];
            maskView.backgroundColor = UIColor.whiteColor;
            [view addSubview:maskView];
            [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(view);
            }];
            [maskView layoutIfNeeded];
        }
    }
    
    for (UIView *subview in view.subviews) {
        [self fixShadowImageInView:subview];
    }
}

#pragma mark - Override Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
