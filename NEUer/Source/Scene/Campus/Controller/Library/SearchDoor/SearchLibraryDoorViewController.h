//
//  SearchLibraryDoorViewController.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchLibraryDoorViewController : UISearchController
@property (nonatomic, strong, readonly) UIView *resultView;
- (void)searchKeyword:(NSString *)keyword;
@end
