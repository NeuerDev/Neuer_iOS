//
//  ARCampusTask.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ARCampusTaskType) {
    ARCampusTaskTypeBuilding,   // 建筑模型
    ARCampusTaskTypeTunnel,     // 传送门
    ARCampusTaskTypeGuide,      // 校内导航
    ARCampusTaskTypePanorama,   // 球型全景
};

@interface ARCampusTask : NSObject
@property (nonatomic, assign) ARCampusTaskType type;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;
@end
