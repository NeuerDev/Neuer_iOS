//
//  LibraryNewBookViewController.m
//  NEUer
//
//  Created by kl h on 2017/10/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryNewBookViewController.h"
#import "LibraryBookListComponent.h"
#import "SearchLibraryNewBookModel.h"

@interface LibraryNewBookViewController () <SearchLibraryNewBookDelegate,LibraryBookListComponentDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) LibraryBookListComponent *bookListComponent;
@property (nonatomic, strong) SearchLibraryNewBookModel *model;

@end

@implementation LibraryNewBookViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

#pragma mark - Init Methods
- (void)initData {
    [self setTitle:@"新手通报"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.model search];
}

- (void)initConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
        make.left.and.right.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.bookListComponent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark - SearchLibraryNewBookDelegate
- (void)searchDidSuccess {
    NSMutableArray *array = [NSMutableArray array];
    for (SearchLibraryNewBookBean *bean in self.model.resultArray) {
        [array addObject:bean.title];
    }
    [self.bookListComponent setStrings:array];
}

- (void)searchDidFail:(NSString *)message {
    
}

#pragma mark - LibraryBookListComponentDelegate
- (void)component:(LibraryBookListComponent *)component didSelectedString:(NSString *)string {
    
}

#pragma mark - Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_scrollView];
    }
   return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self.scrollView addSubview:_contentView];
    }
   return _contentView;
}

- (LibraryBookListComponent *)bookListComponent {
    if (!_bookListComponent) {
        _bookListComponent = [[LibraryBookListComponent alloc] initWithModelType:ComponentModelTypeNewBook];
        _bookListComponent.viewController = self;
        _bookListComponent.newbookModel = self.model;
        [self.contentView addSubview:_bookListComponent.view];
    }
   return _bookListComponent;
}

- (SearchLibraryNewBookModel *)model
{
   if (!_model) {
       _model = [[SearchLibraryNewBookModel alloc] init];
       _model.languageType = @"ALL";
       _model.sortType = @"ALL";
       _model.date = @"180";
       _model.delegate = self;
    }
   return _model;
}




@end
