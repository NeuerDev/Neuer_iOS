//
//  LibraryRecommendModel.m
//  NEUer
//
//  Created by kl h on 2017/11/7.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryRecommendModel.h"
#import "LibraryLoginModel.h"

@interface LibraryRecommendModel () <JHRequestDelegate>
@property (nonatomic, assign) BOOL isGetKey;

@end

@implementation LibraryRecommendModel
#pragma mark - Public Methods
- (void)getREC_key {
    _isGetKey = NO;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8118/apsm/recommend/recommend.jsp?url_id=%@",[LibraryCenter defaultCenter].currentModel.recommendURL.URLEncode];
    NSURL *url = [NSURL URLWithString:urlStr];
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)recommendWithTitle:(NSString *)title author:(NSString *)author press:(NSString *)press ISBN:(NSString *)ISBN reason :(NSString *)reason {
    _language = @"01";
    _yearOfPublication = @"";
    _price = @"";
    _recommendNum = @"1";
    
    _title = title;
    _author = author;
    _press = press;
    _ISBN = ISBN;
    _recommendReason = reason;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8118/apsm/recommend/recommend_do.jsp"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url method:@"POST" params:@{@"Z13_TITLE":_title.URLEncode,@"LIBRARY":_language.URLEncode,@"Z13_AUTHOR":_author.URLEncode,@"Z13_IMPRINT":_press.URLEncode,@"Z13_YEAR":_yearOfPublication.URLEncode,@"Z13_ISBN_ISSN":_ISBN.URLEncode,@"Z13_PRICE":_price.URLEncode,@"Z303_REC_KEY":_REC_key.URLEncode,@"Z68_NO_UNITS":_recommendNum.URLEncode,@"Z46_REQUEST_PAGES":_recommendReason.URLEncode}];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    NSData *htmlData = request.response.data;
    if (!_isGetKey) {
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
        NSArray<TFHppleElement *> *tdArr = [doc searchWithXPathQuery:@"//input[@name='Z303_REC_KEY']"];
        _REC_key = [tdArr[0] objectForKey:@"value"];
        _isGetKey = YES;
    } else {
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
        NSArray<TFHppleElement *> *spanArr = [doc searchWithXPathQuery:@"//span[@class='title']"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate recommendDidSuccess:[spanArr[0] text]];
        });
    }
    
}

- (void)requestDidFail:(JHRequest *)request {
    
}




@end
