//
//  SearchLibraryResultViewController.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchLibraryResultModel;

@interface SearchLibraryResultViewController : JHBaseViewController

- (void)searchWithKeyword:(NSString *)keyword scope:(NSInteger)scope;
- (void)loadMore;
- (void)clear;

@end
