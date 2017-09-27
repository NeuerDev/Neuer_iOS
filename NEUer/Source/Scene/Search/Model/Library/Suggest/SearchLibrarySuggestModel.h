//
//  SearchLibrarySuggestModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kSearchSuggestBookName = @"searchSuggestBookName";
static NSString * const kSearchSuggestBookQuryTime = @"searchSuggestBookQuryTime";

@protocol SearchLibrarySuggestDelegate

@required
- (void)suggestUpdated;

@end

@interface SearchLibrarySuggestModel : NSObject

@property (nonatomic, weak) id<SearchLibrarySuggestDelegate> delegate;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *suggestions;
- (void)querySuggestionsForKeyword:(NSString *)keyword;

@end
