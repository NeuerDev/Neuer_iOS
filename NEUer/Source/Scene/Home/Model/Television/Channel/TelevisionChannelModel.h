//
//  TelevisionChannelModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TelevisionChannelModelSelectionType) {
    TelevisionChannelModelSelectionTypeToday = 0,
    TelevisionChannelModelSelectionTypeYesterday,
    TelevisionChannelModelSelectionTypeTwoDaysAgo,
    TelevisionChannelModelSelectionTypeThreeDaysAgo,
    TelevisionChannelModelSelectionTypeFourDaysAgo,
    TelevisionChannelModelSelectionTypeFiveDaysAgo,
    TelevisionChannelModelSelectionTypeSixDaysAgo,
    TelevisionChannelModelSelectionTypeSevenDaysAgo,
};

@protocol TelevisionChannelModelDelegate

@required
- (void)fetchTelevisionChannelModelSuccess;
- (void)fetchTelevisionChannelModelFailureWithMsg:(NSString *)msg;

@end


@interface TelevisionChannelModel : NSObject

@property (nonatomic, weak) id<TelevisionChannelModelDelegate> delegate;
@property (nonatomic, assign) TelevisionChannelModelSelectionType selectedType;
@property (nonatomic, strong) NSString *sourceStr; // 当前正在播放的视频源

/**
 @param videoUrl 播放源地址
 */
- (void)fecthTelevisionChannelDataWithVideoUrl:(NSString *)videoUrl;

/**
 获取该播放源的近8天所有播放过的节目单
 */
- (NSDictionary *)TelevisionChannelDictionary;

/**
 获取某一天播放过的节目单
 */
- (NSArray *)TelevisionChannelSelectionDayArrayWithType:(TelevisionChannelModelSelectionType)type;

/**
 获取播放天数类型数组
 */
- (NSArray *)TelevisionChannelModelSelectionTypeArray;

@end

@interface TelevisionChannelScheduleBean : NSObject

@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *time;

@end
