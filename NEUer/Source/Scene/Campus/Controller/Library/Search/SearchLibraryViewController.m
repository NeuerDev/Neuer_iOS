//
//  LibrarySearchDoorViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchLibraryViewController.h"
#import "SearchLibraryDoorViewController.h"
#import "SearchLibraryBorrowingModel.h"
#import "CustomSectionHeaderFooterView.h"

static NSString * const kDefaultCellId = @"kDefaultCellId";
static NSString * const kLibrarySearchConsumeHistoryHeaderViewId = @"kLibrarySearchConsumeHistoryHeaderViewId";

@interface SearchLibraryViewController () <UISearchControllerDelegate, UITableViewDelegate,UITableViewDataSource,SearchLibraryBorrowingDelegate>

@property (nonatomic, strong) SearchLibraryDoorViewController *searchDoorViewController;
@property (nonatomic, strong) UIVisualEffectView *maskView;
@property (nonatomic, strong) UIBarButtonItem *collectionBarButtonItem;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SearchLibraryBorrowingModel *mostModel;

@property (nonatomic, strong) NSArray<NSString *> *recentStrings;
@property (nonatomic, strong) NSArray<NSString *> *mostStrings;

@end

@implementation SearchLibraryViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SearchLibraryNavigationBarTitle", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.collectionBarButtonItem;
    if (@available(iOS 11.0, *)) {
#ifdef __IPHONE_11_0
        self.navigationItem.searchController = self.searchDoorViewController;
        [self.navigationItem setHidesSearchBarWhenScrolling:NO];
#endif
    } else {
        
    }
    
    [self initData];
    [self initConstraints];
}

- (void)initData {
    [self.mostModel search];
}

- (void)initConstraints {
    self.tableView.frame = self.view.frame;
    self.maskView.frame = self.view.frame;
}

#pragma mark - Response Methods

- (void)showCollections {
    
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    if ([searchController isKindOfClass:[SearchLibraryDoorViewController class]]) {
        UIView *suggestView = ((SearchLibraryDoorViewController *)searchController).resultView;
        suggestView.frame = self.view.frame;
        [self.view addSubview:suggestView];
        _maskView.effect = nil;
        _maskView.alpha = 1;
        _maskView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _maskView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        }];
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if ([searchController isKindOfClass:[SearchLibraryDoorViewController class]]) {
        UIView *suggestView = ((SearchLibraryDoorViewController *)searchController).resultView;
        [self.view layoutIfNeeded];
        
        [suggestView removeFromSuperview];
        [UIView animateWithDuration:0.3 animations:^{
            _maskView.alpha = 0;
        } completion:^(BOOL finished) {
            _maskView.hidden = YES;
        }];

    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchDoorViewController.active = YES;
    if (indexPath.section == 0) {
        [self.searchDoorViewController searchKeyword:self.recentStrings[indexPath.row]];
    } else {
        [self.searchDoorViewController searchKeyword:self.mostStrings[indexPath.row]];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomSectionHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLibrarySearchConsumeHistoryHeaderViewId];
    if (!headerView) {
        headerView = [[CustomSectionHeaderFooterView alloc] initWithReuseIdentifier:kLibrarySearchConsumeHistoryHeaderViewId];
        [headerView.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    headerView.section = section;
    if (section == 0) {
        headerView.titleLabel.text = @"最近搜索";
        [headerView.actionButton setTitle:@"清空" forState:UIControlStateNormal];
    } else {
        headerView.titleLabel.text = @"热门搜索";
        [headerView.actionButton setTitle:@"清空" forState:UIControlStateNormal];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellId];
    cell.textLabel.textColor = [UIColor beautyBlue];
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    if (indexPath.section == 0) {
        cell.textLabel.text = self.recentStrings[indexPath.row];
    } else {
        cell.textLabel.text = self.mostStrings[indexPath.row];
    }
    return cell;
}

#pragma mark - SearchLibraryBorrowingDelegate
- (void)searchDidSuccess {
    NSMutableArray *array = [NSMutableArray array];
    for (SearchLibraryBorrowingBean *bean in self.mostModel.resultArray) {
        [array addObject:bean.title];
    }
    self.mostStrings = array;
    [self.tableView reloadData];
}

- (void)searchDidFail:(NSString *)message {
    
}

#pragma mark - Getter

- (SearchLibraryDoorViewController *)searchDoorViewController {
    if (!_searchDoorViewController) {
        _searchDoorViewController = [[SearchLibraryDoorViewController alloc] init];
        _searchDoorViewController.delegate = self;
    }
    
    return _searchDoorViewController;
}

- (UIBarButtonItem *)collectionBarButtonItem {
    if (!_collectionBarButtonItem) {
        _collectionBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(showCollections)];
    }
    return _collectionBarButtonItem;
}

- (UIVisualEffectView *)maskView {
    if (!_maskView) {
        _maskView = [[UIVisualEffectView alloc] init];
        _maskView.hidden = YES;
        [self.view addSubview:_maskView];
    }
    return _maskView;
}

- (UITableView *)tableView {
   if (!_tableView) {
       _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
       _tableView.dataSource = self;
       _tableView.delegate =self;
       _tableView.alwaysBounceVertical = YES;
       _tableView.showsVerticalScrollIndicator = NO;
       _tableView.backgroundColor = [UIColor clearColor];
       _tableView.tableFooterView = [[UIView alloc] init];
       _tableView.separatorInset = UIEdgeInsetsMake(0, 16.0f, 0, 16.0f);
       [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDefaultCellId];
       [self.view addSubview:_tableView];
    }
   return _tableView;
}

- (NSArray<NSString *> *)recentStrings {
    if (!_recentStrings) {
        _recentStrings = @[@"iOS", @"The Great Gatsby", @"Oliver Twist", @"The Phantom Of the Opera", @"Khaled Hosseini", @"莫言"];
    }
   return _recentStrings;
}

- (NSArray<NSString *> *)mostStrings {
    if (!_mostStrings) {
        _mostStrings = @[@"马克思原理", @"软件工程", @"公共事业管理基础", @"人工智能与神经网络", @"机械与自动化", @"工程原理"];
    }
   return _mostStrings;
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

@end
