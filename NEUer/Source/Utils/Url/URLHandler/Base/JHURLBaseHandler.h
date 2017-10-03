//
//  NEUerURLHandler.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JHURLHandlerResponse;

typedef NS_ENUM(NSInteger, JHURLHandlerActionType) {
    JHURLHandlerActionTypePush,
    JHURLHandlerActionTypePresent,
    JHURLHandlerActionTypeHandle,
};

@protocol JHURLHandlerViewControllerProtocol

@required
- (instancetype)initWithUrl:(NSURL *)url params:(NSDictionary *)params;
- (void)handleUrl:(NSURL *)url params:(NSDictionary *)params;

@end

@protocol JHURLHandlerProtocol
@required
- (JHURLHandlerResponse *)responseForUrl:(NSURL *)url;
@end;

@interface JHURLHandlerResponse : NSObject
@property (nonatomic, strong) UIViewController<JHURLHandlerViewControllerProtocol> *viewController;
@property (nonatomic, assign) JHURLHandlerActionType modelType;
@end


@interface JHURLBaseHandler : NSObject <JHURLHandlerProtocol>

@end
