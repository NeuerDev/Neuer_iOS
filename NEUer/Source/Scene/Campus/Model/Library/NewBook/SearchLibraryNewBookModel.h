//
//  SearchLibraryNewBookModel.h
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SearchLibraryNewBookBean;

@protocol SearchLibraryNewBookDelegate
- (void)searchDidSuccess;
- (void)searchDidFail:(NSString *)message;
@end

@interface SearchLibraryNewBookModel : NSObject

@property (nonatomic, strong) NSString *languageType;
@property (nonatomic, strong) NSString *sortType;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, weak) id <SearchLibraryNewBookDelegate> delegate;
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
