//
//  LibraryBookDetailModel.m
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryBookDetailModel.h"

@interface LibraryBookDetailModel () <JHRequestDelegate>
@property (nonatomic, strong) LibraryBookDetailBean *bean;

@end

@implementation LibraryBookDetailModel

#pragma mark - Public Methods
- (void)showDetail {
    _local_base = @"NEU01";
    _bookNumber = @"1413";
    _con_ing = @"chi";
    
    NSString *urlStr = [NSString stringWithFormat:@"http://202.118.8.7:8991/F?func=find-b&find_code=SYS&local_base=%@&request=%@&con_Ing=%@",_local_base.URLEncode,_bookNumber.URLEncode,_con_ing.URLEncode];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    NSData *htmlData = request.response.data;
    TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray<TFHppleElement *> *tdElements = [hpple searchWithXPathQuery:@"//td/a"];
    
    _bean = [[LibraryBookDetailBean alloc] init];
    _bean.bookNumber = _bookNumber;
    _bean.ISBN = [tdElements[0] text];
    _bean.languageType = _con_ing;
    _bean.title = [tdElements[1] text];
    _bean.published = [tdElements[2] text];
    _bean.author = [tdElements[3] text];
    _bean.allTheCollection = [tdElements[5] text];
    
}

- (void)requestDidFail:(JHRequest *)request {
    
}

@end

@implementation LibraryBookDetailBean

@end
