//
//  SearchLibraryBorrowingModel.h
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SearchLibraryBorrowingBean;

@protocol SearchLibraryBorrowingDelegate
- (void)searchDidSuccess;
- (void)searchDidFail:(NSString *)message;
@end

@interface SearchLibraryBorrowingModel : NSObject
@property (nonatomic, weak) id <SearchLibraryBorrowingDelegate> delegate;
@property (nonatomic, strong) NSString *languageType;
@property (nonatomic, strong) NSString *sortType;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSMutableArray<SearchLibraryBorrowingBean *> *resultArray;

- (void)search;

@end
@interface SearchLibraryBorrowingBean : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *count;

@end
