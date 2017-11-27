//
//  TelevisionWallModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TelevisionWallModel.h"

#import "JHRequest.h"
#import "JHResponse.h"

#import <hpple/TFHpple.h>

#import "NSString+JHCategory.h"

@interface TelevisionWallModel () <JHRequestDelegate>
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<TelevisionWallChannelBean *> *> *channelArrayDictionary;
@property (nonatomic, strong) NSMutableDictionary *name2TypeDic;
@property (nonatomic, strong) NSString *keyword;

@end

@implementation TelevisionWallModel
{
    queryCollectionItemBlock _block;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _channelArray = @[].mutableCopy;
        _channelDictionary = @{}.mutableCopy;
        _currentType = TelevisionChannelTypeAll;
        NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Json.bundle/neu_tv" ofType:@"json"]];
        NSDictionary *neuTVDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *typeArray = neuTVDic[@"type"];
        NSMutableDictionary *type2NameDic = @{}.mutableCopy;
        for (NSDictionary *type in typeArray) {
            [type2NameDic setObject:type[@"name"] forKey:type[@"id"]];
        }
        _name2TypeDic = @{}.mutableCopy;
        for (NSDictionary *type in typeArray) {
            [_name2TypeDic setObject:type[@"id"] forKey:type[@"name"]];
        }
        NSArray *liveArray = neuTVDic[@"live"];
        NSDictionary *typeMap = @{
                                  @"uidall"  :   @(0),
                                  @"uid1"    :   @(TelevisionChannelTypeZhongyang),
                                  @"uid2"    :   @(TelevisionChannelTypeWeishi),
                                  @"uid3"    :   @(TelevisionChannelTypeVariety),
                                  @"uid4"    :   @(TelevisionChannelTypeSports),
                                  @"uid5"    :   @(TelevisionChannelTypeShaoer),
                                  @"uid6"    :   @(TelevisionChannelTypeOther),
                                  };
        for (NSDictionary *live in liveArray) {
            TelevisionWallChannelBean *channel = _channelDictionary[live[@"name"]];
            if (channel) {
                channel.type = channel.type |
                [typeMap[live[@"itemid"]] integerValue];
            } else {
                channel = [[TelevisionWallChannelBean alloc] init];
                channel.channelName = live[@"name"];
                channel.videoUrlArray = [live[@"urllist"] componentsSeparatedByString:@"#"];
                NSString *channelId = [[channel.videoUrlArray.firstObject stringByReplacingOccurrencesOfString:@"http://media2.neu6.edu.cn/hls/" withString:@""] stringByReplacingOccurrencesOfString:@".m3u8" withString:@""];
                channel.previewImageUrl = [NSString stringWithFormat:@"http://hdtv.neu6.edu.cn/wall/img/%@_s.png", channelId];
                channel.channelDetailUrl = channelId;
                channel.quality = live[@"quality"];
                channel.viewerCount = 0;
                channel.type = channel.type |
                [typeMap[live[@"itemid"]] integerValue];
                [_channelArray addObject:channel];
                [_channelDictionary setObject:channel forKey:channel.channelName];
            }
        }
        _channelArrayDictionary = @{@"0" : _channelArray.copy}.mutableCopy;
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)fetchWallData {
    NSString *urlStr = @"http://hdtv.neu6.edu.cn/live-wall";
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)addCollectionTVWithSourceUrl:(NSString *)sourceUrl withBlock:(queryCollectionItemBlock)block {
    
    _block = block;
    
    FMDatabase *database = [DataBaseCenter defaultCenter].database;
//    [database executeUpdate:@"DROP TABLE IF EXISTS t_TV"];
    if ([UserCenter defaultCenter].currentUser) {
        [database executeUpdate:@"insert into t_TV (number, tv_sourceurl) values (?, ?);", [UserCenter defaultCenter].currentUser.number, sourceUrl];
        for (TelevisionWallChannelBean *bean in self.channelArray) {
            if ([bean.channelDetailUrl isEqualToString:sourceUrl]) {
                [_collectionArray addObject:bean];
                _block(YES);
            }
        }
    } else {
        _block(NO);
    }
}

- (void)deleteColletionTVItemWithSourceUrl:(NSString *)sourceUrl withBlock:(queryCollectionItemBlock)block {
    _block = block;
    
    FMDatabase *database = [DataBaseCenter defaultCenter].database;
    
    if ([UserCenter defaultCenter].currentUser) {
        [database executeUpdate:@"delete from t_TV where number = ? tv_sourceurl = ?" , [UserCenter defaultCenter].currentUser.number, sourceUrl];
        _block(YES);
    } else {
        _block(NO);
    }
}

- (void)queryWallWithKeyword:(NSString *)keyword {
    
    _keyword = keyword;
    NSMutableArray *queryArray = [NSMutableArray arrayWithCapacity:0];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", keyword];
    for (TelevisionWallChannelBean *bean in self.channelArray) {
        if ([preicate evaluateWithObject:bean.channelName]) {
            [queryArray addObject:bean];
        }
    }
    if (self.resultArray.count != 0) {
        [_resultArray removeAllObjects];
    }
    [_resultArray addObjectsFromArray:queryArray];
}

- (void)removeTVShowOrderFromOrderArray:(TelevisionWallOrderBean *)bean {
    [self.orderedArray removeObject:bean];
}

- (void)addOrderedTVShow:(TelevisionWallOrderBean *)bean {
    [self.orderedArray addObject:bean];
}

#pragma mark - JHRequestDelegate

- (void)requestDidSuccess:(JHRequest *)request {
    NSData *htmlData = request.response.data;
    [self updateChannelFromHtmlData:htmlData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate fetchWallDataDidSuccess];
    });
}

- (void)requestDidFail:(JHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate fetchWallDataDidFail:@"发生了错误"];
    });
}

#pragma mark - Private Methods

- (void)updateChannelFromHtmlData:(NSData *)htmlData {
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray<TFHppleElement *> *itemArray = [xpathParser searchWithXPathQuery:@"//div[@id ='list-wall']/a"];
    @autoreleasepool {
        for (TFHppleElement *item in itemArray) {
            NSMutableString *channelName;
            NSInteger viewerCount = 0;
            
            TFHppleElement *imageElement = [item firstChildWithTagName:@"img"];
            NSArray<NSString *> *info = [[imageElement objectForKey:@"title"] componentsSeparatedByString:@" "];
            if (info.count>=2) {
                for (NSInteger index = 0; index<info.count-1; index++) {
                    if (channelName) {
                        [channelName appendString:@" "];
                        [channelName appendString:info[index]];
                    } else {
                        channelName = info[index].mutableCopy;
                    }
                }
                channelName = channelName.length>0 ? channelName.copy:@"";
                viewerCount = [[info lastObject] stringByReplacingOccurrencesOfString:@"人" withString:@""].integerValue;
            }
            
            TelevisionWallChannelBean *bean = _channelDictionary[channelName];
            bean.viewerCount += viewerCount;
        }
    }
}

#pragma mark - Setter

- (void)setCurrentTypeWithName:(NSString *)typeName {
    _currentType = [@{
                      @"uidall"  :   @(0),
                      @"uid1"    :   @(TelevisionChannelTypeZhongyang),
                      @"uid2"    :   @(TelevisionChannelTypeWeishi),
                      @"uid3"    :   @(TelevisionChannelTypeVariety),
                      @"uid4"    :   @(TelevisionChannelTypeSports),
                      @"uid5"    :   @(TelevisionChannelTypeShaoer),
                      @"uid6"    :   @(TelevisionChannelTypeOther),
                      }[_name2TypeDic[typeName]] integerValue];
}

#pragma mark - Getter

- (NSMutableArray<TelevisionWallChannelBean *> *)collectionArray {
    if (!_collectionArray) {
        _collectionArray = @[].mutableCopy;
        if (self.currentType == TelevisionChannelTypeAll) {
            FMDatabase *database = [DataBaseCenter defaultCenter].database;
            FMResultSet *result = [database executeQuery:@"select * from t_TV where number = ?", [UserCenter defaultCenter].currentUser.number];
            
            while ([result next]) {
                for (TelevisionWallChannelBean *bean in self.channelArray) {
                    if ([bean.channelDetailUrl isEqualToString:[result stringForColumn:@"tv_sourceurl"]]) {
                        [_collectionArray addObject:bean];
                    }
                }
            }
        }
    }
    return _collectionArray;
}

- (NSMutableArray<TelevisionWallChannelBean *> *)channelArrayWithType:(TelevisionChannelType)type {
    if (!_channelArrayDictionary[[NSString stringWithFormat:@"%ld", type]]) {
        NSMutableArray<TelevisionWallChannelBean *> *array = [[NSMutableArray alloc] initWithCapacity:0];
        for (TelevisionWallChannelBean *bean in _channelArray) {
            if (bean.type&type) {
                [array addObject:bean];
            }
        }
        [_channelArrayDictionary setObject:array.copy forKey:[NSString stringWithFormat:@"%ld", type]];
    }
    
    return _channelArrayDictionary[[NSString stringWithFormat:@"%ld", type]];
}

- (NSMutableDictionary<NSString *, NSMutableArray<TelevisionWallChannelBean *> *> *)channelDictionary {
    if (!_channelArrayDictionary) {
        _channelArrayDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return _channelArrayDictionary;
}

- (NSArray<NSString *> *)channelTypeArray {
    return @[
             @"全部频道",
             @"中央频道",
             @"卫视频道",
             @"热门综艺",
             @"体育频道",
             @"少儿频道",
             @"其他频道",
             ];
}

- (NSMutableArray<TelevisionWallChannelBean *> *)resultArray {
    if (!_resultArray) {
        _resultArray = [NSMutableArray arrayWithArray:self.channelArray];
    }
    return _resultArray;
}

- (NSMutableArray<TelevisionWallOrderBean *> *)orderedArray {
    if (!_orderedArray) {
        _orderedArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _orderedArray;
}

@end

@implementation TelevisionWallOrderBean

@end

@implementation TelevisionWallChannelBean

- (NSArray<NSDictionary *> *)sourceArray {
    if (!_sourceArray) {
        NSMutableArray *sourceArray = @[].mutableCopy;
        int i = 1;
        NSDictionary *tempDic = [[NSDictionary alloc] init];
        for (NSString *urlStr in _videoUrlArray) {
            NSString *sourceStr = [[urlStr stringByReplacingOccurrencesOfString:@"http://media2.neu6.edu.cn/hls/" withString:@""] stringByReplacingOccurrencesOfString:@".m3u8" withString:@""];
            if ([sourceStr rangeOfString:@"hls"].location != NSNotFound) {
                tempDic = @{
                            [NSString stringWithFormat:@"测试%d", i] : sourceStr
                            };
                i++;
                    
            } else if ([sourceStr rangeOfString:@"jlu_"].location != NSNotFound) {
                tempDic = @{
                            @"吉林大学" : sourceStr
                            };
            } else {
                tempDic = @{
                            @"清华大学" : sourceStr
                            };
            }
                
            [sourceArray addObject:tempDic];
        }
        
        _sourceArray = sourceArray.copy;
    }
    
    return _sourceArray;
}

//当用户没有设置choosenSource时，默认选中第一个
- (NSDictionary *)choosenSource {
    if (!_choosenSource) {
        _choosenSource = self.sourceArray[0];
    }
    return _choosenSource;
}

- (NSString *)choosenDate {
    if (!_choosenDate) {
        _choosenDate = @"今天";
    }
    return _choosenDate;
}

@end
