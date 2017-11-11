//
//  LibraryCenter.h
//  NEUer
//
//  Created by kl h on 2017/11/5.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LibraryLoginModel.h"

@interface LibraryCenter : NSObject
@property (nonatomic, strong) LibraryLoginModel *currentModel;

+ (instancetype)defaultCenter;

@end
