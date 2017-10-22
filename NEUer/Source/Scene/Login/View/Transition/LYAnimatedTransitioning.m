//
//  LYAnimatedTransitioning.m
//  NEUer
//
//  Created by lanya on 2017/10/13.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LYAnimatedTransitioning.h"
#import "UIView+JHCategory.h"
#import "AppDelegate.h"
#import "GatewayViewController.h"

@interface LYAnimatedTransitioning()
@property (nonatomic, assign) LYAnimatedTransitioningType animatedTransitioningType;

@end

@implementation LYAnimatedTransitioning

- (instancetype)initWithTransitioningType:(LYAnimatedTransitioningType)animatedTransitioningType {
    if (self = [super init]) {
        _animatedTransitioningType = animatedTransitioningType;
    }
    return self;
}

+ (instancetype)transitionWithTransitioningType:(LYAnimatedTransitioningType)animatedTransitioningType {
    return [[self alloc] initWithTransitioningType:animatedTransitioningType];
}

//实现协议定义的两个方法
- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.animatedTransitioningType) {
        case LYAnimatedTransitioningTypePresent:
            [self presentViewControllerWithTransitionContext:transitionContext];
            break;
        case LYAnimatedTransitioningTypeDismiss:
            [self dismissViewControllerWithTransitionContext:transitionContext];
            break;
        default:
            break;
    }
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

//实现具体的present动画
- (void)presentViewControllerWithTransitionContext:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
 
    UIView *tempView = [fromVC.view snapshotViewAfterScreenUpdates:YES];
    tempView.frame = fromVC.view.frame;
    tempView = [[AppDelegate alloc] init].skelentonVC.view;
    tempView.userInteractionEnabled = YES;
//    tempView = [[GatewayViewController alloc] init].view;
//    tempView = fromVC.view;
//    NSLog(@"%@", fromVC.view);
    tempView.backgroundColor = [UIColor blackColor];
    tempView.alpha = 0.6;

//    fromVC.view.hidden = YES;
    
    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:tempView];
    [containerView addSubview:toVC.view];
    
    toVC.view.frame = CGRectMake(0, containerView.frame.size.height, containerView.frame.size.width, containerView.frame.size.height - 100);
    NSTimeInterval duration = 0.5f;
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [toVC.view roundCorners:UIRectCornerAllCorners radii:CGSizeMake(8.0, 8.0)];
        
        toVC.view.transform = CGAffineTransformMakeTranslation(0, -containerView.frame.size.height + 100);
        
    } completion:^(BOOL finished) {
 
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        //转场失败后的处理
        if ([transitionContext transitionWasCancelled]) {
            
            fromVC.view.hidden = NO;
            [tempView removeFromSuperview];
        }
    }];
}

//实现具体的dismiss动画
- (void)dismissViewControllerWithTransitionContext:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSArray *subviewsArray = containerView.subviews;
    UIView *tempView = subviewsArray[MIN(subviewsArray.count, MAX(0, subviewsArray.count - 2))];
    
    NSTimeInterval duration = 0.3f;
    [UIView animateWithDuration:duration animations:^{
        //因为present的时候都是使用的transform，这里的动画只需要将transform恢复就可以了
        fromVC.view.transform = CGAffineTransformIdentity;
        tempView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            //失败了接标记失败
            [transitionContext completeTransition:NO];
        }else{
            [transitionContext completeTransition:YES];
            toVC.view.hidden = NO;
            [tempView removeFromSuperview];
        }
    }];
}

@end

