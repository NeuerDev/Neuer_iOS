//
//  LibraryBookListComponent.h
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SearchLibraryNewBookModel;
@class SearchLibraryBorrowingModel;
@class LibraryBookListComponent;

@protocol LibraryBookListComponentDelegate <NSObject>

@required
- (void)component:(LibraryBookListComponent *)component didSelectedString:(NSString *)string;

@end

typedef NS_ENUM(NSInteger,ComponentModelType) {
    ComponentModelTypeNewBook,
    ComponentModelTypeMost
};

@interface LibraryBookListComponent : NSObject
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) SearchLibraryNewBookModel *newbookModel;
@property (nonatomic, strong) SearchLibraryBorrowingModel *mostModel;
@property (nonatomic, assign) ComponentModelType modelType;
@property (nonatomic, weak) id <LibraryBookListComponentDelegate> delegate;

- (instancetype)initWithModelType:(ComponentModelType)type;
- (UIView *)view;
- (void)setStrings:(NSArray<NSString *> *)strings;

@end
