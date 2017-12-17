//
//  EcardServiceModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcardBaseModel.h"

@interface EcardServiceModel : EcardBaseModel

- (void)changePasswordWithOldPassword:(NSString *)oldPassword
                          newPassword:(NSString *)newPassword
                        renewPassword:(NSString *)renewPassword
                             complete:(EcardActionCompleteBlock)block;

- (void)reportLostWithPassword:(NSString *)password
                identityNumber:(NSString *)identityNumber
                      complete:(EcardActionCompleteBlock)block;

@end
