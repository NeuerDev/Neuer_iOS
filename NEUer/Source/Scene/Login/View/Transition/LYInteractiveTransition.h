//
//  LYInteractiveTransition.h
//  NEUer
//
//  Created by lanya on 2017/10/13.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

//定义手势类型
typedef NS_ENUM(NSInteger, LYInteractiveTransitionType) {
    LYInteractiveTransitionTypePresent,
    LYInteractiveTransitionTypeDismiss,
    LYInteractiveTransitionTypePush,
    LYInteractiveTransitionTypePop
};

//定义手势方向
typedef NS_ENUM(NSInteger, LYInteractiveTransitionGestureDirection) {
    LYInteractiveTransitionGestureDirectionUp,
    LYInteractiveTransitionGestureDirectionDown,
    LYInteractiveTransitionGestureDirectionLeft,
    LYInteractiveTransitionGestureDirectionRight
};

typedef void(^GestureConfig)(void);

@interface LYInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign, getter=isInteractive) BOOL interactive;
@property (nonatomic, strong) GestureConfig presentVCConfig;
@property (nonatomic, strong) GestureConfig pushVCConfig;

- (instancetype)initWithInteractiveTransitionType:(LYInteractiveTransitionType)transitionType GestureDirection:(LYInteractiveTransitionGestureDirection)gestureDirection;

+ (instancetype)interactiveTrainsitionWithTransitionType:(LYInteractiveTransitionType)trainsitionType GestureDirection:(LYInteractiveTransitionGestureDirection)gestureDirection;

- (void)addPanGestureToViewController:(UIViewController *)viewController;

@end

