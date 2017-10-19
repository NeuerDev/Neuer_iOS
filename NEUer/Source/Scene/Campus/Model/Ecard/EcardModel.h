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

+ (EcardInfoBean *)infoWithUser:(User *)user;

@end

typedef NS_ENUM(NSUInteger, EcardConsumeType) {
    EcardConsumeTypeUnknown,
    EcardConsumeTypeBath,
    EcardConsumeTypeFood,
};

@interface EcardConsumeBean : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *cost;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, assign) EcardConsumeType consumeType;

@end

@interface EcardModel : NSObject

@property (nonatomic, strong) EcardInfoBean *info;
@property (nonatomic, strong) NSDictionary *consumeStatisicsDictionary;
@property (nonatomic, strong) NSArray *consumeHistoryArray;

- (instancetype)initWithUser:(User *)user;

- (void)getVerifyImage:(EcardGetVerifyImageBlock)block;

- (void)authorUser:(NSString *)userName password:(NSString *)password verifyCode:(NSString *)verifyCode complete:(EcardActionCompleteBlock)block;

- (void)fetchAvatarComplete:(EcardActionCompleteBlock)block;

- (void)queryInfoComplete:(EcardActionCompleteBlock)block;

- (void)queryConsumeHistoryComplete:(EcardActionCompleteBlock)block;

- (void)queryConsumeStatisicsComplete:(EcardActionCompleteBlock)block;

- (void)reportLostComplete:(EcardActionCompleteBlock)block;

@end
