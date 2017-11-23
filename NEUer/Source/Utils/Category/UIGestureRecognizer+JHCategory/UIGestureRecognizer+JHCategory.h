//
//  UIGestureRecognizer+JHCategory.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/22.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JHGestureRecognizerActionBlock)(UIGestureRecognizer *gestureRecognizer);

@interface UIGestureRecognizer (JHCategory)
+ (instancetype)gestureRecognizerWithActionBlock:(JHGestureRecognizerActionBlock)block;
- (instancetype)initWithActionBlock:(JHGestureRecognizerActionBlock)block;
@end
