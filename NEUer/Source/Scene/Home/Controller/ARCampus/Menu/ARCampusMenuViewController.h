//
//  ARCampusMenuViewController.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/13.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHBaseViewController.h"
@class ARCampusTask;

@protocol ARCampusMenuViewControllerDelegate

@required
- (void)menuWillShow;
- (void)menuDidHide;
- (void)menuTaskChanged:(ARCampusTask *)task;

@end

@interface ARCampusMenuViewController : JHBaseViewController
@property (nonatomic, weak) id<ARCampusMenuViewControllerDelegate> delegate;
@property (nonatomic, weak) ARCampusTask *task;
@end
