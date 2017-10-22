//
//  EcardModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class User;

typedef void(^EcardGetVerifyImageBlock)(UIImage *verifyImage, NSString *message);
typedef void(^EcardActionCompleteBlock)(BOOL success, NSError *error);
typedef void(^EcardQueryConsumeCompleteBlock)(BOOL success, BOOL hasMore, NSError *error);

typedef NS_ENUM(NSUInteger, EcardInfoBalanceLevel) {
    EcardInfoBalanceLevelUnknown,
    EcardInfoBalanceLevelEnough,
    EcardInfoBalanceLevelNotEnough,
    EcardInfoBalanceLevelNoMoney,
};

@interface EcardInfoBean : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *balance;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *allowance;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *campus;
@property (nonatomic, strong) NSString *major;
@property (nonatomic, strong) NSString *lastUpdate;
@property (nonatomic, assign) BOOL enable;                          // 是否正常卡 否为挂失
@property (nonatomic, assign) EcardInfoBalanceLevel balanceLevel;   // 余额级别 充足、偏低、警报

+ (EcardInfoBean *)infoWithUser:(User *)user;

@end

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

@interface EcardModel : NSObject

@property (nonatomic, strong) EcardInfoBean *info;
@property (nonatomic, strong) NSDictionary *consumeStatisicsDictionary;
@property (nonatomic, strong) NSArray<EcardConsumeBean *> *consumeHistoryArray;
@property (nonatomic, strong) NSArray<EcardConsumeBean *> *todayConsumeArray;

- (instancetype)initWithUser:(User *)user;

- (void)getVerifyImage:(EcardGetVerifyImageBlock)block;

- (void)authorUser:(NSString *)userName password:(NSString *)password verifyCode:(NSString *)verifyCode complete:(EcardActionCompleteBlock)block;

- (void)fetchAvatarComplete:(EcardActionCompleteBlock)block;

- (void)queryInfoComplete:(EcardActionCompleteBlock)block;

- (void)queryTodayConsumeHistoryComplete:(EcardQueryConsumeCompleteBlock)block;

- (void)queryConsumeStatisicsComplete:(EcardActionCompleteBlock)block;

- (void)reportLostComplete:(EcardActionCompleteBlock)block;

@end
