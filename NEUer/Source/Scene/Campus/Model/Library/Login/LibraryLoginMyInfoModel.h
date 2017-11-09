//
//  LibraryLoginMyInfoModel.h
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LibraryLoginMyInfoBorrowingBean;
@class LibraryLoginMyInfoBorrowHistoryBean;
@class LibraryLoginMyInfoReservationBean;
@class LibraryLoginMyInfoBookedBean;
@class LibraryLoginMyInfoCashBean;


@protocol LibraryLoginInfoDelegate <NSObject>
@optional
- (void)getBorrowingInfoDidSuccess;
- (void)getBorrowHistoryInfoDidSuccess;
- (void)getReservationInfoDidSuccess;
- (void)getBookedInfoDidSuccess;
- (void)getCashInfoDidSuccess;
@end

@interface LibraryLoginMyInfoModel : NSObject
@property (nonatomic, strong) NSString *borrowingURL;
@property (nonatomic, strong) NSString *borrowHistoryURL;
@property (nonatomic, strong) NSString *reservationURL;
@property (nonatomic, strong) NSString *bookedURL;
@property (nonatomic, strong) NSString *cashURL;

@property (nonatomic, strong) NSMutableArray<LibraryLoginMyInfoBorrowingBean *> *borrowingArr;
@property (nonatomic, strong) NSMutableArray<LibraryLoginMyInfoBorrowHistoryBean *> *borrowHistoryArr;
@property (nonatomic, strong) NSMutableArray<LibraryLoginMyInfoReservationBean *> *reservationArr;
@property (nonatomic, strong) NSMutableArray<LibraryLoginMyInfoBookedBean *> *bookedArr;
@property (nonatomic, strong) NSMutableArray<LibraryLoginMyInfoCashBean *> *cashArr;

@property (nonatomic, weak) id <LibraryLoginInfoDelegate> delegate;

- (void)searchBorrowingInfo;
- (void)searchBorrowHistoryInfo;
- (void)searchReservationInfo;
- (void)searchBookedInfo;
- (void)searchCashInfo;

@end
typedef NS_ENUM(NSUInteger, ReturnDateLevel) {
    ReturnDateLevelLow,
    ReturnDateLevelHigh
};

@interface LibraryLoginMyInfoBorrowingBean : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *yearOfPublication;
@property (nonatomic, strong) NSString *shouldReturnDate;
@property (nonatomic, strong) NSString *fine;
@property (nonatomic, strong) NSString *branch;
@property (nonatomic, strong) NSString *claimNumber;
@property (nonatomic, strong) NSString *itemDescription;
@property (nonatomic, assign) ReturnDateLevel returnDateLevel;

@end

@interface LibraryLoginMyInfoBorrowHistoryBean : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *shouldReturnDate;
@property (nonatomic, strong) NSString *shouldReturnTime;
@property (nonatomic, strong) NSString *returnDate;
@property (nonatomic, strong) NSString *returnTime;
@property (nonatomic, strong) NSString *fine;
@property (nonatomic, strong) NSString *branch;


@end

@interface LibraryLoginMyInfoReservationBean : NSObject

@end

@interface LibraryLoginMyInfoBookedBean : NSObject

@end

@interface LibraryLoginMyInfoCashBean : NSObject

@end
