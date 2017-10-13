//
//  EcardModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^EcardGetVerifyImageBlock)(UIImage *verifyImage, NSString *message);

@interface EcardInfoBean : NSObject

@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *balance;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *allowance;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *campus;
@property (nonatomic, strong) NSString *major;

@end

@protocol EcardLoginDelegate

@required
- (void)loginSuccess:(BOOL)success error:(NSError *)error;

@end;

@protocol EcardInfoDelegate

@required
- (void)fetchAvatarSuccess:(BOOL)success error:(NSError *)error;
- (void)queryInfoSuccess:(BOOL)success error:(NSError *)error;
- (void)queryConsumeHistorySuccess:(BOOL)success error:(NSError *)error;
- (void)queryConsumeStatisicsSuccess:(BOOL)success error:(NSError *)error;

@end

@protocol EcardServiceDelegate

@required
- (void)reportLostSuccess:(BOOL)success error:(NSError *)error;

@end

@interface EcardModel : NSObject

@property (nonatomic, weak) id<EcardLoginDelegate> loginDelegate;
@property (nonatomic, weak) id<EcardInfoDelegate> infoDelegate;
@property (nonatomic, weak) id<EcardServiceDelegate> serviceDelegate;

@property (nonatomic, strong) EcardInfoBean *info;
@property (nonatomic, strong) NSDictionary *consumeStatisicsDictionary;
@property (nonatomic, strong) NSArray *consumeHistoryArray;

- (void)getVerifyImage:(EcardGetVerifyImageBlock)block;

- (void)authorUser:(NSString *)userName password:(NSString *)password verifyCode:(NSString *)verifyCode;

- (void)fetchAvatar;

- (void)queryInfo;

- (void)queryConsumeHistory;

- (void)queryConsumeStatisics;

- (void)reportLost;

@end
