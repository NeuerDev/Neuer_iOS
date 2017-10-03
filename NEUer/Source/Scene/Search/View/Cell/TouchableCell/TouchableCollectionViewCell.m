//
//  TouchableCollectionViewCell.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TouchableCollectionViewCell.h"

@implementation TouchableCollectionViewCell

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self touchedDownInside];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self touchedUpInside];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self touchedDownUpCancel];
}

#pragma mark - Override Methods

- (void)touchedDownInside {
    [self goDeep];
}

- (void)touchedUpInside {
    [self goBack];
}

- (void)touchedDownUpCancel {
    [self goBack];
}

#pragma mark- Private

- (void)goDeep {
    [UIView animateWithDuration:1.0f/6.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }
                     completion:^(BOOL finished) {
        
    }];
}

- (void)goBack {
    [UIView animateWithDuration:1.0f/6.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

@end
