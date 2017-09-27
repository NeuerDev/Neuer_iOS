//
//  SkeletonViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SkeletonViewController.h"

#import "HomeViewController.h"
#import "CampusViewController.h"
#import "SearchViewController.h"
#import "MeViewController.h"

#import <objc/runtime.h>

@interface SkelentonNavigationViewController : UINavigationController

@end

@implementation SkelentonNavigationViewController

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.navigationBar.prefersLargeTitles = YES;
    } else {
        
    }
#endif
    
}

#pragma mark - Override Methods

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

/**
 重写 pushViewController:animated: 方法，push 的时候隐藏 tabbar
 
 @param viewController 将要被 push 的 viewController
 @param animated 是否动画
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count==1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end

@interface SkeletonViewController ()
@property (nonatomic, strong) SkelentonNavigationViewController *homeNavigationVC;
@property (nonatomic, strong) SkelentonNavigationViewController *campusNavigationVC;
@property (nonatomic, strong) SkelentonNavigationViewController *searchNavigationVC;
@property (nonatomic, strong) SkelentonNavigationViewController *meNavigationVC;
@end

@implementation SkeletonViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidesBottomBarWhenPushed = YES;
    self.viewControllers = @[
                             self.homeNavigationVC,
                             self.campusNavigationVC,
                             self.searchNavigationVC,
                             self.meNavigationVC
                             ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Override Methods

- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

#pragma mark - Getter

- (SkelentonNavigationViewController *)homeNavigationVC {
    if (!_homeNavigationVC) {
        _homeNavigationVC = [[SkelentonNavigationViewController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
        _homeNavigationVC.tabBarItem.title = NSLocalizedString(@"HomeTabBarItemTitle", nil);
    }
    
    return _homeNavigationVC;
}

- (SkelentonNavigationViewController *)campusNavigationVC {
    if (!_campusNavigationVC) {
        _campusNavigationVC = [[SkelentonNavigationViewController alloc] initWithRootViewController:[[CampusViewController alloc] init]];
        _campusNavigationVC.tabBarItem.title = NSLocalizedString(@"CampusTabBarItemTitle", nil);
    }
    
    return _campusNavigationVC;
}

- (SkelentonNavigationViewController *)searchNavigationVC {
    if (!_searchNavigationVC) {
        _searchNavigationVC = [[SkelentonNavigationViewController alloc] initWithRootViewController:[[SearchViewController alloc] init]];
        _searchNavigationVC.tabBarItem.title = NSLocalizedString(@"SearchTabBarItemTitle", nil);
    }
    
    return _searchNavigationVC;
}

- (SkelentonNavigationViewController *)meNavigationVC {
    if (!_meNavigationVC) {
        _meNavigationVC = [[SkelentonNavigationViewController alloc] initWithRootViewController:[[MeViewController alloc] init]];
        _meNavigationVC.tabBarItem.title = NSLocalizedString(@"MeTabBarItemTitle", nil);
    }
    
    return _meNavigationVC;
}

@end
