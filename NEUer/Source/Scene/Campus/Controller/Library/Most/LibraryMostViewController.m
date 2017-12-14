//
//  LibraryMostViewController.m
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryMostViewController.h"
#import "SearchLibraryResultViewController.h"
#import "LibraryBookListComponent.h"
#import "SearchLibraryBorrowingModel.h"

@interface LibraryMostViewController () <SearchLibraryBorrowingDelegate,LibraryBookListComponentDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIBarButtonItem *sortButtonItem;
@property (nonatomic, strong) LibraryBookListComponent *bookListComponent;
@property (nonatomic, strong) SearchLibraryBorrowingModel *model;

@end

@implementation LibraryMostViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

#pragma mark - Init Methods
- (void)initData {
    [self setTitle:@"热门排行"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = self.sortButtonItem;
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

#pragma mark - Respond Methods
- (void)selectSortType {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择分类" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - SearchLibraryBorrowingDelegate
- (void)searchDidSuccess {
    NSMutableArray *array = [NSMutableArray array];
    for (SearchLibraryBorrowingBean *bean in self.model.resultArray) {
        [array addObject:bean.title];
    }
    [self.bookListComponent setStrings:array];
}

- (void)searchDidFail:(NSString *)message {
    
}

#pragma mark - LibraryBookListComponentDelegate
- (void)component:(LibraryBookListComponent *)component didSelectedString:(NSString *)string {
    SearchLibraryResultViewController *resultVC = [[SearchLibraryResultViewController alloc] init];
    [resultVC.view setBackgroundColor:[UIColor whiteColor]];
    [resultVC searchWithKeyword:string scope:0];
    [self.navigationController pushViewController:resultVC animated:YES];
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
        _bookListComponent = [[LibraryBookListComponent alloc] initWithModelType:ComponentModelTypeMost];
        _bookListComponent.viewController = self;
        _bookListComponent.mostModel = self.model;
        _bookListComponent.delegate = self;
        [self.contentView addSubview:_bookListComponent.view];
    }
    return _bookListComponent;
}

- (SearchLibraryBorrowingModel *)model {
    if (!_model) {
        _model = [[SearchLibraryBorrowingModel alloc] init];
        _model.languageType = @"ALL";
        _model.sortType = @"ALL";
        _model.date = @"y";
        _model.delegate = self;
    }
    return _model;
}

- (UIBarButtonItem *)sortButtonItem {
    if (!_sortButtonItem) {
        _sortButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分类" style:UIBarButtonItemStylePlain target:self action:@selector(selectSortType)];
    }
    return _sortButtonItem;
}

@end
