//
//  LYAnimatedTransitioning.m
//  NEUer
//
//  Created by lanya on 2017/10/13.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LYAnimatedTransitioning.h"
#import "UIView+LYCategory.h"

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
    return 1.0f;
}

//实现具体的present动画
- (void)presentViewControllerWithTransitionContext:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    //通过viewControllerForKey取出转场前后的两个控制器，这里toVC就是vc1、fromVC就是vc2
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    NSLog(@"%@", toVC);
    NSLog(@"%@", fromVC);
    //snapshotViewAfterScreenUpdates可以对某个视图截图，我们采用对这个截图做动画代替直接对vc1做动画，因为在手势过渡中直接使用vc1动画会和手势有冲突，如果不需要实现手势的话，就可以不是用截图视图了，大家可以自行尝试一下
    UIView *tempView = [fromVC.view snapshotViewAfterScreenUpdates:YES];
    tempView.frame = fromVC.view.frame;
    //因为对截图做动画，vc1就可以隐藏了
    fromVC.view.hidden = YES;
    //这里有个重要的概念containerView，如果要对视图做转场动画，视图就必须要加入containerView中才能进行，可以理解containerView管理者所有做转场动画的视图
    UIView *containerView = [transitionContext containerView];
    //将截图视图和vc2的view都加入ContainerView中
    [containerView addSubview:tempView];
    [containerView addSubview:toVC.view];
    
    toVC.view.frame = CGRectMake(10, containerView.frame.size.height, containerView.frame.size.width - 10, containerView.frame.size.height - 100);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 / 0.55 options:0 animations:^{
        [toVC.view roundAt:UIRectCornerAllCorners withRadius:8.0];
        //首先我们让vc2向上移动
        toVC.view.transform = CGAffineTransformMakeTranslation(0, -containerView.frame.size.height + 100);
        //然后让截图视图缩小一点即可
        tempView.transform = CGAffineTransformMakeScale(0.85, 0.85);
        
    } completion:^(BOOL finished) {
        //使用如下代码标记整个转场过程是否正常完成[transitionContext transitionWasCancelled]代表手势是否取消了，如果取消了就传NO表示转场失败，反之亦然，如果不是用手势的话直接传YES也是可以的，我们必须标记转场的状态，系统才知道处理转场后的操作，否者认为你一直还在，会出现无法交互的情况
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
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //因为present的时候都是使用的transform，这里的动画只需要将transform恢复就可以了
        fromVC.view.transform = CGAffineTransformIdentity;
        tempView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            //失败了接标记失败
            [transitionContext completeTransition:NO];
        }else{
            //如果成功了，我们需要标记成功，同时让vc1显示出来，然后移除截图视图，
            [transitionContext completeTransition:YES];
            toVC.view.hidden = NO;
            [tempView removeFromSuperview];
        }
    }];
}

@end

