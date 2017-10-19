//
//  JHToastView.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkStatusView : UIView

+ (instancetype)sharedNetworkStatusView;

- (void)show;

- (void)dismiss;

@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end
