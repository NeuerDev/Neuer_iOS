//
//  EcardModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^EcardAuthorCallbackBlock)(BOOL success, NSString *message);

typedef void(^EcardGetVerifyImageBlock)(UIImage *verifyImage, NSString *message);

typedef void(^EcardQueryLeftMoneyBlock)(NSString *money, NSString *message);

@protocol EcardDelegate

@required
- (void)queryLeftMoneySuccess:(BOOL)success leftMoney:(NSString *)leftMoney error:(NSError *)error;

@end

@interface EcardModel : NSObject

@property (nonatomic, weak) id<EcardDelegate> delegate;

- (void)getVerifyImage:(EcardGetVerifyImageBlock)block;

- (void)authorUser:(NSString *)userName password:(NSString *)password verifyCode:(NSString *)verifyCode callBack:(EcardAuthorCallbackBlock)callback;

- (void)queryLeftMoney;

@end
