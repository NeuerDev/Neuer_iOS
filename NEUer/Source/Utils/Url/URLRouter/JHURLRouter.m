//
//  NEUerURLRouter.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHURLRouter.h"

static JHURLRouter *_instance;

@interface JHURLRouter ()
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, Class> *> *handlersMap;
@property (nonatomic, strong) UIViewController *rootViewController;
@end

@implementation JHURLRouter

#pragma mark - Singleton

+ (instancetype)sharedRouter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[JHURLRouter alloc] init];
    });
    
    return _instance;
}


#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)openUrl:(NSURL *)url handleClass:(Class)HandleClass {
    
    id viewController = [((JHBaseViewController *)[HandleClass alloc]) initWithUrl:url params:url.params];
    
    if ([_rootViewController isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)_rootViewController).topViewController.navigationController pushViewController:viewController animated:YES];
    } else if ([_rootViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedViewController = ((UITabBarController *) _rootViewController).selectedViewController;
        if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
            [((UINavigationController *)selectedViewController).topViewController.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (void)configRootViewController:(UIViewController *)rootViewController {
    _rootViewController = rootViewController;
}

- (void)loadRouterFromPlist:(NSString *)plist {
    NSDictionary *routerDic = [NSDictionary dictionaryWithContentsOfFile:plist];
    NSMutableArray *handlersMap = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dictionary in routerDic[@"object_list"]) {
        [handlersMap addObject:@{
                                 @"class":NSClassFromString(dictionary[@"class"]),
                                 @"regex":dictionary[@"regex"],
                                 }];
    }
    _handlersMap = handlersMap.copy;
}

- (BOOL)handleUrl:(NSURL *)url {
    NSString *host = url.host;
    NSString *path = url.path;
    for (NSDictionary *dictionary in _handlersMap) {
        if ([host isEqualToString:@"go"]) {
            NSString *regex = dictionary[@"regex"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            
            if ([predicate evaluateWithObject:path]) {
                [self openUrl:url handleClass:dictionary[@"class"]];
                return YES;
            } else {
                continue;
            }
            
        } else if ([host isEqualToString:@"handle"]) {
            NSString *regex = dictionary[@"regex"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            
            if ([predicate evaluateWithObject:path]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kJHURLRouterHandleNotification object:nil userInfo:@{@"url":url,@"class":dictionary[@"class"]}];
                return YES;
            } else {
                continue;
            }
        }
    }
    //    JHURLHandlerResponse *response = nil;
    //    for (NSObject *handler in self.handlers) {
    //        if ([handler conformsToProtocol:@protocol(JHURLHandlerProtocol)]) {
    //            response = [((id<JHURLHandlerProtocol>)handler) responseForUrl:url];
    //            if (response) {
    //                UIViewController *viewController = response.viewController;
    //                switch (response.modelType) {
    //                    case JHURLHandlerActionTypePush:
    //                        if ([_rootViewController isKindOfClass:[UINavigationController class]]) {
    //                            [((UINavigationController *)_rootViewController) pushViewController:viewController animated:YES];
    //                        } else if ([_rootViewController isKindOfClass:[UITabBarController class]]) {
    //                            UIViewController *selectedViewController = ((UITabBarController *) _rootViewController).selectedViewController;
    //                            if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
    //                                [((UINavigationController *)selectedViewController) pushViewController:viewController animated:YES];
    //                            }
    //                        }
    //                        break;
    //                    case JHURLHandlerActionTypePresent:
    //                        [_rootViewController presentViewController:viewController animated:YES completion:nil];
    //                        break;
    //                    case JHURLHandlerActionTypeHandle:
    //
    //                        break;
    //
    //                    default:
    //                        break;
    //                }
    //                return YES;
    //            }
    //        }
    //    }
    
    return NO;
}

@end
