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
@interface LibraryReturnCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *callNumLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *returndateLabel;
@property (nonatomic, strong) UIButton *refurbishBtn;

- (void)setBorrowingBean:(LibraryLoginMyInfoBorrowingBean *)bean;

@end
