//
//  SearchListComponent.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SearchListComponent;

@protocol SearchListComponentDelegate

@required
- (void)component:(SearchListComponent *)component didSelectedString:(NSString *)string;

@optional
- (void)component:(SearchListComponent *)component willPerformAction:(NSString *)action;

@end

@interface SearchListComponent : NSObject

@property (nonatomic, weak) id<SearchListComponentDelegate> delegate;
@property (nonatomic, strong) NSArray<NSString *> *strings;

- (instancetype)initWithTitle:(NSString *)title action:(NSString *)action;
- (UIView *)view;
@end
