//
//  EcardModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "EcardLoginModel.h"
#import "EcardInfoModel.h"
#import "EcardServiceModel.h"
#import "EcardHistoryModel.h"

@class User;

@interface EcardModel : EcardBaseModel

#pragma mark - Login

- (void)loginWithUser:(NSString *)userName password:(NSString *)password complete:(EcardActionCompleteBlock)block;

#pragma mark - Info

- (void)fetchAvatarComplete:(EcardActionCompleteBlock)block;

- (void)queryInfoComplete:(EcardActionCompleteBlock)block;

#pragma mark - History

- (void)queryTodayConsumeHistoryComplete:(EcardActionCompleteBlock)block;

- (void)queryThisMonthConsumeHistoryComplete:(EcardActionCompleteBlock)block;

- (void)queryConsumeStatisicsComplete:(EcardActionCompleteBlock)block;

#pragma mark - Service

- (void)changePasswordWithOldPassword:(NSString *)oldPassword
                          newPassword:(NSString *)newPassword
                        renewPassword:(NSString *)renewPassword
                             complete:(EcardActionCompleteBlock)block;

- (void)reportLostWithPassword:(NSString *)password
                identityNumber:(NSString *)identityNumber
                      complete:(EcardActionCompleteBlock)block;

#pragma mark - Getter

- (EcardInfoBean *)info;
- (NSArray<EcardConsumeBean *> *)todayConsumeArray;
- (NSArray<EcardConsumeBean *> *)consumeHistoryArray;

@end
