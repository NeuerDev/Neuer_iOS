//
//  JHServer.m
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHServer.h"

#import "JHRequest.h"
#import "JHResponse.h"

// 线程安全地 添加、删除、查找
@interface JHServerRequestPool : NSObject

@property (nonatomic, strong) NSMutableDictionary *requestDic;

- (BOOL)hasRequest:(JHRequest *)request;
- (void)addRequest:(JHRequest *)request;
- (void)removeRequest:(JHRequest *)request;
- (JHRequest *)requestWithUrlStr:(NSString *)urlStr;

@end

@implementation JHServerRequestPool

- (instancetype)init {
    if (self = [super init]) {
        _requestDic = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (BOOL)hasRequest:(JHRequest *)request {
    return [_requestDic objectForKey:request.url.absoluteString];
}

- (void)addRequest:(JHRequest *)request {
    @synchronized (_requestDic) {
        [_requestDic setObject:request forKey:request.url.absoluteString];
    }
}

- (void)removeRequest:(JHRequest *)request {
    @synchronized (_requestDic) {
        [_requestDic removeObjectForKey:request.url.absoluteString];
    }
}

- (JHRequest *)requestWithUrlStr:(NSString *)urlStr {
    @synchronized (_requestDic) {
        return [_requestDic objectForKey:urlStr];
    }
}

@end

@interface JHServer ()

@property (nonatomic, strong) JHServerRequestPool *requestPool;

@end

@implementation JHServer

static JHServer *_instance;

+ (instancetype)sharedServer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[JHServer alloc] init];
    });
    
    return _instance;
}


- (instancetype)init {
    if (self = [super init]) {
        _requestPool = [[JHServerRequestPool alloc] init];
    }
    
    return self;
}


- (void)startRequest:(JHRequest *)request {
    if (request.requestType==JHRequestTypeIgnoreFollow) {
        if ([_requestPool hasRequest:request]) {
            return;
        }
    } else if (request.requestType==JHRequestTypeCancelPrevious) {
        JHRequest *previousRequest = [_requestPool requestWithUrlStr:request.url.absoluteString];
        if (previousRequest) {
            [self cancelRequest:previousRequest];
        }
    }
    [_requestPool addRequest:request];
    NSURLSessionDataTask *task = [self _taskFromRequest:request];
    [task resume];
}


- (void)cancelRequest:(JHRequest *)request {
    request.delegate = nil;
    request.completeBlock = nil;
    [_requestPool removeRequest:request];
}


#pragma mark - Private Methods

- (NSURLSessionDataTask *)_taskFromRequest:(JHRequest *)request {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:request.url];
    urlRequest.HTTPMethod = request.method;
    urlRequest.allHTTPHeaderFields = request.headerFields;
    urlRequest.timeoutInterval = request.timeoutInterval;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        request.error = error;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            request.response = [[JHResponse alloc] initWithUrl:response.URL statusCode:((NSHTTPURLResponse *)response).statusCode headerFields:((NSHTTPURLResponse *)response).allHeaderFields data:data];
            
            if (request.completeBlock) {
                request.completeBlock(request);
            }
            
            if (request.response.success) {
                [self.requestPool removeRequest:request];
                [request.delegate requestDidSuccess:request];
            } else {
                [self.requestPool removeRequest:request];
                [request.delegate requestDidFail:request];
            }
        } else {
            if (request.completeBlock) {
                request.completeBlock(request);
            }
        }
    }];
    
    return task;
}

@end
