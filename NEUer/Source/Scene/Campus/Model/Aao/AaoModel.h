//
//  EcardModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AaoAuthorCallbackBlock)(BOOL success, NSString *message);

typedef void(^AaoGetVerifyImageBlock)(UIImage *verifyImage, NSString *message);

@protocol AaoDelegate

@required
- (void)queryLeftMoneySuccess:(BOOL)success leftMoney:(NSString *)leftMoney error:(NSError *)error;

@end

@interface AaoModel : NSObject

@property (nonatomic, weak) id<AaoDelegate> delegate;

- (void)getVerifyImage:(AaoGetVerifyImageBlock)block;

- (void)authorUser:(NSString *)userName password:(NSString *)password verifyCode:(NSString *)verifyCode callBack:(AaoAuthorCallbackBlock)callback;

- (void)queryLeftMoney;

@end
