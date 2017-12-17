//
//  EcardInfoModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcardBaseModel.h"
@class EcardInfoBean;
@class User;


#pragma mark - Info Model

@interface EcardInfoModel : EcardBaseModel

@property (nonatomic, strong) EcardInfoBean *info;

- (void)queryInfoComplete:(EcardActionCompleteBlock)block;

- (void)fetchAvatarComplete:(EcardActionCompleteBlock)block;

@end


#pragma mark - Info Bean

typedef NS_ENUM(NSUInteger, EcardInfoBalanceLevel) {
    EcardInfoBalanceLevelUnknown,
    EcardInfoBalanceLevelEnough,
    EcardInfoBalanceLevelNotEnough,
    EcardInfoBalanceLevelNoMoney,
};

@interface EcardInfoBean : NSObject

// 通用属性
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger sex;    // 0 未知 1 男 2 女
@property (nonatomic, strong) NSString *campus;
@property (nonatomic, strong) NSString *major;

// 校园卡特有属性
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *balance;
@property (nonatomic, strong) NSString *allowance;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;
@property (nonatomic, assign) BOOL enable;                          // 是否正常卡 否为挂失
@property (nonatomic, assign) EcardInfoBalanceLevel balanceLevel;   // 余额级别 充足、偏低、警报

+ (EcardInfoBean *)infoWithUser:(User *)user;

- (NSString *)lastUpdate;

- (void)commitUpdates;

@end
