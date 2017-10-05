//
//  NEUerURLHandler.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JHURLRouter.h"

@class JHURLHandlerResponse;

typedef NS_ENUM(NSInteger, JHURLHandlerActionType) {
    JHURLHandlerActionTypePush,
    JHURLHandlerActionTypePresent,
    JHURLHandlerActionTypeHandle,
};

@protocol JHURLHandlerProtocol
@required
- (JHURLHandlerResponse *)responseForUrl:(NSURL *)url;
@end;

@interface JHURLHandlerResponse : NSObject
@property (nonatomic, strong) UIViewController<JHURLRouterViewControllerProtocol> *viewController;
@property (nonatomic, assign) JHURLHandlerActionType modelType;
@end


@interface JHURLBaseHandler : NSObject <JHURLHandlerProtocol>

@end
