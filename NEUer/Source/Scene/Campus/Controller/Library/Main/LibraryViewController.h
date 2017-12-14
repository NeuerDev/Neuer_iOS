//
//  LibraryViewController.h
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHBaseViewController.h"

@interface LibraryViewController : JHBaseViewController

@end


@class LibraryLoginMyInfoBorrowingBean;
@class SearchLibraryBorrowingBean;
@class LibraryLoginModel;
@interface LibraryReturnCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *returndateLabel;
@property (nonatomic, strong) UIButton *refurbishBtn;
@property (nonatomic, weak) LibraryLoginModel *loginModel;
@property (nonatomic, strong) LibraryLoginMyInfoBorrowingBean *borrowingBean;

- (void)setContent:(LibraryLoginMyInfoBorrowingBean *)bean;
- (void)setMainColor:(UIColor *)color;
- (void)setButtonUserInteractionEnabled:(BOOL)enabled;

@end
