//
//  CalendarLogic.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarLogic : NSObject

// 农历
+ (NSString*)getChineseCalendarWithDate:(NSDate *)date;

+ (NSString *)getWeekWithDate:(NSDate *)date;

+ (NSString *)getHolidays:(NSDate *)date;

+ (NSString *)getLunarSpecialDate:(int)iYear Month:(int)iMonth Day:(int)iDay;

@end
