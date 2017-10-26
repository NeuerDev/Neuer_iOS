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
@end

@implementation TelevisionWallModel

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
                                  @"uid0"    :   @(TelevisionChannelTypeHD),
                                  @"uid1"    :   @(TelevisionChannelTypeZhongyang),
                                  @"uid2"    :   @(TelevisionChannelTypeWeishi),
                                  @"uid3"    :   @(TelevisionChannelTypeLiaoning),
                                  @"uid4"    :   @(TelevisionChannelTypeBeijing),
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
                NSString *channelId = [[channel.videoUrlArray.lastObject stringByReplacingOccurrencesOfString:@"http://media2.neu6.edu.cn/hls/" withString:@""] stringByReplacingOccurrencesOfString:@".m3u8" withString:@""];
                channel.previewImageUrl = [NSString stringWithFormat:@"http://hdtv.neu6.edu.cn/wall/img/%@_s.png", channelId];
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
                      @"uid0"    :   @(TelevisionChannelTypeHD),
                      @"uid1"    :   @(TelevisionChannelTypeZhongyang),
                      @"uid2"    :   @(TelevisionChannelTypeWeishi),
                      @"uid3"    :   @(TelevisionChannelTypeLiaoning),
                      @"uid4"    :   @(TelevisionChannelTypeBeijing),
                      @"uid5"    :   @(TelevisionChannelTypeShaoer),
                      @"uid6"    :   @(TelevisionChannelTypeOther),
                      }[_name2TypeDic[typeName]] integerValue];
}

#pragma mark - Getter

- (NSMutableArray<TelevisionWallChannelBean *> *)channelArray {
    return [self channelArrayWithType:_currentType];
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
             @"高清频道",
             @"中央频道",
             @"卫视频道",
             @"辽宁地区",
             @"北京地区",
             @"少儿频道",
             @"其他频道",
             ];
}

@end

@implementation TelevisionWallChannelBean

- (NSArray<NSString *> *)sourceArray {
    if (!_sourceArray) {
        NSMutableArray *sourceArray = @[].mutableCopy;
        for (NSString *urlStr in _videoUrlArray) {
            NSString *sourceStr = [[urlStr stringByReplacingOccurrencesOfString:@"http://media2.neu6.edu.cn/hls/" withString:@""] stringByReplacingOccurrencesOfString:@".m3u8" withString:@""];
            [sourceArray addObject:sourceStr];
        }
        _sourceArray = sourceArray.copy;
    }
    
    return _sourceArray;
}

@end
