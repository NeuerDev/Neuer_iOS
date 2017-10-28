//
//  LibraryViewController.m
//  NEUer
//
//  Created by kl h on 2017/10/25.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryViewController.h"
#import "LibraryNewBookViewController.h"
#import "LibraryMostViewController.h"
#import "SearchLibraryResultViewController.h"

#import "SearchListComponent.h"

#import "SearchLibraryNewBookModel.h"
#import "SearchLibraryBorrowingModel.h"


@interface LibraryViewController () <SearchListComponentDelegate,SearchLibraryNewBookDelegate,SearchLibraryBorrowingDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) SearchListComponent *newbookSearchComponent;
@property (nonatomic, strong) SearchListComponent *mostSearchComponent;
@property (nonatomic, strong) SearchLibraryNewBookModel *newbookModel;
@property (nonatomic, strong) SearchLibraryBorrowingModel *mostModel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation LibraryViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
    
}

#pragma mark - Init Methods
- (void)initData {
    [self setTitle:@"图书馆"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.newbookModel search];
    [self.mostModel search];
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
    
    [self.newbookSearchComponent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.contentView);
        make.height.mas_equalTo(20 * 44);
    }];
    
    [self.mostSearchComponent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.newbookSearchComponent.view.mas_bottom);
        make.bottom.and.left.and.right.equalTo(self.contentView);
    }];
}

#pragma mark - SearchListComponentDelegate
- (void)component:(SearchListComponent *)component didSelectedString:(NSString *)string {
    SearchLibraryResultViewController *resultVC = [[SearchLibraryResultViewController alloc] init];
    [resultVC.view setBackgroundColor:[UIColor whiteColor]];
    [resultVC searchWithKeyword:string scope:0];
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (void)component:(SearchListComponent *)component willPerformAction:(NSString *)action {
    if (component.view.tag == 101) {
        LibraryNewBookViewController *newbookVC = [[LibraryNewBookViewController alloc] init];
        [self.navigationController pushViewController:newbookVC animated:YES];
    } else {
        LibraryMostViewController *mostVC =[[LibraryMostViewController alloc] init];
        [self.navigationController pushViewController:mostVC animated:YES];
    }
}

#pragma mark - SearchLibraryBorrowingDelegate
#pragma mark - SearchLibraryNewBookDelegate
- (void)searchDidSuccess {
    if (self.newbookModel.resultArray.count && self.mostModel.resultArray.count) {
        NSMutableArray *newbookArr = [NSMutableArray array];
        for (SearchLibraryNewBookBean *bean in self.newbookModel.resultArray) {
            [newbookArr addObject:bean.title];
        }
        
        NSMutableArray *mostArr = [NSMutableArray array];
        for (SearchLibraryBorrowingBean *bean in self.mostModel.resultArray) {
            [mostArr addObject:bean.title];
        }
        
        self.newbookSearchComponent.strings = newbookArr;
        self.mostSearchComponent.strings = mostArr;
    }
}

- (void)searchDidFail:(NSString *)message {
    
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

- (SearchListComponent *)newbookSearchComponent {
    if (!_newbookSearchComponent) {
        _newbookSearchComponent = [[SearchListComponent alloc] initWithTitle:@"新书通报" action:@"查看全部"];
        _newbookSearchComponent.delegate = self;
        _newbookSearchComponent.view.tag = 101;
        [self.contentView addSubview:_newbookSearchComponent.view];
    }
    return _newbookSearchComponent;
}

- (SearchListComponent *)mostSearchComponent {
    if (!_mostSearchComponent) {
        _mostSearchComponent = [[SearchListComponent alloc] initWithTitle:@"热门排行" action:@"查看全部"];
        _mostSearchComponent.delegate = self;
        _mostSearchComponent.view.tag = 102;
        [self.contentView addSubview:_mostSearchComponent.view];
    }
    return _mostSearchComponent;
}

- (SearchLibraryNewBookModel *)newbookModel {
    if (!_newbookModel) {
        _newbookModel = [[SearchLibraryNewBookModel alloc] init];
        _newbookModel.languageType = @"ALL";
        _newbookModel.sortType = @"ALL";
        _newbookModel.date = @"180";
        _newbookModel.delegate = self;
    }
    return _newbookModel;
}

- (SearchLibraryBorrowingModel *)mostModel {
    if (!_mostModel) {
        _mostModel = [[SearchLibraryBorrowingModel alloc] init];
        _mostModel.languageType = @"ALL";
        _mostModel.sortType = @"ALL";
        _mostModel.date = @"y";
        _mostModel.delegate = self;
    }
    return _mostModel;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
    }
   return _indicatorView;
}


@end
