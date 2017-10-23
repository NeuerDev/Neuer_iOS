//
//  SearchLibraryResultModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchLibraryResultModel.h"

@interface SearchLibraryResultModel () <JHRequestDelegate>
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, assign) NSInteger scope;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) NSString *tmpUrl;

@end

@implementation SearchLibraryResultModel

#pragma mark - Init Methods

- (instancetype)init {
    return [self initWithKeyword:@"" scope:0];
}

- (instancetype)initWithKeyword:(NSString *)keyword scope:(NSInteger)scope {
    if (self = [super init]) {
        _keyword = keyword;
        _scope = scope;
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)searchWithKeyword:(NSString *)keyword scope:(NSInteger)scope {
    _keyword = keyword;
    _scope = scope;
    [self search];
}

- (void)search {
    _resultsArray = @[].mutableCopy;
    NSString *scopeStr = @[@"WRD", @"WTI", @"WAU", @"WPU"][_scope];
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/F?func=find-b&request=%@&find_code=%@", _keyword.URLEncode, scopeStr.URLEncode];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)loadMore {
    NSString *urlStr = [NSString stringWithFormat:@"%@/F?func=short-jump&jump=%ld", _tmpUrl, _resultsArray.count+1];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeIgnoreFollow;
    [request start];
}

- (BOOL)hasMore {
    return _totalCount>_resultsArray.count;
}

#pragma mark - JHRequestDelegate

- (void)requestDidSuccess:(JHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate searchWillComplete];
    });
    NSData *htmlData = request.response.data;
    [_resultsArray addObjectsFromArray:[self resultArrayFromHtmlData:htmlData]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate searchDidSuccess];
    });
}

- (void)requestDidFail:(JHRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate searchWillComplete];
        [_delegate searchDidFail:@"发生了错误"];
    });
}

#pragma mark - Private Methods

- (NSArray<SearchLibraryResultBean *> *)resultArrayFromHtmlData:(NSData *)htmlData {
    NSMutableArray<SearchLibraryResultBean *> *resultArray = [NSMutableArray arrayWithCapacity:0];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray<TFHppleElement *> *countItemArray = [xpathParser searchWithXPathQuery:@"//div[@class='hitnum']"];
    NSString *totalNumberString = @"";
    if (countItemArray.count>0) {
        NSMutableString *totalNumberOriginString = @"".mutableCopy;
        for (TFHppleElement *textElement in [countItemArray[0] childrenWithTagName:@"text"]) {
            [totalNumberOriginString appendString:(textElement.content?:@"")];
        }
        totalNumberString = [[totalNumberOriginString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if ([totalNumberString rangeOfString:@"of"].location!=NSNotFound && [totalNumberString rangeOfString:@"(最大显示记录"].location!=NSNotFound) {
        totalNumberString = [totalNumberString substringFromIndex:[totalNumberString rangeOfString:@"of"].location+2];
        totalNumberString = [totalNumberString substringToIndex:[totalNumberString rangeOfString:@"(最大显示记录"].location];
        _totalCount = [totalNumberString integerValue];
        self.hint = [NSLocalizedString(@"SearchLibraryResultFoundNumberSubfix", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:totalNumberString];
    } else {
        self.hint = NSLocalizedString(@"SearchLibraryResultNotFound", nil);
        _totalCount = 0;
        return @[];
    }
    
    // 获取 var tmp 暂存索引 服务器生成的 必须保存
    NSArray<TFHppleElement *> *scriptArray = [xpathParser searchWithXPathQuery:@"//head/script"];
    for (TFHppleElement *script in scriptArray) {
        NSString *content = [script.firstChild.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([content hasPrefix:@"var tmp="]) {
            content = [content substringFromIndex:@"var tmp=\"".length];
            content = [content substringToIndex:(content.length-@"\";".length)];
            _tmpUrl = content;
            break;
        }
    }
    
    NSArray<TFHppleElement *> *itemArray = [xpathParser searchWithXPathQuery:@"//table[@class='items']/tr"];
    @autoreleasepool {
        for (TFHppleElement *item in itemArray) {
            SearchLibraryResultBean *bean = [[SearchLibraryResultBean alloc] init];
            
            // imageUrl
            TFHppleElement *imageElement = [[[item firstChildWithClassName:@"cover"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"];
            bean.imageUrl = [imageElement objectForKey:@"src"];
            
            // title
            TFHppleElement *titleElement = [[[item firstChildWithClassName:@"col2"] firstChildWithClassName:@"itemtitle"] firstChildWithTagName:@"a"];
            bean.title = [titleElement text];
            
            // properties
            NSArray<TFHppleElement *> *propertyElementArray = [[[item firstChildWithClassName:@"col2"] firstChildWithTagName:@"table"] childrenWithTagName:@"tr"];
            NSMutableArray<NSString *> *contentArray = [NSMutableArray arrayWithCapacity:0];
            for (TFHppleElement *propertyElement in propertyElementArray) {
                for (TFHppleElement *contentElement in [propertyElement childrenWithClassName:@"content"]) {
                    NSString *content = [contentElement text] ? : @"";
                    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [contentArray addObject:content];
                }
            }
            
            // stock
            TFHppleElement *libElement = [[[propertyElementArray lastObject] firstChildWithClassName:@"libs"] firstChildWithTagName:@"a"];
            NSString *htmlTemp = [libElement objectForKey:@"onmouseover"];
            htmlTemp = [htmlTemp substringFromIndex:([htmlTemp rangeOfString:@"hint('"].location+@"hint('".length)];
            htmlTemp = [htmlTemp substringToIndex:[htmlTemp rangeOfString:@"',this)"].location];
            TFHpple *parser = [[TFHpple alloc] initWithHTMLData:[htmlTemp dataUsingEncoding:NSUTF8StringEncoding]];
            NSArray<TFHppleElement *> *libItemArray = [parser searchWithXPathQuery:@"/html/body/tr"];
            for (TFHppleElement *libItem in libItemArray) {
                NSArray<TFHppleElement *> *libItemDetailArray = libItem.children;
                if (libItemDetailArray.count>=3) {
                    NSString *location = libItemDetailArray[0].firstChild.text ? : @"";
                    NSString *bookStock = [libItemDetailArray[2].text stringByReplacingOccurrencesOfString:@" " withString:@""] ? : @"";
                    NSArray *stockArray = [bookStock componentsSeparatedByString:@"/"];
                    if (stockArray.count==2) {
                        bookStock = [NSString stringWithFormat:@"%@ / %@", stockArray[1], stockArray[0]];
                    }
                    if (bean.stockLocation) {
                        bean.stockLocation = [bean.stockLocation stringByAppendingString:[NSString stringWithFormat:@"\n%@\t%@", location, bookStock]];
                    } else {
                        bean.stockLocation = [NSString stringWithFormat:@"\n%@\t%@", location, bookStock];
                    }
                } else {
                    bean.stockLocation = @"";
                }
            }
            
            bean.author = contentArray[0];
            bean.callNumber = contentArray[1].length>0?contentArray[1]:@"暂无";
            bean.press = contentArray[2];
            bean.year = contentArray[3];
            
            [resultArray addObject:bean];
        }
    }
    
    return resultArray;
}

#pragma mark - Getter

- (NSString *)hint {
    if (!_hint) {
        _hint = @"";
    }
    
    return _hint;
}

@end

@implementation SearchLibraryResultBean

@end

@implementation SearchLibraryResultLocationBean

@end

