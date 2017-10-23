//
//  SearchLibraryResultModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchLibraryResultBean;
@class SearchLibraryResultLocationBean;

@protocol SearchLibraryResultDelegate
- (void)searchWillComplete;
- (void)searchDidSuccess;
- (void)searchDidFail:(NSString *)message;
@end

@interface SearchLibraryResultModel : NSObject

@property (nonatomic, strong) NSMutableArray<SearchLibraryResultBean *> *resultsArray;
@property (nonatomic, weak) id<SearchLibraryResultDelegate> delegate;

- (void)searchWithKeyword:(NSString *)keyword scope:(NSInteger)scope;
- (void)search;
- (void)loadMore;
- (BOOL)hasMore;
- (NSString *)hint;

@end

@interface SearchLibraryResultBean : NSObject
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *callNumber;
@property (nonatomic, strong) NSString *press;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *stockLocation;

// status property
@property (nonatomic, assign) BOOL showDetail;
@property (nonatomic, assign) BOOL collected;

@property (nonatomic, strong) NSArray<SearchLibraryResultLocationBean *> *loactions;
@end

@interface SearchLibraryResultLocationBean : NSObject
@property (nonatomic, strong) NSString *campus;
@property (nonatomic, strong) NSString *totalCount;
@property (nonatomic, strong) NSString *leftCount;
@end
