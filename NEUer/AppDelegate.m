//
//  AppDelegate.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <JPFPSStatus/JPFPSStatus.h>
#import <PgySDK/PgyManager.h>
#import <PgyUpdate/PgyUpdateManager.h>

#import "AppDelegate.h"
#import "JHURLRouter.h"
#import "TesseractCenter.h"
#import "DataBaseCenter.h"
#import "BadgeCenter.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>
@property (nonatomic, strong) JHURLRouter *router;
@end

@implementation AppDelegate

#pragma mark - Life Circle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化蒲公英
    [[PgyManager sharedPgyManager] startManagerWithAppId:@"6e6971469056f97ff3b28a73f546eb5d"];
    [[PgyManager sharedPgyManager] setShakingThreshold:4];
    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:@"6e6971469056f97ff3b28a73f546eb5d"];
    [[PgyManager sharedPgyManager] setThemeColor:DKColorPickerWithKey(accent)(DKNightVersionManager.sharedManager.themeVersion)];
    
    // 初始化视图窗口
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    [self.window makeKeyAndVisible];
    self.window.rootViewController = self.skelentonVC;
    
#if defined(DEBUG)||defined(_DEBUG)
    [[JPFPSStatus sharedInstance] open];
#endif
    
    // 异步初始化耗时的任务
    [[TesseractCenter defaultCenter] setup];
    
    // 初始化数据库
    [[DataBaseCenter defaultCenter] setup];
    
    // 初始化用户系统
    [[UserCenter defaultCenter] setup];
    
    // 开始监听网络
    [[GatewayCenter defaultCenter] startMonitoring];
    
//    初始化badge值
    [[BadgeCenter defaultCenter] clearBadges];
    
    // 配置路由表
    [self.router loadRouterFromPlist:[[NSBundle mainBundle] pathForResource:@"router" ofType:@"plist"]];
    
    _center = [UNUserNotificationCenter currentNotificationCenter];
    _center.delegate = self;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[BadgeCenter defaultCenter] clearBadges];
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"url = %@", url.absoluteString);
    return [self.router handleUrl:url];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

}


#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"%@",  response.notification.request.content.userInfo);
    
    if ([[response.notification.request.content.userInfo objectForKey:@"contentType"] isEqualToString:@"tvshow"]) {
        NSString *sourceName = [response.notification.request.content.userInfo objectForKey:@"showsource"];
        NSString *time = [response.notification.request.content.userInfo objectForKey:@"showtime"];
        
        if ([response.notification.request.content.categoryIdentifier isEqualToString:@"tvshowid"]) {
            [self.router handleUrl:[NSURL URLWithString:[NSString stringWithFormat:@"neu://go/tv?sourcename=%@", sourceName]]];
        }
        
        WS(ws);
        [_center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
            [ws.center removeDeliveredNotificationsWithIdentifiers:@[[NSString stringWithFormat:@"requestId_%@_%@", sourceName, time]]];
        }];
    }
    
    completionHandler();
}

#pragma mark - Getter

- (SkeletonViewController *)skelentonVC {
    if (!_skelentonVC) {
        _skelentonVC = [[SkeletonViewController alloc] init];
    }
    
    return _skelentonVC;
}

- (JHURLRouter *)router {
    if (!_router) {
        _router = [JHURLRouter sharedRouter];
        [_router configRootViewController:self.skelentonVC];
    }
    
    return _router;
}

@end
