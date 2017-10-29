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
//    _videoSource = [LYTool subStringFromString:videoUrl startString:@"hls/" endString:@".m3u8"];
    NSString *urlStr = [NSString stringWithFormat:@"http://hdtv.neu6.edu.cn/newplayer?p=%@", self.videoSource];
    JHRequest *request = [[JHRequest alloc] initWithUrl:[NSURL URLWithString:urlStr]];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (NSDictionary *)TelevisionChannelDictionary {
    return self.TelevisionChannelDic;
}

- (NSArray *)TelevisionChannelSelectionDayArrayWithType:(TelevisionChannelModelSelectionType)type {
    _selectedType = type;
    if ([self.TelevisionChannelDic objectForKey:[LYTool dateOfTimeIntervalFromToday:self.selectedType]]) {
        return [self.TelevisionChannelDic objectForKey:[LYTool dateOfTimeIntervalFromToday:self.selectedType]];
    } else {
        return nil;
    }
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
    NSMutableArray *listArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    //    日期div
    NSArray <TFHppleElement *>* dateArray = [hpple searchWithXPathQuery:@"//*[@id='tabs']/div"];
    
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
                            [listArr addObject:bean];
                            bean = [[TelevisionChannelScheduleBean alloc] init];
                        }
                    } else {
                        continue;
                    }
                }
            } else {
                continue;
            }
        }
        [listDic setObject:listArr.copy forKey:date];
        [listArr removeAllObjects];
    }
    _TelevisionChannelDic = listDic;
}

- (NSArray *)TelevisionChannelModelSelectionTypeArray {

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

- (NSString *)sourceStr {
    return self.videoSource;
}

@end

@implementation TelevisionChannelScheduleBean

@end
