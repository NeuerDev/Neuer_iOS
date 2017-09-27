//
//  JHRequest.h
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JHRequest;
@class JHResponse;

typedef NS_ENUM(NSInteger, JHRequestType) {
    JHRequestTypeNone,              // 都执行
    JHRequestTypeCancelPrevious,    // 取消旧请求
    JHRequestTypeIgnoreFollow,      // 无视新请求
};

@protocol JHRequestDelegate <NSObject>

@required
- (void)requestDidSuccess:(JHRequest *)request;
- (void)requestDidFail:(JHRequest *)request;

@end

@interface JHRequest : NSObject

@property (nonatomic, weak) id<JHRequestDelegate> delegate;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *params;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *headerFields;
@property (nonatomic, strong) JHResponse *response;
@property (nonatomic, assign) JHRequestType requestType; // default is JHRequestTypeNone


/**
 Init method, default method is GET
 
 @param url destination url
 @return instance of JHRequest
 */
- (instancetype)initWithUrl:(NSURL *)url;


/**
 Init methods=
 
 @param url destination url
 @param method HTTP method
 @return instance of JHRequest
 */
- (instancetype)initWithUrl:(NSURL *)url
                     method:(NSString *)method;


/**
 Init method
 
 @param url destination url
 @param method HTTP method
 @param params request params
 @return instance of JHRequest
 */
- (instancetype)initWithUrl:(NSURL *)url
                     method:(NSString *)method
                     params:(NSDictionary *)params;


/**
 Init method
 
 @param url destination url
 @param method HTTP method
 @param params request params
 @param headers request header
 @return instance of JHRequest
 */
- (instancetype)initWithUrl:(NSURL *)url
                     method:(NSString *)method
                     params:(NSDictionary *)params
                    headers:(NSDictionary *)headers;


/**
 Start request
 */
- (void)start;


/**
 Cancel request and remove delegates
 */
- (void)cancel;

@end
