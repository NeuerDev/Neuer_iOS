//
//  TelevisionChannelModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TelevisionChannelModel.h"
#import <hpple/TFHpple.h>
#import "LYTool.h"
#import "TelevisionWallModel.h"

@interface TelevisionChannelModel () <JHRequestDelegate>

@property (nonatomic, strong) NSDictionary *TelevisionChannelDic;
@property (nonatomic, strong) NSString *videoSource;

@end

@implementation TelevisionChannelModel

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _TelevisionChannelDic = [NSDictionary dictionary];
    }
    return self;
}


- (void)fecthTelevisionChannelDataWithVideoUrl:(NSString *)videoUrl {

    _videoSource = videoUrl;
    NSString *urlStr = [NSString stringWithFormat:@"http://hdtv.neu6.edu.cn/newplayer?p=%@", self.videoSource];
    JHRequest *request = [[JHRequest alloc] initWithUrl:[NSURL URLWithString:urlStr]];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

#pragma mark - JHRequest

- (void)requestDidFail:(JHRequest *)request {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate) {
            [_delegate fetchTelevisionChannelModelFailureWithMsg:@"加载失败！"];
        }
    });
}

- (void)requestDidSuccess:(JHRequest *)request {
    
    NSData *htmlData = request.response.data;
    
    [self updateTelevisionChannelModelDataWithHtmlData:htmlData];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate) {
            [_delegate fetchTelevisionChannelModelSuccess];
        }
    });
}

#pragma mark - PrivateMethod

- (void)updateTelevisionChannelModelDataWithHtmlData:(NSData *)htmlData {
    TFHpple *hpple = [[TFHpple alloc ]initWithHTMLData:htmlData];
    
    NSMutableDictionary *listDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableArray<TelevisionChannelScheduleBean *> *listArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    //    日期div
    NSArray <TFHppleElement *>* dateArray = [hpple searchWithXPathQuery:@"//*[@id='tabs']/div"];
    if (dateArray.count == 0) {
        NSLog(@"该节目没有节目回放单");
        return;
    }
    
    for (TFHppleElement *dateElement in dateArray) {
        
        //        获取日期
        NSString *date = dateElement.attributes[@"id"];
        //        获取日期div的子div，即noon和afternoon
        NSArray <TFHppleElement *>*tempElements = [dateElement childrenWithTagName:@"div"];
        
        //        先跳过noon和afternoon，直接取出一天的数据
        for (TFHppleElement *elements in tempElements) {
            
            if ([elements.attributes[@"id"] isEqualToString:@"noon"] || [elements.attributes[@"id"] isEqualToString:@"afternoon"]) {
                
                TelevisionChannelScheduleBean *bean = [[TelevisionChannelScheduleBean alloc] init];
                for (int i = 0; i < [elements childrenWithTagName:@"div"].count; ++i) {
                    TFHppleElement *element = [elements childrenWithTagName:@"div"][i];
                    bean.date = date;
                    if ([element.attributes[@"id"] isEqualToString:@"list_status"]) {
                        TFHppleElement *urlElement = [element firstChildWithTagName:@"a"];
//                    转化成可以播放的视频地址
//                        切换视频源
//                        http://media2.neu6.edu.cn/review/program-1509120000-1509125400-hunanhd.m3u8
//                        http://hdtv.neu6.edu.cn/player-review?timeline=1509036480-1509039180-cctv1hd
//                        http://media2.neu6.edu.cn/hls/cctv13.m3u8
//                        先去掉等号前面的字符串
                        NSArray *videoUrlArray = [[urlElement objectForKey:@"href"] componentsSeparatedByString:@"="];
                        NSString *remainingStr = [videoUrlArray lastObject];
                        
//                        再将等号后面的字符串分割
                        NSArray *remainUrlArray = [remainingStr componentsSeparatedByString:@"-"];
                        NSMutableArray *videoMutableArray = [NSMutableArray arrayWithArray:remainUrlArray];
                        
//                        去掉最后一个元素：即视频类型，再添加从外界传入的视频源类型
                        [videoMutableArray removeLastObject];
                        [videoMutableArray addObject:self.videoSource];
                        NSString *videoRealUrl = [videoMutableArray componentsJoinedByString:@"-"];
                        NSString *tempUrlStr = [@"http://media2.neu6.edu.cn/review/program-" stringByAppendingString:videoRealUrl];
                        NSString *urlStr = [tempUrlStr stringByAppendingString:@".m3u8"];
                        
                        bean.videoUrl = urlStr;
                        
                    } else if ([element.attributes[@"id"] isEqualToString:@"list_item"]) {
                        NSString *text = element.text;
                        NSArray *textArr = [text componentsSeparatedByString:@" "];
                        bean.time = [textArr objectAtIndex:0];
                        if (textArr.count > 2) {
                            bean.name = [textArr componentsJoinedByString:@" "];
                        } else {
                            bean.name = [textArr lastObject];
                        }
                        
                    } else {
                        NSLog(@"%@", [element objectForKey:@"id"]);
                    }
                    if (i % 2 != 0) {
                        if (bean.name && bean.time && bean.videoUrl) {
                            bean.status = @"回看";
                            bean.sourceUrl = _videoSource;
                            [listArr addObject:bean];
                            bean = [[TelevisionChannelScheduleBean alloc] init];
                        }
                    }
                    if ([date isEqualToString:[LYTool dateOfTimeIntervalFromToday:0]]) {
                        if (![bean.time isEqualToString:@" "]) {
                            NSComparisonResult result = [bean.time compare:[LYTool timeOfNow]];
                            //                        降序
                            if (result == NSOrderedDescending && ![bean.name isEqualToString:@" "]) {
                                
//                                将当前listArr最后一个元素，也就是正在播放的元素设为正在播放并且改变url
                                TelevisionChannelScheduleBean *playingBean = (TelevisionChannelScheduleBean *)[listArr lastObject];
                                NSComparisonResult compareNowResult = [playingBean.time compare:[LYTool timeOfNow]];
                                if (compareNowResult == NSOrderedAscending) {
                                    [listArr removeLastObject];
//                                    说明当前时间已经超过视频正在播放的开始时间
                                    playingBean.videoUrl = [NSString stringWithFormat:@"http://media2.neu6.edu.cn/hls/%@.m3u8", _videoSource];
                                    playingBean.status = @"直播中";
                                    [listArr addObject:playingBean];
                                }
                                
                                bean.sourceUrl = _videoSource;
                                bean.status = NSLocalizedString(@"TelevisionChannelPlayListRemind", nil);
                                [listArr addObject:bean];
                                bean = [[TelevisionChannelScheduleBean alloc] init];
                            }
                        }
                    }
                }
            } else {
                continue;
            }
        }
//        一天中最后一个节目
        if (_selectedType == TelevisionChannelModelSelectionTypeToday) {
            NSComparisonResult result = [[listArr lastObject].time compare:[LYTool timeOfNow]];
            if (result == NSOrderedAscending) {
                [listArr lastObject].videoUrl = [NSString stringWithFormat:@"http://media2.neu6.edu.cn/hls/%@.m3u8", _videoSource];
                [listArr lastObject].status = NSLocalizedString(@"TelevisionChannelPlayListPlaying", nil);
            }
        }
        
        [listDic setObject:listArr.copy forKey:date];
        [listArr removeAllObjects];
    }
    _TelevisionChannelDic = listDic;
}

- (NSArray *)televisionChannelModelSelectionTypeArray {

    NSMutableArray *keyArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < 8; ++i) {
        NSString *selectStr = [NSString stringWithFormat:@"%d", i];
        NSString *dateStr = [LYTool dateOfTimeIntervalFromToday:i];
        NSDictionary *tempDic = @{
                                  selectStr : dateStr
                                  };
        [keyArr addObject:tempDic];
    }
    return keyArr;
}


- (NSArray *)televisionChannelSelectionDayArrayWithType {
    if (_selectedType) {
    } else {
        _selectedType = TelevisionChannelModelSelectionTypeToday;
    }
    if ([self.TelevisionChannelDic objectForKey:[LYTool dateOfTimeIntervalFromToday:self.selectedType]]) {
        return [self.TelevisionChannelDic objectForKey:[LYTool dateOfTimeIntervalFromToday:self.selectedType]];
    } else {
        return nil;
    }
}

#pragma mark - Setter

- (void)setSelectedType:(TelevisionChannelModelSelectionType)selectedType {
    _selectedType = selectedType;
}

#pragma mark - Getter
- (NSArray<TelevisionChannelScheduleBean *> *)beanArray {
    if (!_beanArray) {
        _beanArray = [NSArray array];
    }
    _beanArray = [self televisionChannelSelectionDayArrayWithType].copy;
    
    return _beanArray;
}

- (NSMutableArray<TelevisionChannelScheduleBean *> *)playingArray {
    if (!_playingArray) {
        _playingArray = [NSMutableArray arrayWithCapacity:0];
    }
    if (_selectedType == TelevisionChannelModelSelectionTypeToday) {
        [_playingArray removeAllObjects];
        if (self.beanArray.count != 0) {
            for (TelevisionChannelScheduleBean *bean in self.beanArray) {
                NSComparisonResult result = [bean.time compare:[LYTool timeOfNow]];
                if (result == NSOrderedAscending) {
                    [_playingArray addObject:bean];
                }
            }
        } else {
            TelevisionChannelScheduleBean *bean = [[TelevisionChannelScheduleBean alloc] init];
            bean.videoUrl = [NSString stringWithFormat:@"http://media2.neu6.edu.cn/hls/%@.m3u8", self.videoSource];
            [_playingArray addObject:bean];
        }
    }
    
    return _playingArray;
}

- (NSString *)sourceStr {
    return self.videoSource;
}

@end

@implementation TelevisionChannelScheduleBean

@end
