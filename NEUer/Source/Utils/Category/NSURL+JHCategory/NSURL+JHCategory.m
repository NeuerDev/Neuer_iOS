//
//  NSURL+JHCategory.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/5.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NSURL+JHCategory.h"

@implementation NSURL (JHCategory)
- (NSDictionary *)params {
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableDictionary *params = @{}.mutableCopy;
    for (NSURLQueryItem *item in urlComponents.queryItems) {
        [params setObject:item.value forKey:item.name];
    }
    
    return params.copy;
}
@end
