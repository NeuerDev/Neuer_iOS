//
//  GatewayModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/9.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GatewayModel : NSObject

- (void)queryInfo:(void(^)(NSArray<NSString *> *infos))infoBlock;

- (void)login:(void(^)(BOOL isSuccess, NSString *msg))loginBlock;

- (BOOL)hasUser;

@end
