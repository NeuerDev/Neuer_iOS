//
//  JHBaseViewController.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHURLRouter.h"

typedef NS_ENUM(NSUInteger, JHBaseViewControllerState) {
    JHBaseViewControllerStateNormal,
    JHBaseViewControllerStateEmptyContent,
    JHBaseViewControllerStateLoadingContent,
    JHBaseViewControllerStateNetworkUnavailable,
};

@interface JHBaseViewController : UIViewController <JHURLRouterViewControllerProtocol>
@property (nonatomic, assign) JHBaseViewControllerState state;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *retryBtn;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

- (void)showPlaceHolder;
- (void)hidePlaceHolder;
- (void)retry:(UIButton *)sender;

- (void)setNavigationBarBackgroundColor:(UIColor *)color;
- (void)setPlaceholderViewHidden:(BOOL)hidden;

@end
