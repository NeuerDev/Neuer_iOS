//
//  LYAnimatedTransitioning.h
//  NEUer
//
//  Created by lanya on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

//转场类型
typedef NS_ENUM(NSInteger, LYAnimatedTransitioningType) {
    LYAnimatedTransitioningTypePresent,
    LYAnimatedTransitioningTypeDismiss
};

// 用来保存转场对象的类
@interface LYAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

//初始化方法
- (instancetype)initWithTransitioningType:(LYAnimatedTransitioningType)animatedTransitioningType;
+ (instancetype)transitionWithTransitioningType:(LYAnimatedTransitioningType)animatedTransitioningType;
@end

