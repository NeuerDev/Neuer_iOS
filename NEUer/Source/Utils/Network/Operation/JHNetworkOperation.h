//
//  JHOperation.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/28.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHNetworkOperation : NSOperation

@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSSet *runLoopModes;

@end
