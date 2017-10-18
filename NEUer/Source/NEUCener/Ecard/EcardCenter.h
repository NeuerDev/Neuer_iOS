//
//  EcardCenter.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcardModel.h"

@interface EcardCenter : NSObject

@property (nonatomic, strong) EcardModel *currentModel;

+ (instancetype)defaultCenter;

@end
