//
//  TVOfYesterdayModel.m
//  NEUer
//
//  Created by lanya on 2017/10/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TVOfYesterdayModel.h"
#import <hpple/TFHpple.h>
#import "AFNetworking.h"
#import "LYTool.h"

@interface TVOfYesterdayModel() <JHRequestDelegate>

@property (nonatomic, strong) NSDictionary *TVOfYesterdayDic;

@end

@implementation TVOfYesterdayModel

- (instancetype)init {
    if (self = [super init]) {
        _TVOfYesterdayDic = [NSDictionary dictionary];
    }
    return self;
}

- (void)fecthTVOfYesterdayDataWithVideoUrl:(NSString *)videoUrl {
    //    http://hdtv.neu6.edu.cn/newplayer?p=btv6hd
    
    NSString *subVideoUrl = [LYTool subStringFromString:videoUrl startString:@"hls/" endString:@".m3u8"];
    NSString *urlStr = [NSString stringWithFormat:@"http://hdtv.neu6.edu.cn/newplayer?p=%@", subVideoUrl];
    JHRequest *request = [[JHRequest alloc] initWithUrl:[NSURL URLWithString:urlStr]];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];

}

#pragma mark - JHRequestDelegate

- (void)requestDidFail:(JHRequest *)request {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate) {
            [_delegate fetchTVOfYesterdayModelFailureWithMsg:@"加载失败！"];
        } else {
            NSLog(@"没有代理");
        }
    });
}

- (void)requestDidSuccess:(JHRequest *)request {
    
    NSData *htmlData = request.response.data;
    
    [self updateTVOfYesterdayDataWithHtmlData:htmlData];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate) {
            [_delegate fetchTVOfYesterdayModelSuccess];
        } else {
            NSLog(@"没代理");
        }
    });
}

#pragma mark - PrivateMethod

- (void)updateTVOfYesterdayDataWithHtmlData:(NSData *)htmlData {
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
                
                TVOfYesterdayBean *bean = [[TVOfYesterdayBean alloc] init];
                for (int i = 0; i < [elements childrenWithTagName:@"div"].count; ++i) {
                    TFHppleElement *element = [elements childrenWithTagName:@"div"][i];
                    bean.TVShowDate = date;
                    if ([element.attributes[@"id"] isEqualToString:@"list_status"]) {
                        TFHppleElement *urlElement = [element firstChildWithTagName:@"a"];
                        //                    转化成可以播放的视频地址
                        NSString *urlStr = [@"http://hdtv.neu6.edu.cn/" stringByAppendingString:[urlElement objectForKey:@"href"]];
                        
                        bean.TVShowURL = urlStr;
                    } else if ([element.attributes[@"id"] isEqualToString:@"list_item"]) {
                        NSString *text = element.text;
                        NSArray *textArr = [text componentsSeparatedByString:@" "];
                        bean.TVShowTime = [textArr objectAtIndex:0];
                        if (textArr.count > 2) {
                            bean.TVShowName = [textArr componentsJoinedByString:@" "];
                        } else {
                            bean.TVShowName = [textArr lastObject];
                        }
                        
                    } else {
                        NSLog(@"%@", [element objectForKey:@"id"]);
                    }
                    if (i % 2 != 0) {
                        if (bean.TVShowName != nil && bean.TVShowTime != nil && bean.TVShowURL != nil) {
                            [listArr addObject:bean];
                            bean = [[TVOfYesterdayBean alloc] init];
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
    _TVOfYesterdayDic = listDic;
}

- (NSDictionary *)TVOfYesterdayDictionary {
    return self.TVOfYesterdayDic;
}

- (NSArray *)TVOfYesterdaySelectionDayArrayWithType:(TVOfYesterdaySelectionType)type {
    _selectedType = type;
    if ([self.TVOfYesterdayDic objectForKey:[LYTool dateOfTimeIntervalFromToday:self.selectedType]]) {
        return [self.TVOfYesterdayDic objectForKey:[LYTool dateOfTimeIntervalFromToday:self.selectedType]];
    } else {
        return nil;
    }
}

@end

@implementation TVOfYesterdayBean

@end

