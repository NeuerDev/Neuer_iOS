//
//  EcardHeadlineTableViewCell.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/12/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EcardHeadlineTableViewCellDelegate

@required
- (void)willExpandHeadlineForIndexPath:(NSIndexPath *)indexPath;
- (void)willCollapseHeadlineForIndexPath:(NSIndexPath *)indexPath;

@end

@interface EcardHeadlineTableViewCell : UITableViewCell

@property (nonatomic, weak) id<EcardHeadlineTableViewCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isExpand;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *costLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end
