//
//  LibraryLoginModel.h
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LibraryLoginBean;
@class LibraryLoginMyInfoBorrowingBean;
@class LibraryLoginMyInfoBorrowHistoryBean;
@class LibraryLoginMyInfoReservationBean;
@class LibraryLoginMyInfoBookedBean;
@class LibraryLoginMyInfoCashBean;

typedef NS_ENUM(NSUInteger, LibraryInfoReturnDateLevel) {
    LibraryInfoReturnDateLevelLow,
    LibraryInfoReturnDateLevelMiddle,
    LibraryInfoReturnDateLevelHigh
};


@protocol LibraryLoginDelegate <NSObject>
@optional
- (void)loginDidSuccess;
- (void)getBorrowHistoryInfoDidSuccess;
- (void)getReservationInfoDidSuccess;
- (void)getBookedInfoDidSuccess;
- (void)getCashInfoDidSuccess;
- (void)partRenewalDidSuccess;
@end


//图书馆model
@interface LibraryLoginModel : NSObject
//登录
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *tmpURL;
@property (nonatomic, strong) LibraryLoginBean *loginBean;
//信息
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
@property (nonatomic, weak) id <LibraryLoginDelegate> delegate;


/**
 登录图书馆
 */
- (void)gotoLogin;

/**
 查询借阅历史
 */
- (void)searchBorrowHistoryInfo;

/**
 查询预约请求
 */
- (void)searchReservationInfo;

/**
 查询预定请求
 */
- (void)searchBookedInfo;

/**
 查询现金事务
 */
- (void)searchCashInfo;


/**
 部分续借

 @param renewNumber 续借编号
 */
- (void)partRenewalWithRenewNumber:(NSString *)renewNumber;

/**
 全部续借
 */
- (void)allRenewal;

@end



//图书馆登录bean
@interface LibraryLoginBean : NSObject
//我的流通
@property (nonatomic, strong) NSString *borrowingStr;
@property (nonatomic, strong) NSString *borrowHistoryStr;
@property (nonatomic, strong) NSString *reservationStr;
@property (nonatomic, strong) NSString *bookedStr;
@property (nonatomic, strong) NSString *cashStr;
@property (nonatomic, strong) NSString *arrearsStr;
//我的基本信息
@property (nonatomic, strong) NSString *nameStr;
@property (nonatomic, strong) NSString *collegeStr;
@property (nonatomic, strong) NSString *languageStr;
@property (nonatomic, strong) NSString *gradeStr;
@property (nonatomic, strong) NSString *addressBeginStr;
@property (nonatomic, strong) NSString *addressEndStr;
@property (nonatomic, strong) NSString *statusStr;
@property (nonatomic, strong) NSString *barCodeStr;
@property (nonatomic, strong) NSString *registrationStr;
//其他
@property (nonatomic, assign) LibraryInfoReturnDateLevel returnDateLevel;
@property (nonatomic, assign) NSInteger days;

@end

//外借bean
@interface LibraryLoginMyInfoBorrowingBean : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *yearOfPublication;
@property (nonatomic, strong) NSString *shouldReturnDate;
@property (nonatomic, strong) NSString *fine;
@property (nonatomic, strong) NSString *branch;
@property (nonatomic, strong) NSString *claimNumber;
@property (nonatomic, strong) NSString *itemDescription;
@property (nonatomic, strong) NSString *renewNumber;
@property (nonatomic, assign) LibraryInfoReturnDateLevel returnDateLevel;

@end

//借阅历史bean
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
//预约请求bean
@interface LibraryLoginMyInfoReservationBean : NSObject
@end
//预定请求bean
@interface LibraryLoginMyInfoBookedBean : NSObject
@end
//现金事务bean
@interface LibraryLoginMyInfoCashBean : NSObject
@end
