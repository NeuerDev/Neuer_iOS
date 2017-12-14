//
//  LibraryHistoryViewController.m
//  NEUer
//
//  Created by kl h on 2017/11/7.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryHistoryViewController.h"
#import "LibraryLoginModel.h"

static NSString * const kLibraryHistoryCellId = @"kLibraryHistoryCellId";

@interface LibraryHistoryViewController () <UITableViewDelegate,UITableViewDataSource,LibraryLoginDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIBarButtonItem *filterButtonItem;
@property (nonatomic, strong) NSArray<NSString *> *yearArray;
@property (nonatomic, weak) LibraryLoginModel *loginModel;

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
    self.navigationItem.rightBarButtonItem = self.filterButtonItem;
    [self.loginModel searchBorrowHistoryInfo];
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

- (void)filterByYear {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择年份" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *year in self.yearArray) {
        [alert addAction:[UIAlertAction actionWithTitle:year style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{}];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.loginModel.borrowHistoryArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LibraryHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kLibraryHistoryCellId];
    if (!cell) {
        cell = [[LibraryHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLibraryHistoryCellId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [cell setBorrowHistoryBean:self.loginModel.borrowHistoryArr[indexPath.row] index:indexPath.row];
    return cell;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return nil;
}

#pragma mark - LibraryLoginInfoDelegate
- (void)getBorrowHistoryInfoDidSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
       [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
    }
   return _refreshControl;
}

- (UIBarButtonItem *)filterButtonItem {
    if (!_filterButtonItem) {
        _filterButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:UIBarButtonItemStylePlain target:self action:@selector(filterByYear)];
    }
    return _filterButtonItem;
}

- (LibraryLoginModel *)loginModel {
    if (!_loginModel) {
        _loginModel = [LibraryCenter defaultCenter].currentModel;
        _loginModel.delegate = self;
    }
   return _loginModel;
}

- (NSArray<NSString *> *)yearArray {
    if (!_yearArray) {
        _yearArray = @[@"2017年",@"2016年",@"2015年",@"2014年"];
    }
    return _yearArray;
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
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(10);
        make.left.equalTo(self.contentView).with.offset(24);
        make.right.equalTo(self.contentView).with.offset(-24);
    }];
    
    [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).with.offset(-10);
        make.left.equalTo(self.titleLabel);
    }];
    
    [self.returnDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-24);
        make.bottom.equalTo(self.authorLabel);
    }];
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
        _returnDateLabel.textColor = [UIColor grayColor];
        _returnDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _returnDateLabel.numberOfLines = 1;
        [self.contentView addSubview:_returnDateLabel];
    }
   return _returnDateLabel;
}

#pragma mark - Setter
- (void)setBorrowHistoryBean:(LibraryLoginMyInfoBorrowHistoryBean *)bean index:(NSInteger)index{
    self.titleLabel.text = [NSString stringWithFormat:@"%ld.%@",index+1,bean.title];;
    self.authorLabel.text = bean.author;
    self.returnDateLabel.text = [NSString stringWithFormat:@"归还日期: %@",bean.shouldReturnDate];
}


@end
