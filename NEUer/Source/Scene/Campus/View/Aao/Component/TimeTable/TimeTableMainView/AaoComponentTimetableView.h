//
//  AaoComponentTimetableView.h
//  NEUer
//
//  Created by lanya on 2017/12/8.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AaoStudentScheduleBean;
@interface AaoComponentTimetableView : UIView
@property (nonatomic, strong) NSArray <AaoStudentScheduleBean *> *classInfoArray;

@end
