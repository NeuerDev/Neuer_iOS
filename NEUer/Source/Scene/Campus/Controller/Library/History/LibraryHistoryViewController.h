//
//  LibraryHistoryViewController.h
//  NEUer
//
//  Created by kl h on 2017/11/7.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHBaseViewController.h"

@interface LibraryHistoryViewController : JHBaseViewController

@end

@class LibraryLoginMyInfoBorrowHistoryBean;
@interface LibraryHistoryCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *returnDateLabel;

- (void)setBorrowHistoryBean:(LibraryLoginMyInfoBorrowHistoryBean *)bean;

@end
