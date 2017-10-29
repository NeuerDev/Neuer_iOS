//
//  AppDelegate.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <JPFPSStatus/JPFPSStatus.h>

#import "AppDelegate.h"
#import "JHURLRouter.h"
#import "TesseractCenter.h"
#import "DataBaseCenter.h"

@interface AppDelegate ()
@property (nonatomic, strong) JHURLRouter *router;
@end

@implementation AppDelegate

#pragma mark - Life Circle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
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
    
    // 配置路由表
    [self.router loadRouterFromPlist:[[NSBundle mainBundle] pathForResource:@"router" ofType:@"plist"]];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"url = %@", url.absoluteString);
    return [self.router handleUrl:url];
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
