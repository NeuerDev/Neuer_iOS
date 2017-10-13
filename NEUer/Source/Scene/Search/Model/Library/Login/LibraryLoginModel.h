//
//  LibraryLoginModel.h
//  NEUer
//
//  Created by kl h on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryLoginModel : NSObject
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *tmpUrl;

- (void)login;

@end
