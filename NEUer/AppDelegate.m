//
//  AppDelegate.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AppDelegate.h"

#import "SkeletonViewController.h"
#import "JHURLRouter.h"
#import "UserCenter.h"
@interface AppDelegate ()
@property (nonatomic, strong) JHURLRouter *router;
@property (nonatomic, strong) SkeletonViewController *skelentonVC;
@end

@implementation AppDelegate

#pragma mark - Life Circle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initAppearence];
    
    [self.router loadRouterFromPlist:[[NSBundle mainBundle] pathForResource:@"router" ofType:@"plist"]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.skelentonVC;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)initAppearence {
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[[UIImage alloc] init]];
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
    [self.router handleUrl:url];
    return YES;
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
