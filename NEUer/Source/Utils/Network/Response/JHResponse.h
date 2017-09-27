//
//  JHResponse.h
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHResponse : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *headerFields;
@property (nonatomic, strong) NSData *data;

- (instancetype)initWithUrl:(NSURL *)url statusCode:(NSInteger)statusCode headerFields:(NSDictionary<NSString *, NSString *> *)headerFields data:(NSData *)data;

- (NSDictionary *)dictionary;

- (NSArray *)array;

- (NSString *)string;

- (NSString *)stringWithEncoding:(NSStringEncoding)encoding;

- (BOOL)success;
@end
