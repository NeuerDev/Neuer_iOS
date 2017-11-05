//
//  LibraryLoginMyInfoModel.m
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryLoginMyInfoModel.h"

@interface LibraryLoginMyInfoModel () <JHRequestDelegate>

@property (nonatomic, assign) int infoType;

@end

@implementation LibraryLoginMyInfoModel

#pragma mark - Public Methods
- (void)searchBorrowingInfo {
    _borrowingArr = [NSMutableArray array];
    _infoType = 1;
    
    NSURL *url = [NSURL URLWithString:_borrowingURL];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
    
}

- (void)searchBorrowHistoryInfo {
    _borrowHistoryArr = [NSMutableArray array];
    _infoType = 2;
    
    NSURL *url = [NSURL URLWithString:_borrowHistoryURL];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)searchReservationInfo {
    _reservationArr = [NSMutableArray array];
    _infoType = 3;
    
    NSURL *url = [NSURL URLWithString:_reservationURL];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)searchBookedInfo {
    _bookedArr = [NSMutableArray array];
    _infoType = 4;
    
    NSURL *url = [NSURL URLWithString:_bookedURL];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

- (void)searchCashInfo {
    _cashArr = [NSMutableArray array];
    _infoType = 5;
    
    NSURL *url = [NSURL URLWithString:_cashURL];
    
    JHRequest *request = [[JHRequest alloc] initWithUrl:url];
    request.delegate = self;
    request.requestType = JHRequestTypeCancelPrevious;
    [request start];
}

#pragma mark - JHRequestDelegate
- (void)requestDidSuccess:(JHRequest *)request {
    NSData *htmlData = request.response.data;
    switch (_infoType) {
        case 1: {
            _borrowingArr = [self borrowingArrayFromHtmlData:htmlData];
            [_delegate getBorrowingInfoDidSuccess];
        }
            break;
            
        case 2: {
            _borrowHistoryArr = [self borrowHistoryArrayFromHtmlData:htmlData];
            [_delegate getBorrowHistoryInfoDidSuccess];
        }
            break;
            
        case 3: {
            
        }
            break;
            
        case 4: {
            
        }
            break;
            
        case 5: {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)requestDidFail:(JHRequest *)request {
    
}

#pragma mark - Private Methods
- (NSMutableArray<LibraryLoginMyInfoBorrowingBean *> *)borrowingArrayFromHtmlData:(NSData *)htmlData {
    NSMutableArray *array = [NSMutableArray array];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray<TFHppleElement *> *tdArr = [xpathParser searchWithXPathQuery:@"//td[@class='td1']"];
    int num = (int)(tdArr.count - 1) / 11;
    for (int i = 0; i < num; i++) {
        LibraryLoginMyInfoBorrowingBean *bean = [[LibraryLoginMyInfoBorrowingBean alloc] init];
        bean.author = [tdArr[i*11+3] text];
        bean.yearOfPublication = [tdArr[i*11+5] text];
        bean.shouldReturnDate = [tdArr[i*11+6] text];
        bean.branch = [tdArr[i*11+8] text];
        bean.claimNumber = [tdArr[i*11+9] text];
        if ([tdArr[i*11+10] text]) {
            bean.itemDescription = [tdArr[i*11+10] text];
        }
        [array addObject:bean];
    }
    
    NSArray<TFHppleElement *> *titleArr = [xpathParser searchWithXPathQuery:@"//td/a"];
    for (int i = 0; i < num; i++) {
        ((LibraryLoginMyInfoBorrowingBean *)array[i]).title = [titleArr[i*3+8] text];
    }
    
    return array;
}

- (NSMutableArray<LibraryLoginMyInfoBorrowHistoryBean *> *)borrowHistoryArrayFromHtmlData:(NSData *)htmlData {
    NSMutableArray *array = [NSMutableArray array];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray<TFHppleElement *> *tdArr = [xpathParser searchWithXPathQuery:@"//td[@class='td1']"];
    int num = (int)(tdArr.count - 1) / 10;
    for (int i = 0; i < num; i++) {
        LibraryLoginMyInfoBorrowHistoryBean *bean = [[LibraryLoginMyInfoBorrowHistoryBean alloc] init];
        bean.year = [tdArr[i*10+4] text];
        bean.shouldReturnDate = [tdArr[i*10+5] text];
        bean.shouldReturnTime = [tdArr[i*10+6] text];
        bean.returnDate = [tdArr[i*10+7] text];
        bean.returnTime = [tdArr[i*10+8] text];
        if ([tdArr[i*10+9] text]) {
            bean.fine = [tdArr[i*10+9] text];
        }
        bean.branch = [tdArr[i*10+10] text];
        [array addObject:bean];
    }
    
    NSArray<TFHppleElement *> *titleArr = [xpathParser searchWithXPathQuery:@"//td/a"];
    for (int i = 0; i < num; i++) {
        ((LibraryLoginMyInfoBorrowHistoryBean *)array[i]).author = [titleArr[i*3+7] text];
        ((LibraryLoginMyInfoBorrowHistoryBean *)array[i]).title = [titleArr[i*3+8] text];
    }
    return array;
}

- (NSMutableArray<LibraryLoginMyInfoReservationBean *> *)reservationArrayFromHtmlData:(NSData *)htmlData {
    NSMutableArray *array = [NSMutableArray array];
    return array;
}

- (NSMutableArray<LibraryLoginMyInfoBookedBean *> *)bookedArrayFromHtmlData:(NSData *)htmlData {
    NSMutableArray *array = [NSMutableArray array];
    return array;
}

- (NSMutableArray<LibraryLoginMyInfoCashBean *> *)cashArrayFromHtmlData:(NSData *)htmlData {
    NSMutableArray *array = [NSMutableArray array];
    return array;
}

@end

@implementation LibraryLoginMyInfoBorrowingBean

@end

@implementation LibraryLoginMyInfoBorrowHistoryBean

@end

@implementation LibraryLoginMyInfoReservationBean

@end

@implementation LibraryLoginMyInfoBookedBean

@end

@implementation LibraryLoginMyInfoCashBean

@end
