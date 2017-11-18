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
#import "MeViewController.h"

#import "NetworkStatusView.h"

#import <objc/runtime.h>

const CGFloat kSkeletonNetworkViewHeight = 72.0f;

@interface SkelentonNavigationViewController : UINavigationController

@end

@implementation SkelentonNavigationViewController

+ (void)initialize {
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setShadowImage:[[UIImage alloc] init]];
    navigationBar.barTintColor = UIColor.whiteColor;
}

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
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
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
    
    // 修正push控制器tabbar上移问题
    if (@available(iOS 11.0, *)){
        // 修改tabBra的frame
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
        self.tabBarController.tabBar.frame = frame;
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    if (@available(iOS 11.0, *)){
        // 修改tabBra的frame
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
        self.tabBarController.tabBar.frame = frame;
    }
    return viewController;
}

@end

@interface SkeletonViewController ()
@property (nonatomic, strong) SkelentonNavigationViewController *homeNavigationVC;
@property (nonatomic, strong) SkelentonNavigationViewController *campusNavigationVC;
@property (nonatomic, strong) SkelentonNavigationViewController *meNavigationVC;

@property (nonatomic, strong) NetworkStatusView *networkView;

@end

@implementation SkeletonViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidesBottomBarWhenPushed = YES;
    self.tabBar.tintColor = [UIColor colorWithHexStr:@"#4DABF5"];
    self.viewControllers = @[
                             self.homeNavigationVC,
                             self.campusNavigationVC,
                             self.meNavigationVC
                             ];
    
    self.networkView.frame = CGRectMake(
                                        CGRectGetMinX(self.view.frame) + 16,
                                        CGRectGetMaxY(self.view.frame),
                                        CGRectGetWidth(self.view.frame) - 32,
                                        kSkeletonNetworkViewHeight
                                        );
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedNetworkStatusChangeNotification:) name:kGatewayNetworkStatusChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedURLRouterNotification:) name:kJHURLRouterHandleNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Notification

- (void)didReceivedURLRouterNotification:(NSNotification *)notification {
    Class ViewController = notification.userInfo[@"class"];
    NSURL *url = notification.userInfo[@"url"];
    UIViewController *viewController = [((JHBaseViewController *)[ViewController alloc]) initWithUrl:url params:url.params];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [viewController setModalPresentationStyle:UIModalPresentationCustom];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReceivedNetworkStatusChangeNotification:(NSNotification *)notification {
    GatewayCenter *center = [GatewayCenter defaultCenter];
    
    NSString *alertMessage = nil;
    UIImage *icon = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_networkView.gestureRecognizers.firstObject setEnabled:NO];
    });
    if (center.networkEnable) {
        if (center.campusStatus == GatewayStatusYES) {
            // 处于校园网环境
            if (center.reachableStatus == GatewayStatusYES) {
                alertMessage = @"正在使用校园网 Wi-Fi\n可访问外网";
                icon = [UIImage imageNamed:@"wifi_network"];
            } else if (center.reachableStatus == GatewayStatusNO) {
                alertMessage = @"已连接校园网 Wi-Fi\n点击登录网关";
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_networkView.gestureRecognizers.firstObject setEnabled:YES];
                });
                icon = [UIImage imageNamed:@"key_network"];
            }
        } else if (center.campusStatus == GatewayStatusNO) {
            // 不在校园网环境
            if (center.reachableStatus == GatewayStatusYES) {
                if (center.wifiStatus == GatewayStatusYES) {
                    // Wi-Fi
                    alertMessage = @"正在使用非校内 Wi-Fi\n校园卡等服务无法使用";
                    icon = [UIImage imageNamed:@"wifi_network"];
                } else if (center.wifiStatus == GatewayStatusNO) {
                    // 蜂窝数据
                    alertMessage = @"正在使用 蜂窝数据\n校园卡等服务无法使用";
                    icon = [UIImage imageNamed:@"data_network"];
                }
            } else if (center.reachableStatus == GatewayStatusNO) {
                alertMessage = @"连接以太网超时(10s)";
                icon = [UIImage imageNamed:@"broken_network"];
            }
        } else {
            if (center.wifiStatus == GatewayStatusYES) {
                // Wi-Fi
                alertMessage = @"正在使用 Wi-Fi";
                icon = [UIImage imageNamed:@"wifi_network"];
            } else if (center.wifiStatus == GatewayStatusNO) {
                // 蜂窝数据
                alertMessage = @"正在使用 蜂窝数据\n校园卡等服务无法使用";
                icon = [UIImage imageNamed:@"data_network"];
            }
        }
    } else {
        alertMessage = @"网络已断开";
        icon = [UIImage imageNamed:@"broken_network"];
    }
    
    if (alertMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self.networkView.textLabel.text isEqualToString:alertMessage]) {
                self.networkView.textLabel.text = alertMessage;
                self.networkView.imageView.image = icon;
                [self showNetworkView];
            }
        });
    }
}

- (void)showNetworkView {
    [self.networkView show];
}

- (void)hideNetworkView {
//    [self.networkView dismiss];
}

#pragma mark - Gesture

- (void)didNetworkViewTap:(UITapGestureRecognizer *)tap {
    [self didClickNetworkViewDismiss];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"neu://handle/ipgw"] options:@{} completionHandler:nil];
}

- (void)didClickNetworkViewDismiss {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNetworkView) object:nil];
    [self.networkView.layer removeAllAnimations];
    [self performSelector:@selector(hideNetworkView) withObject:nil afterDelay:0.0f];
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
        _homeNavigationVC.tabBarItem.image = [UIImage imageNamed:@"tab_home"];
    }
    
    return _homeNavigationVC;
}

- (SkelentonNavigationViewController *)campusNavigationVC {
    if (!_campusNavigationVC) {
        _campusNavigationVC = [[SkelentonNavigationViewController alloc] initWithRootViewController:[[CampusViewController alloc] init]];
        _campusNavigationVC.tabBarItem.title = NSLocalizedString(@"CampusTabBarItemTitle", nil);
        _campusNavigationVC.tabBarItem.image = [UIImage imageNamed:@"tab_campus"];
    }
    
    return _campusNavigationVC;
}

- (SkelentonNavigationViewController *)meNavigationVC {
    if (!_meNavigationVC) {
        _meNavigationVC = [[SkelentonNavigationViewController alloc] initWithRootViewController:[[MeViewController alloc] init]];
        _meNavigationVC.tabBarItem.title = NSLocalizedString(@"MeTabBarItemTitle", nil);
        _meNavigationVC.tabBarItem.image = [UIImage imageNamed:@"tab_me"];
    }
    
    return _meNavigationVC;
}

- (NetworkStatusView *)networkView {
    if (!_networkView) {
        _networkView = [NetworkStatusView sharedNetworkStatusView];
    }
    
    return _networkView;
}

@end
