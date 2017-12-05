//
//  TelevisionWallModel.h
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+JHCategory.h"


@class TelevisionWallChannelBean;

typedef void(^queryCollectionItemBlock)(BOOL success);

typedef NS_OPTIONS(NSInteger, TelevisionChannelType) {
    TelevisionChannelTypeAll        = 0,
    TelevisionChannelTypeZhongyang  = 1<<0,
    TelevisionChannelTypeWeishi     = 1<<2,
    TelevisionChannelTypeVariety    = 1<<3,
    TelevisionChannelTypeSports     = 1<<4,
    TelevisionChannelTypeShaoer     = 1<<5,
    TelevisionChannelTypeOther      = 1<<6,
};

@protocol TelevisionWallDelegate

@required
- (void)fetchWallDataDidSuccess;
- (void)fetchWallDataDidFail:(NSString *)message;

@end

@interface TelevisionWallOrderBean : NSObject
@property (nonatomic, strong) NSString *showName;
@property (nonatomic, strong) NSString *showTime;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *sourceString;

@end

@interface TelevisionWallModel : NSObject

@property (nonatomic, strong) NSMutableArray<TelevisionWallChannelBean *> *channelArray;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TelevisionWallChannelBean *> *channelDictionary;
@property (nonatomic, strong) NSMutableArray<TelevisionWallChannelBean *> *resultArray;
@property (nonatomic, strong) NSMutableArray<TelevisionWallOrderBean *> *orderedArray;
@property (nonatomic, strong) NSMutableArray<TelevisionWallChannelBean *> *collectionArray;
@property (nonatomic, weak) id<TelevisionWallDelegate> delegate;
@property (nonatomic, assign) TelevisionChannelType currentType;

- (void)fetchWallData;
- (void)setCurrentTypeWithName:(NSString *)typeName;
- (NSMutableArray<TelevisionWallChannelBean *> *)channelArrayWithType:(TelevisionChannelType)type;
- (NSArray<NSString *> *)channelTypeArray;
- (void)queryWallWithKeyword:(NSString *)keyword complete:(queryCollectionItemBlock)block;
- (void)removeTVShowOrderFromOrderArray:(TelevisionWallOrderBean *)bean;
- (void)addOrderedTVShow:(TelevisionWallOrderBean *)bean;
- (void)addCollectionTVWithSourceUrl:(NSString *)sourceUrl withBlock:(queryCollectionItemBlock)block;
- (void)deleteColletionTVItemWithSourceUrl:(NSString *)sourceUrl withBlock:(queryCollectionItemBlock)block;

@end

@interface TelevisionWallChannelBean : NSObject
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *previewImageUrl;
@property (nonatomic, strong) NSString *channelDetailUrl;
@property (nonatomic, strong) NSArray *videoUrlArray;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *quality;
@property (nonatomic, assign) NSInteger viewerCount;
@property (nonatomic, strong) UIColor *mainColor;
@property (nonatomic, strong) NSArray<NSDictionary *> *sourceArray;
@property (nonatomic, strong) NSDictionary *choosenSource; // 被用户选中的播放源
@property (nonatomic, strong) NSString *choosenDate;

@end
