//
//  NEUerURLRouter.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHURLRouter : NSObject

+ (instancetype)sharedRouter;

- (void)configRootViewController:(UIViewController *)rootViewController;

- (void)loadRouterFromPlist:(NSString *)plist;

- (BOOL)handleUrl:(NSURL *)url;

@end
