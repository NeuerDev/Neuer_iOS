//
//  JHBaseViewController.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHURLRouter.h"

typedef NS_ENUM(NSUInteger, JHBaseViewState) {
    JHBaseViewStateNormal,                // 正常状态 啥都没有
    JHBaseViewStateRemainsToDo,           // 还在施工
    JHBaseViewStateEmptyContent,          // 空页面
    JHBaseViewStateLoadingContent,        // 正在加载中
    JHBaseViewStateConnectionLost,        // 与服务器连接丢失（服务器挂了）
    JHBaseViewStateNetworkUnavailable,    // 没有网络
    
    JHBaseViewStateRequireCameraAccess,   // 需要授权使用照相机
    JHBaseViewStateRequireLocationAccess, // 需要授权使用地理位置

    JHBaseViewStateError,                 // 未知错误
};

@interface JHBaseViewController : UIViewController <JHURLRouterViewControllerProtocol>
@property (nonatomic, assign) JHBaseViewState baseViewState;
@property (nonatomic, strong) UIView *baseContentView;
@property (nonatomic, strong) UILabel *baseStateTitleLabel;
@property (nonatomic, strong) UILabel *baseStateDetailLabel;
@property (nonatomic, strong) UIButton *baseRetryButton;
@property (nonatomic, strong) UIActivityIndicatorView *baseActivityIndicatorView;


//- (void)showPlaceHolder;
//- (void)hidePlaceHolder;
- (void)onBaseRetryButtonClicked:(UIButton *)sender;

@end
