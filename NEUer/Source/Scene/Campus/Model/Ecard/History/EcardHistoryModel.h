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

typedef void(^EcardQueryConsumeCompleteBlock)(BOOL success, BOOL hasMore, NSError *error);

@interface EcardHistoryModel : EcardBaseModel

@property (nonatomic, strong) NSArray<EcardConsumeBean *> *consumeHistoryArray;
@property (nonatomic, strong) NSArray<EcardConsumeBean *> *todayConsumeArray;

- (void)queryTodayConsumeHistoryComplete:(EcardQueryConsumeCompleteBlock)block;

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

@end
