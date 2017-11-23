//
//  UIGestureRecognizer+JHCategory.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/22.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "UIGestureRecognizer+JHCategory.h"

static const int target_key;

@implementation UIGestureRecognizer (JHCategory)

+ (instancetype)gestureRecognizerWithActionBlock:(JHGestureRecognizerActionBlock)block {
    return [[self alloc]initWithActionBlock:block];
}

- (instancetype)initWithActionBlock:(JHGestureRecognizerActionBlock)block {
    self = [self init];
    [self addActionBlock:block];
    [self addTarget:self action:@selector(invoke:)];
    return self;
}

- (void)addActionBlock:(JHGestureRecognizerActionBlock)block {
    if (block) {
        objc_setAssociatedObject(self, &target_key, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)invoke:(id)sender {
    JHGestureRecognizerActionBlock block = objc_getAssociatedObject(self, &target_key);
    if (block) {
        block(sender);
    }
}

@end
