//
//  NSDictionary+JHCategory.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NSDictionary+JHCategory.h"

@implementation NSDictionary (JHCategory)
- (NSString *)queryString {
    NSArray *keyArray = self.allKeys;
    keyArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSLiteralSearch];
    }];
    NSMutableString *bodyStr = [[NSMutableString alloc] init];
    for (NSString *key in keyArray) {
        if (bodyStr.length==0) {
            [bodyStr appendFormat:@"%@=%@", key, self[key]?:@""];
        } else {
            [bodyStr appendFormat:@"&%@=%@", key, self[key]?:@""];
        }
    }
    
    return bodyStr.copy;
}
@end
