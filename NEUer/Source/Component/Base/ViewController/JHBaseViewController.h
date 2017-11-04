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
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *detailLaebl;
@property (nonatomic, strong) UIButton *retryBtn;


- (void)showLabel;
- (void)hideLabel;
- (void)retry:(UIButton *)sender;


@end
