//
//  LibraryBookDetailModel.h
//  NEUer
//
//  Created by kl h on 2017/10/12.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LibraryBookDetailBean;

@interface LibraryBookDetailModel : NSObject

@property (nonatomic, strong) NSString *local_base;
@property (nonatomic, strong) NSString *bookNumber;
@property (nonatomic, strong) NSString *con_ing;
@property (nonatomic, strong) LibraryBookDetailBean *bean;

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
