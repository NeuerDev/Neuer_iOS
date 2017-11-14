//
//  LYTool.m
//  NEUer
//
//  Created by lanya on 2017/10/15.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LYTool.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation LYTool

+ (NSString *)getMMSSFromSS:(NSString *)totalTime{
    
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
}

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(320, 8000)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    return rect.size;
}


+ (NSString *)getDeviceIPAddressesOnWifi {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (UIViewController *)getPresentedViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    topVC = topVC.presentedViewController;
    return topVC;
}

// 截取字符串方法封装
+ (NSString *)subStringFromString:(NSString *)originString startString:(NSString *)startString endString:(NSString *)endString {
    
    NSRange startRange = [originString rangeOfString:startString];
    NSRange endRange = [originString rangeOfString:endString];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
    return [originString substringWithRange:range];
    
}

+ (NSString *)dateOfTimeIntervalFromToday:(NSInteger)days {
    
    NSDate *today = [NSDate date];
    NSTimeInterval oneDaysInterval = 24 * 60 * 60;
    NSDate *beforeDate = [today initWithTimeIntervalSinceNow: - oneDaysInterval * days];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *resultDate = [dateFormatter stringFromDate:beforeDate];
    
    return resultDate;
}

+ (NSString *)timeOfNow {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *time = [dateFormatter stringFromDate:today];
    return time;
}

+ (NSString *)dateOfTodayWithFormat:(NSString *)format {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *time = [dateFormatter stringFromDate:today];
    return time;
}

+ (NSString *)changeDateFormatterFromDateFormat:(NSString *)fromDateFormat toDateFormat:(NSString *)toDateFormat withDateString:(NSString *)dateString {
//    先将字符串转化为date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fromDateFormat];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
//    再将date转为string形式
    [dateFormatter setDateFormat:toDateFormat];
    NSString *newDateString = [dateFormatter stringFromDate:date];
    
    return newDateString;
}

+ (NSTimeInterval)timeIntervalWithStartTime:(NSString *)startTime endTime:(NSString *)endTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *today = [formatter stringFromDate:date];
    NSString *todayDate = [[today componentsSeparatedByString:@" "] firstObject];
    todayDate = [todayDate stringByAppendingString:@" "];
    
    NSString *startTimesDate = [todayDate stringByAppendingString:startTime];
    NSString *endTimesDate = [todayDate stringByAppendingString:endTime];
    
    NSDate *startDate = [formatter dateFromString:startTimesDate];
    NSDate *endDate = [formatter dateFromString:endTimesDate];
    
    NSTimeInterval start = [startDate timeIntervalSince1970];
    NSTimeInterval end = [endDate timeIntervalSince1970];
    
    NSTimeInterval differenceValue = end - start;
    
    return differenceValue;
}

@end
