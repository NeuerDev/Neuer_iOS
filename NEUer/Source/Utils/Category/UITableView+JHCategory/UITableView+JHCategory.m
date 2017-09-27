//
//  UITableView+JHCategory.m
//
//  Created by 307A on 2017/2/13.
//  Copyright © 2017年 徐嘉宏. All rights reserved.
//

#import "UITableView+JHCategory.h"

@implementation UITableView (JHCategory)

- (void)showMessage:(NSString *)message forRowCount:(NSUInteger)rowCount; {
    if (rowCount == 0) {
        // Display a message when the table is empty
        // 没有数据的时候，UILabel的显示样式
        UILabel *messageLabel = [[UILabel alloc] init];
        
        messageLabel.text = message;
        messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        messageLabel.textColor = [UIColor grayColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.backgroundView = messageLabel;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        self.backgroundView = nil;
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}
@end
