//
//  NetworkInternetListViewController.m
//  NEUer
//
//  Created by lanya on 2017/11/6.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkInternetListViewController.h"
#import "NetworkInternetListTableViewCell.h"
#import "NetworkReuseFooterView.h"

static NSString *kNetworkTableViewCellInternetListReuseID = @"internetListCellID";
@interface NetworkInternetListViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NetworkReuseFooterView *footerView;

@end

@implementation NetworkInternetListViewController
{
    NSInteger _maxLineNumber;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstaints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Init

- (void)initData {
    self.title = @"上网明细";

    [self beginRefreshing];
    _maxLineNumber = 0;
//    self.tableView.refreshControl = self.refreshControl;
}

- (void)initConstaints {
    self.scrollView.frame = self.view.frame;
//    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL - self.navigationController.navigationBar.frame.size.height);
    
    self.tableView.frame = self.scrollView.frame;
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

#pragma mark - Response Method

- (void)beginRefreshing {
//    [self.refreshControl beginRefreshing];
    [self.indicatorView startAnimating];
    WS(ws);
    
    [self.model refreshInternetRecordsDataComplete:^(BOOL success, NSString *data) {
        if (success) {
            
            _maxLineNumber = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.indicatorView stopAnimating];
                if ([ws.tableView numberOfSections] == 0) {
                    [ws.tableView reloadData];
                } else {
                    if ([ws.tableView numberOfRowsInSection:0] == ws.model.internetRecordInfoArray.count) {
                        [ws.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            });
        }
    }];
//    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.0f];
}
//
//- (void)endRefreshing {
//    [self.refreshControl endRefreshing];
//}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NetworkInternetListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkTableViewCellInternetListReuseID];
    if (!cell) {
        cell = [[NetworkInternetListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkTableViewCellInternetListReuseID];
    }
    cell.infoBean = self.model.internetRecordInfoArray[indexPath.row];
    
    if (self.model.internetRecordInfoArray.count - indexPath.row < 5) {
        [self loadMore];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.internetRecordInfoArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.model.internetRecordInfoArray.count) {
        return 1;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    NetworkReuseFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kNetworkFooterViewReuseID];
    
    if (!footerView) {
        footerView = [[NetworkReuseFooterView alloc] init];
    }
    if (!_maxLineNumber) {
        [footerView setAnimated:YES];
    } else {
        [footerView setAnimated:NO];
    }
    footerView.contentView.backgroundColor = [UIColor whiteColor];
    
    return footerView;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (void)loadMore {
    WS(ws);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [ws.model queryUserOnlineLogDetailListComplete:^(BOOL success, NSString *data) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.model.appendingInternetRecordInfoArray.count > 0) {
                        [ws appendingDataWithArray:self.model.appendingInternetRecordInfoArray];
                    }
                });
            } else {
                _maxLineNumber = ws.model.internetRecordInfoArray.count;
            }
        }];
    });
}

- (void)appendingDataWithArray:(NSArray *)array {
    NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (GatewaySelfServiceMenuInternetRecordsInfoBean *bean in array) {
        if ([self.model.internetRecordInfoArray containsObject:bean]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.model.internetRecordInfoArray indexOfObject:bean] inSection:0];
            [indexPaths addObject:indexPath];
        } else {
            continue;
        }
    }
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.allowsSelection = NO;
        //        去掉groupTableView最上面的空白
        _tableView.tableHeaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        
        [self.scrollView addSubview:_tableView];
    }
    return _tableView;
}
//
//- (UIRefreshControl *)refreshControl {
//    if (!_refreshControl) {
//        _refreshControl = [[UIRefreshControl alloc] init];
//        [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
//    }
//    return _refreshControl;
//}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate  = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (NetworkReuseFooterView *)footerView {
    if (!_footerView) {
        _footerView = [[NetworkReuseFooterView alloc] init];
    }
    return _footerView;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        [self.view addSubview:_indicatorView];
    }
    return _indicatorView;
}

@end
