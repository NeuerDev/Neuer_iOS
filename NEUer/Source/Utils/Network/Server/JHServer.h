//
//  JHServer.h
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JHRequest.h"

@interface JHServer : NSObject

+ (instancetype)sharedServer;

- (void)startRequest:(JHRequest *)request;
- (void)cancelRequest:(JHRequest *)request;

@end
