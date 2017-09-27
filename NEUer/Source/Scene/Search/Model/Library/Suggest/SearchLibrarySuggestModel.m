//
//  SearchLibrarySuggestModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchLibrarySuggestModel.h"

#import "JHRequest.h"
#import "JHResponse.h"

#import "NSString+JHCategory.h"

@interface SearchLibrarySuggestModel () <JHRequestDelegate>

@end

@implementation SearchLibrarySuggestModel

#pragma mark - Public Methods

- (void)querySuggestionsForKeyword:(NSString *)keyword {
    _keyword = keyword;
    if (_keyword.length>0) {
        [self query];
    } else {
        _suggestions = @[];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate suggestUpdated];
        });
    }
}

#pragma mark - Private Methods

- (void)query {
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/cgi-bin/sug.cgi?q=%@", _keyword.URLEncode];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    [request start];
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)suggestionsFromResponseString:(NSString *)string {
    NSMutableArray *suggestions = @[].mutableCopy;
    NSError *error;
    if ([string hasPrefix:@"aleph_sug("] && [string hasSuffix:@"})"]) {
        string = [string substringFromIndex:@"aleph_sug(".length];
        string = [string substringToIndex:(string.length-1)];
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = @{};
        id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!error && [obj isKindOfClass:[NSDictionary class]]) {
            dictionary = obj;
        }
        for (NSString *key in dictionary.allKeys) {
            if ([dictionary[key] isKindOfClass:[NSNumber class]]) {
                [suggestions addObject:@{
                                         kSearchSuggestBookName:key,
                                         kSearchSuggestBookQuryTime:[dictionary[key] stringValue],
                                         }];
            }
        }
        [suggestions sortUsingComparator:^NSComparisonResult(NSDictionary<NSString *, NSString *> *obj1, NSDictionary<NSString *, NSString *> *obj2) {
            int value1 = [obj1[kSearchSuggestBookQuryTime] intValue];
            int value2 = [obj2[kSearchSuggestBookQuryTime] intValue];
            return value1 > value2 ? NSOrderedAscending : NSOrderedDescending;
        }];
    }
     
     return suggestions;
}

#pragma mark - JHRequestDelegate

- (void)requestDidSuccess:(JHRequest *)request {
    JHResponse *response = request.response;
    if ([[request.url.query substringFromIndex:@"q=".length].URLDecode isEqualToString:_keyword]) {
        _suggestions = [self suggestionsFromResponseString:response.string.copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate suggestUpdated];
        });
    }
}

- (void)requestDidFail:(JHRequest *)request {
    
}

#pragma mark - Getter

- (NSArray<NSDictionary<NSString *,NSString *> *> *)suggestions {
    if (!_suggestions) {
        _suggestions = @[];
    }
    
    return _suggestions;
}

- (NSString *)keyword {
    if (!_keyword) {
        _keyword = @"";
    }
    
    return _keyword;
}

@end
