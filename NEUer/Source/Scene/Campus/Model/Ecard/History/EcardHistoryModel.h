//
//  EcardHistoryModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcardBaseModel.h"
@class EcardConsumeBean;

#pragma mark - History Model

typedef void(^EcardQueryConsumeProgressBlock)(NSInteger currentPage, NSInteger totalPage);

@interface EcardHistoryModel : EcardBaseModel

@property (nonatomic, strong) NSArray<EcardConsumeBean *> *consumeHistoryArray;
@property (nonatomic, strong) NSArray<EcardConsumeBean *> *todayConsumeArray;
@property (nonatomic, strong) NSArray<EcardConsumeBean *> *thisMonthConsumeArray;

- (void)queryTodayConsumeHistoryComplete:(EcardActionCompleteBlock)block;

- (void)queryThisMonthConsumeHistoryComplete:(EcardActionCompleteBlock)block;

- (void)queryThisMonthConsumeHistoryComplete:(EcardActionCompleteBlock)block
                                    progress:(EcardQueryConsumeProgressBlock)progress;

- (void)queryConsumeStatisicsComplete:(EcardActionCompleteBlock)block;

@end


#pragma mark - Consume Bean

typedef NS_ENUM(NSUInteger, EcardConsumeType) {
    EcardConsumeTypeUnknown,
    EcardConsumeTypeBath,
    EcardConsumeTypeFood,
};

@interface EcardConsumeBean : NSObject

@property (nonatomic, strong) NSString *title;              // 主标题
@property (nonatomic, strong) NSString *desc;               // 副标题
@property (nonatomic, strong) NSNumber *cost;               // 消费金额
@property (nonatomic, assign) EcardConsumeType consumeType; // 消费类型

- (instancetype)initWithTime:(NSString *)time station:(NSString *)station device:(NSString *)device money:(NSString *)money subject:(NSString *)subject;
- (NSString *)time;


/**
 判断是否可以合并两个相同类型的 bean 例如连续洗澡 在合理时间差内 允许合并

 @param bean 另一个用于合并的消费记录
 @return 是否符合合并条件
 */
- (BOOL)canMergeWithConsume:(EcardConsumeBean *)bean;


/**
 合并两条消费记录

 @param bean 另一个用于合并的消费记录
 */
- (void)mergeWithConsume:(EcardConsumeBean *)bean;

@end
