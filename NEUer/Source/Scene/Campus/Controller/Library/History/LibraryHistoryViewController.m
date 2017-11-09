//
//  LibraryHistoryViewController.m
//  NEUer
//
//  Created by kl h on 2017/11/7.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryHistoryViewController.h"
#import "LibraryLoginModel.h"
#import "LibraryLoginMyInfoModel.h"

static NSString * const kLibraryHistoryCellId = @"kLibraryHistoryCellId";

@interface LibraryHistoryViewController () <UITableViewDelegate,UITableViewDataSource,LibraryLoginInfoDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) LibraryLoginMyInfoModel *infoModel;

@end

@implementation LibraryHistoryViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

#pragma mark - Init Methods
- (void)initData {
    [self setTitle:@"借阅历史"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tableView.refreshControl = self.refreshControl;
    [self.infoModel searchBorrowHistoryInfo];
}

- (void)initConstraints {
    self.tableView.frame = self.view.frame;
    
}

#pragma mark - Respond Methods
- (void)beginRefreshing {
    [self.refreshControl beginRefreshing];
    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:3.0f];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoModel.borrowHistoryArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LibraryHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kLibraryHistoryCellId];
    if (!cell) {
        cell = [[LibraryHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLibraryHistoryCellId];
    }
    [cell setBorrowHistoryBean:self.infoModel.borrowHistoryArr[indexPath.row]];
    return cell;
}

#pragma mark - LibraryLoginInfoDelegate
- (void)getBorrowHistoryInfoDidSuccess {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//        NSLog(@"history - 线程%@",[NSThread currentThread]);
//    });
    [self.tableView reloadData];
    NSLog(@"history - 线程%@",[NSThread currentThread]);
    
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
   return _tableView;
}

- (UIRefreshControl *)refreshControl {
   if (!_refreshControl) {
       _refreshControl = [[UIRefreshControl alloc] init];
       [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventTouchUpInside];
    }
   return _refreshControl;
}

- (LibraryLoginMyInfoModel *)infoModel {
    if (!_infoModel) {
        _infoModel = [LibraryCenter defaultCenter].currentModel.infoModel;
        _infoModel.delegate = self;
    }
   return _infoModel;
}
@end


@implementation LibraryHistoryCell
#pragma mark - Init Methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    
}


#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
    }
   return _titleLabel;
}

- (UILabel *)authorLabel {
    if (!_authorLabel) {
        _authorLabel = [[UILabel alloc] init];
        _authorLabel.textColor = [UIColor grayColor];
        _authorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _authorLabel.numberOfLines = 1;
        [self.contentView addSubview:_authorLabel];
    }
   return _authorLabel;
}

- (UILabel *)returnDateLabel {
    if (!_returnDateLabel) {
        _returnDateLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_returnDateLabel];
    }
   return _returnDateLabel;
}

#pragma mark - Setter
- (void)setBorrowHistoryBean:(LibraryLoginMyInfoBorrowHistoryBean *)bean {
    self.titleLabel.text = bean.title;
    self.authorLabel.text = bean.author;
    self.returnDateLabel.text = bean.shouldReturnDate;
}


@end
