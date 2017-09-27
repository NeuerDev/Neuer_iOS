//
//  JHRequest.m
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHRequest.h"
#import "JHServer.h"

@implementation JHRequest

#pragma mark - Init Methods

- (instancetype)initWithUrl:(NSURL *)url {
    return [self initWithUrl:url method:@"GET" params:@{} headers:@{}];
}

- (instancetype)initWithUrl:(NSURL *)url method:(NSString *)method {
    return [self initWithUrl:url method:method params:@{} headers:@{}];
}

- (instancetype)initWithUrl:(NSURL *)url method:(NSString *)method params:(NSDictionary *)params {
    return [self initWithUrl:url method:method params:params headers:@{}];
}

- (instancetype)initWithUrl:(NSURL *)url method:(NSString *)method params:(NSDictionary *)params headers:(NSDictionary *)headers {
    if (self = [super init]) {
        _url = url;
        _method = method;
        _params = params;
        _headerFields = headers;
    }
    
    return self;
}

- (void)start {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[JHServer sharedServer] startRequest:self];
    });
}

- (void)cancel {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[JHServer sharedServer] cancelRequest:self];
    });
}

#pragma mark - Private Methods


@end
