//
//  LYInteractiveTransition.m
//  NEUer
//
//  Created by lanya on 2017/10/13.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LYInteractiveTransition.h"

@interface LYInteractiveTransition ()

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, assign) LYInteractiveTransitionGestureDirection gestureDirection;
@property (nonatomic, assign) LYInteractiveTransitionType transitionType;

@end

@implementation LYInteractiveTransition

#pragma mark - Init Method
- (instancetype)initWithInteractiveTransitionType:(LYInteractiveTransitionType)transitionType GestureDirection:(LYInteractiveTransitionGestureDirection)gestureDirection {
    if (self = [super init]) {
        _gestureDirection = gestureDirection;
        _transitionType = transitionType;
    }
    return self;
}

+ (instancetype)interactiveTrainsitionWithTransitionType:(LYInteractiveTransitionType)trainsitionType GestureDirection:(LYInteractiveTransitionGestureDirection)gestureDirection {
    return [[self alloc] initWithInteractiveTransitionType:trainsitionType GestureDirection:gestureDirection];
}

#pragma mark - Other Method
- (void)addPanGestureToViewController:(UIViewController *)viewController {
    UIPanGestureRecognizer *panGestureRecoginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.viewController = viewController;
    [viewController.view addGestureRecognizer:panGestureRecoginzer];
}

#pragma mark - Response Method
- (void)handleGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    //    手势view所占屏幕的百分比, 用以判断用户是否取消或者完成手势
    CGFloat percent = 0;
    switch (self.gestureDirection) {
        case LYInteractiveTransitionGestureDirectionUp:
        {
            CGFloat transitionY = - [panGestureRecognizer translationInView:panGestureRecognizer.view].y;
            percent = transitionY / panGestureRecognizer.view.frame.size.height;
        }
            break;
        case LYInteractiveTransitionGestureDirectionDown:
        {
            CGFloat transitionY = [panGestureRecognizer translationInView:panGestureRecognizer.view].y;
            percent = transitionY / panGestureRecognizer.view.frame.size.width;
        }
            break;
        case LYInteractiveTransitionGestureDirectionLeft:
        {
            CGFloat transitionX = - [panGestureRecognizer translationInView:panGestureRecognizer.view].x;
            percent = transitionX / panGestureRecognizer.view.frame.size.width;
        }
            break;
        case LYInteractiveTransitionGestureDirectionRight:
        {
            CGFloat transitionX = [panGestureRecognizer translationInView:panGestureRecognizer.view].x;
            percent = transitionX / panGestureRecognizer.view.frame.size.width;
        }
            break;
            
        default:
            break;
    }
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            //            成功调用手势交互方法，并且根据不同的transitionType来选择不同的手势进入方式
            self.interactive = YES;
            [self startInteractiveTransitionWithGesture];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //            手势过程中改变百分比的值
            [self updateInteractiveTransition:percent];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            //            取消手势
            [self cancelInteractiveTransition];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            //            手势结束后判断百分比以确定是否取消操作
            if (percent > 0.5) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        }
            break;
        default:
            break;
    }
}

- (void)startInteractiveTransitionWithGesture {
    switch (self.transitionType) {
        case LYInteractiveTransitionTypePresent:
        {
            if (self.presentVCConfig) {
                _presentVCConfig();
            }
        }
            break;
        case LYInteractiveTransitionTypeDismiss:
        {
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case LYInteractiveTransitionTypePush:
        {
            if (self.pushVCConfig) {
                _pushVCConfig();
            }
        }
            break;
        case LYInteractiveTransitionTypePop:
        {
            [self.viewController.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}

@end

