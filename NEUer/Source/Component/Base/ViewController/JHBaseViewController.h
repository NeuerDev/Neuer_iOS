//
//  JHBaseViewController.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHURLRouter.h"


@interface JHBaseViewController : UIViewController <JHURLRouterViewControllerProtocol>
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *retryBtn;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

- (void)showPlaceHolder;
- (void)hidePlaceHolder;
- (void)retry:(UIButton *)sender;

@end
