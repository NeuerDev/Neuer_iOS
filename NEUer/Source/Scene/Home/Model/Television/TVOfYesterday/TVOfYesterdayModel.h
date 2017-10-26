//
//  TVOfYesterdayModel.h
//  NEUer
//
//  Created by lanya on 2017/10/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TVOfYesterdaySelectionType) {
    TVOfYesterdaySelectionTypeToday = 0,
    TVOfYesterdaySelectionTypeYesterday,
    TVOfYesterdaySelectionTypeTwoDaysAgo,
    TVOfYesterdaySelectionTypeThreeDaysAgo,
    TVOfYesterdaySelectionTypeFourDaysAgo,
    TVOfYesterdaySelectionTypeFiveDaysAgo,
    TVOfYesterdaySelectionTypeSixDaysAgo,
    TVOfYesterdaySelectionTypeSevenDaysAgo,
};


@protocol TVOfYesterdayModelDelegate

@required
- (void)fetchTVOfYesterdayModelSuccess;
- (void)fetchTVOfYesterdayModelFailureWithMsg:(NSString *)msg;

@end

@interface TVOfYesterdayModel : NSObject

@property (nonatomic, weak) id<TVOfYesterdayModelDelegate> delegate;
@property (nonatomic, assign) TVOfYesterdaySelectionType selectedType;

/**
 @param videoUrl 播放源地址
 */
- (void)fecthTVOfYesterdayDataWithVideoUrl:(NSString *)videoUrl;

/**
 获取该播放源的近8天所有播放过的节目单
 */
- (NSDictionary *)TVOfYesterdayDictionary;

/**
 获取某一天播放过的节目单
 */
- (NSArray *)TVOfYesterdaySelectionDayArrayWithType:(TVOfYesterdaySelectionType)type;

@end

@interface TVOfYesterdayBean : NSObject

@property (nonatomic, strong) NSString *TVShowName;
@property (nonatomic, strong) NSString *TVShowURL;
@property (nonatomic, strong) NSString *TVShowTime;
@property (nonatomic, strong) NSString *TVShowDate;

@end
