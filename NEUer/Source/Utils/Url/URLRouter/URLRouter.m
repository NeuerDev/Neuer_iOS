//
//  NEUerURLRouter.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "URLRouter.h"
#import "URLHandler.h"

static URLRouter *_instance;

@interface URLRouter ()
@property (nonatomic, strong) NSArray *handlers;
@end

@implementation URLRouter

#pragma mark - Singleton

+ (instancetype)sharedRouter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[URLRouter alloc] init];
    });
    
    return _instance;
}


#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"router" ofType:@"plist"];
        NSDictionary *routerDic = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    return self;
}

- (BOOL)handleUrl:(NSURL *)url {
    URLHandlerResponse *response = nil;
    for (NSObject *handler in self.handlers) {
        if ([handler conformsToProtocol:@protocol(URLHandlerProtocol)]) {
            response = [((id<URLHandlerProtocol>)handler) responseForUrl:url];
            if (response) {
                
                return YES;
            }
        }
    }
    
    return NO;
}

@end
