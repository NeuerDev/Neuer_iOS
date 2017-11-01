//
//  TelevisionChannelModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TelevisionChannelScheduleBean;

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
@property (nonatomic, strong) NSArray <TelevisionChannelScheduleBean *> *beanArray; // 所有视频信息
@property (nonatomic, copy) NSMutableArray <TelevisionChannelScheduleBean *> *playingArray; // 正在播放的视频

/**
 @param videoUrl 播放源地址
 */
- (void)fecthTelevisionChannelDataWithVideoUrl:(NSString *)videoUrl;

/**
 获取播放天数类型数组
 */
- (NSArray *)televisionChannelModelSelectionTypeArray;

@end

@interface TelevisionChannelScheduleBean : NSObject

@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *status;

@end
