//
//  NEUerURLRouter.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLRouter : NSObject

+ (instancetype)sharedInstance;

- (BOOL)handleUrl:(NSURL *)url;

@end
