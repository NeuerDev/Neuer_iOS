//
//  LibraryRecommendModel.m
//  NEUer
//
//  Created by kl h on 2017/11/7.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryRecommendModel.h"

@interface LibraryRecommendModel () <JHRequestDelegate>

@end

@implementation LibraryRecommendModel
#pragma mark - Public Methods
- (void)recommend {
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/apsm/recommend/recommend_do.jsp"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url method:@"POST" params:@{@"Z13_TITLE":_title.URLEncode,@"LIBRARY":_language.URLEncode,@"Z13_AUTHOR":_author.URLEncode,@"Z13_IMPRINT":_press.URLEncode,@"Z13_YEAR":_yearOfPublication.URLEncode,@"Z13_ISBN_ISSN":_ISBN.URLEncode,@"Z13_PRICE":_price.URLEncode,@"Z303_REC_KEY":_REC_key.URLEncode,@"Z68_NO_UNITS":_recommendNum.URLEncode,@"Z46_REQUEST_PAGES":_recommendReason.URLEncode}];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    
}

- (void)requestDidFail:(JHRequest *)request {
    
}




@end
