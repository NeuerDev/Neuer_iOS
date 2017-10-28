//
//  JHOperation.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/28.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "JHNetworkOperation.h"

static NSString * const kJHSpinLockName = @"operation.lock";

@implementation JHNetworkOperation {
    BOOL _finished;
    BOOL _executing;
}

+ (NSThread *)networkRequestThread {
    NSLog(@"networkRequestThread");
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        NSLog(@"networkRequestThreadEntryPoint");
        [[NSThread currentThread] setName:@"NetworkThread"];
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runloop run];
    }
}

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = kJHSpinLockName;
        _runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    }
    
    return self;
}

- (void)start {
    [self.lock lock];
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    else if ([self isReady]) {
        [self willChangeValueForKey:@"isFinished"];
        _finished  = NO;
        [self didChangeValueForKey:@"isFinished"];
        
        [self willChangeValueForKey:@"isExecuting"];
        _executing = YES;
        [self willChangeValueForKey:@"isExecuting"];
        
        NSLog(@"这里是start,线程号：%@", [NSThread currentThread]);
        [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
    }
    [self.lock unlock];
}

- (void)operationDidStart {
    [self.lock lock];
    if (![self isCancelled]) {
        NSLog(@"operationDidStart");
    }
    [self.lock unlock];
}

- (void)finishOperation {
    [self.lock lock];
    NSLog(@"is finishOperation");
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self.lock unlock];
}

- (BOOL)isConcurrent{
    NSLog(@"is concurrent");
    return YES;
}

- (BOOL)isFinished{
    NSLog(@"is finished");
    return _finished;
}

- (BOOL)isExecuting{
    NSLog(@"is executing");
    return _executing;
}

- (void)cancel {
    [self.lock lock];
    if (![self isFinished] && ![self isCancelled]) {
        [super cancel];
    }
    [self.lock unlock];
}

@end
