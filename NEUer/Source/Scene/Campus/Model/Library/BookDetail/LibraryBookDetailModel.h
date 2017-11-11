//
//  LibraryBookDetailModel.h
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryBookDetailModel : NSObject
@property (nonatomic, strong) NSString *local_base;
@property (nonatomic, strong) NSString *bookNumber;
@property (nonatomic, strong) NSString *con_ing;


- (void)showDetail;

@end


@interface LibraryBookDetailBean : NSObject
@property (nonatomic, strong) NSString *bookNumber;
@property (nonatomic, strong) NSString *ISBN;
@property (nonatomic, strong) NSString *languageType;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *published;
@property (nonatomic, strong) NSString *carrierForm;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *allTheCollection;

@end
