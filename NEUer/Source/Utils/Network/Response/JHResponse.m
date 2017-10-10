//
//  JHResponse.m
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHResponse.h"

@interface JHResponse ()
@property (nonatomic, strong) id jsonObj;
@end

@implementation JHResponse

- (instancetype)initWithUrl:(NSURL *)url statusCode:(NSInteger)statusCode headerFields:(NSDictionary<NSString *,NSString *> *)headerFields data:(NSData *)data {
    if (self = [super init]) {
        _url = url;
        _statusCode = statusCode;
        _headerFields = headerFields;
        _data = data;
    }
    
    return self;
}

- (NSDictionary *)dictionary {
    if ([_jsonObj isKindOfClass:[NSDictionary class]]) {
        return _jsonObj;
    } else {
        return @{};
    }
}

- (NSArray *)array {
    if ([_jsonObj isKindOfClass:[NSArray class]]) {
        return _jsonObj;
    } else {
        return @[];
    }
}

- (id)jsonObj {
    if (!_jsonObj) {
        _jsonObj = [NSJSONSerialization JSONObjectWithData:[self.string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    }
    
    return _jsonObj;
}

- (NSString *)string {
    return [self stringWithEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringWithEncoding:(NSStringEncoding)encoding {
    if (!_data) {
        return @"";
    } else {
        return [[NSString alloc] initWithData:_data encoding:encoding];
    }
}

- (BOOL)success {
    return _statusCode/100 == 2;
}

@end
