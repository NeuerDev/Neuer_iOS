//
//  EcardLoginModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcardBaseModel.h"

@interface EcardLoginModel : EcardBaseModel

#pragma mark - Login

- (void)loginWithUser:(NSString *)userName password:(NSString *)password complete:(EcardActionCompleteBlock)block;

@end
