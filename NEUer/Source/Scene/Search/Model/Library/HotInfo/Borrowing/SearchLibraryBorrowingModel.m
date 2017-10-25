//
//  SearchLibraryBorrowingModel.m
//  NEUer
//
//  Created by kl h on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchLibraryBorrowingModel.h"

@interface SearchLibraryBorrowingModel () <JHRequestDelegate>

@end

@implementation SearchLibraryBorrowingModel
#pragma mark - Public Methods
- (void)search {
    _resultArray = [NSMutableArray array];
    _languageType = @"ALL"; // ALL:全部 01:中文文献库 02:外文文献库
//    _sortType = @"ALL";     // ALL:全部 A:马列主义、毛泽东思想、邓小平理论 B:宗教、哲学 C:社会科学总论 D:政治、法律 E:军事 F:经济 G:文化、科学、教育、体育
                            // H:语言、文字 I:文学 J:艺术 K:历史、地理 N:自然科学总论 O:数理科学与化学 O2:数学 O3:力学 O4:物理学1 O5:物理学2 O6:化学
                            // O7:晶体学 P:天文学、地球科学 Q:生物科学 R:医药、卫生 S:农业科学 T:工业技术 TB:一般工业技术 TD:矿业工程 TE:石油、天然气工业
                            // TF:冶金工业 TG:金属学与金属工艺 TH:机械、仪表工业 TJ:武器工业 TK:能源与动力工程 TL:原子能技术 TM:电子技术
                            // TN:无线电电子学、电信技术 TP:自动化技术、计算机技术 TQ:化学工业 TS:轻工业、手工业 TU:建筑科学 TV:水利工程 U:交通运输
                            // V:航空、航天 X:环境科学、安全科学 Z:综合性图书
//    _date = @"y";           // y:最近一年 s:最近三月 m:最近一月 w:最近一周
    
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/opac_lcl_chi/loan_top_ten/loan.%@.%@.%@",_languageType.URLEncode,_sortType.URLEncode,_date.URLEncode];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    NSData *htmlData = request.response.data;
    _resultArray = [self resultArrayFromHtmlData:htmlData];
//    [_resultArray addObjectsFromArray:[self resultArrayFromHtmlData:htmlData]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate searchDidSuccess];
    });
}

- (void)requestDidFail:(JHRequest *)request {
   
    
}

#pragma mark - Private Methods
- (NSMutableArray<SearchLibraryBorrowingBean *> *)resultArrayFromHtmlData:(NSData *)htmlData {
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements = [doc searchWithXPathQuery:@"//a[@target='_blank']"];
    NSMutableArray *array = [NSMutableArray array];
    for (TFHppleElement *e in elements) {
        SearchLibraryBorrowingBean *bean = [[SearchLibraryBorrowingBean alloc] init];
        NSString *content = [e text];
        content = [content stringByReplacingOccurrencesOfString:@"," withString:@""];
        content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *contentArray = [content componentsSeparatedByString:@"借阅次数:"];
        bean.count = contentArray[1];
        contentArray = [contentArray[0] componentsSeparatedByString:@"("];
        bean.title = contentArray[0];
        bean.author = [contentArray[1] componentsSeparatedByString:@")"][0];
        [array addObject:bean];
    }
    
    return [array copy];
}


@end

@implementation SearchLibraryBorrowingBean

@end
