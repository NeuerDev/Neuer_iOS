//
//  SearchLibraryNewBookModel.m
//  NEUer
//
//  Created by kl h on 2017/10/9.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchLibraryNewBookModel.h"

@interface SearchLibraryNewBookModel () <JHRequestDelegate>

@end

@implementation SearchLibraryNewBookModel
#pragma mark - Public Methods
- (void)search {
    _resultArray = [NSMutableArray array];
    _languageType = @"ALL"; // ALL:全部 01:中文文献库 02:外文文献库
    _sortType = @"ALL";     // ALL:全部 A:马列主义、毛泽东思想、邓小平理论 B:宗教、哲学 C:社会科学总论 D:政治、法律 E:军事 F:经济 G:文化、科学、教育、体育
                            // H:语言、文字 I:文学 J:艺术 K:历史、地理 N:自然科学总论 O:数理科学与化学 O2:数学 O3:力学 O4:物理学1 O5:物理学2 O6:化学
                            // O7:晶体学 P:天文学、地球科学 Q:生物科学 R:医药、卫生 S:农业科学 T:工业技术 TB:一般工业技术 TD:矿业工程 TE:石油、天然气工业
                            // TF:冶金工业 TG:金属学与金属工艺 TH:机械、仪表工业 TJ:武器工业 TK:能源与动力工程 TL:原子能技术 TM:电子技术
                            // TN:无线电电子学、电信技术 TP:自动化技术、计算机技术 TQ:化学工业 TS:轻工业、手工业 TU:建筑科学 TV:水利工程 U:交通运输
                            // V:航空、航天 X:环境科学、安全科学 Z:综合性图书
    _date = @"180";         // 180:最近半年 90:最近三月 15:最近一月 7:最近一周
   
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/cgi-bin/newbook.cgi?&base=%@&cls=%@&date=%@",_languageType.URLEncode,_sortType.URLEncode,_date.URLEncode];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
    
}

- (void)loadMore {
    _languageType = @"01";
    _sortType = @"ALL";
    _date = @"180";
    _page = @"2";
    
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/cgi-bin/newbook.cgi?total=%@&base=%@&date=%@&cls=%@&page=%@",_total.URLEncode,_languageType.URLEncode,_date.URLEncode,_sortType.URLEncode,_page.URLEncode];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeIgnoreFollow;
    [request start];
    
}

#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    NSData *jsonData = request.response.data;
    [_resultArray addObjectsFromArray:[self resultArrayFromJsonData:jsonData]];
}

- (void)requestDidFail:(JHRequest *)request {
    
}

#pragma mark - Private Methods
- (NSArray<SearchLibraryNewBookBean *> *)resultArrayFromJsonData:(NSData *)jsonData {
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *navStr = [jsonStr componentsSeparatedByString:@";"][1];
    navStr = [[navStr substringToIndex:navStr.length - 1] substringFromIndex:4];
    _total = [navStr componentsSeparatedByString:@","][0];
    
    jsonStr = [jsonStr componentsSeparatedByString:@";"][0];
    jsonStr = [[jsonStr substringToIndex:jsonStr.length - 1] substringFromIndex:8];
    jsonStr = [jsonStr stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"["];
    jsonStr = [jsonStr stringByReplacingCharactersInRange:NSMakeRange(jsonStr.length - 1, 1) withString:@"]"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"b:" withString:@"\"b\":"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"t:" withString:@"\"t\":"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"[0-9]{4}:" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange (0, jsonStr.length)];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"[0-9]{3}:" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange (0, jsonStr.length)];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"[0-9]{2}:" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange (0, jsonStr.length)];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"[0-9]{1}:" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange (0, jsonStr.length)];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in jsonArray) {
        SearchLibraryNewBookBean *bean = [[SearchLibraryNewBookBean alloc] init];
        bean.type = [dic valueForKey:@"b"];
        NSString *content = [dic valueForKey:@"t"];
        content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
        bean.year = [content componentsSeparatedByString:@"-"].lastObject;
        bean.title = [content componentsSeparatedByString:@"("].firstObject;
        NSRange start = [content rangeOfString:@"："];
        NSRange end = [content rangeOfString:@")"];
        bean.author = [content substringWithRange:NSMakeRange(start.location + 1, end.location - start.location - 1)];
        [array addObject:bean];
    }
    if (err) {
        NSLog(@"error - %@",err);
        return nil;
    } else {
        return [array copy];
    }
}

@end


@implementation SearchLibraryNewBookBean

@end
