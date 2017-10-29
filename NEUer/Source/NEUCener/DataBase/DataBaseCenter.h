//
//  DataBaseCenter.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/23.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface DataBaseCenter : NSObject

+ (DataBaseCenter *)defaultCenter;

- (void)setup;

- (FMDatabase *)database;

@end
