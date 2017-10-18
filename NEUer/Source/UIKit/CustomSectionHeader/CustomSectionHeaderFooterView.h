//
//  CustomSectionHeaderFooterView.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CustomSectionHeaderFooterPerformActionBlock)(NSInteger section);

@interface CustomSectionHeaderFooterView : UITableViewHeaderFooterView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) NSInteger section;

- (void)setPerformActionBlock:(CustomSectionHeaderFooterPerformActionBlock)performActionBlock;

@end
