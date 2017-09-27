//
//  NEUerURLHandler.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface URLHandlerResponse : NSObject
@property (nonatomic, strong) UIViewController *viewController;
@end

@protocol URLHandlerProtocol
@required
- (URLHandlerResponse *)responseForUrl:(NSURL *)url;
@end;

@interface URLHandler : NSObject <URLHandlerProtocol>

@end
