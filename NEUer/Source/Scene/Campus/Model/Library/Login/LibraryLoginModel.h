//
//  LibraryLoginModel.h
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryLoginModel : NSObject
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *tmpURL;

- (void)gotoLogin;

@end

@interface LibraryLoginBean : NSObject
//我的流通
@property (nonatomic, strong) NSString *borrowingStr;
@property (nonatomic, strong) NSString *borrowHistoryStr;
@property (nonatomic, strong) NSString *reservationStr;
@property (nonatomic, strong) NSString *bookedStr;
@property (nonatomic, strong) NSString *cashStr;
@property (nonatomic, strong) NSString *arrearsStr;
//我的基本信息
@property (nonatomic, strong) NSString *nameStr;
@property (nonatomic, strong) NSString *collegeStr;
@property (nonatomic, strong) NSString *languageStr;
@property (nonatomic, strong) NSString *gradeStr;
@property (nonatomic, strong) NSString *addressBeginStr;
@property (nonatomic, strong) NSString *addressEndStr;
@property (nonatomic, strong) NSString *statusStr;
@property (nonatomic, strong) NSString *barCodeStr;
@property (nonatomic, strong) NSString *registrationStr;

@end
