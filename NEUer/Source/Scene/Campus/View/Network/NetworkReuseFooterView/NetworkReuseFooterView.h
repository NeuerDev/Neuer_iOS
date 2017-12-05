//
//  NetworkReuseFooterView.h
//  NEUer
//
//  Created by lanya on 2017/11/14.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kNetworkFooterViewReuseID = @"kNetworkFooterViewReuseID";

@interface NetworkReuseFooterView : UITableViewHeaderFooterView

- (void)setAnimated:(BOOL)animated;
- (BOOL)isAnimated;

@end
