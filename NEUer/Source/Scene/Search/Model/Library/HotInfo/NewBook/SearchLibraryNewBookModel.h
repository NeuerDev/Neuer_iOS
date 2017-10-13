//
//  SearchLibraryNewBookModel.h
//  NEUer
//
//  Created by kl h on 2017/10/9.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SearchLibraryNewBookBean;

@interface SearchLibraryNewBookModel : NSObject

@property (nonatomic, strong) NSString *languageType;
@property (nonatomic, strong) NSString *sortType;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSMutableArray<SearchLibraryNewBookBean *> *resultArray;

- (void)search;
- (void)loadMore;

@end


@interface SearchLibraryNewBookBean : NSObject
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *year;

@end