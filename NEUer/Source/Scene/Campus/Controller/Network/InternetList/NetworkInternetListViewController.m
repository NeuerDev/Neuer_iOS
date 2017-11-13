//
//  NetworkInternetListViewController.m
//  NEUer
//
//  Created by lanya on 2017/11/6.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkInternetListViewController.h"
#import "NetworkInternetListTableViewCell.h"

static NSString *kNetworkTableViewCellInternetListReuseID = @"internetListCellID";
@interface NetworkInternetListViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *footerLabel;

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
    
    WS(ws);
    [self.model refreshInternetRecordsDataComplete:^(BOOL success, NSString *data) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView reloadData];
            });
        }
    }];
    
    _maxLineNumber = 0;
    self.tableView.refreshControl = self.refreshControl;
}

- (void)initConstaints {
    self.scrollView.frame = self.view.frame;
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL - self.navigationController.navigationBar.frame.size.height);
}

#pragma mark - Response Method

- (void)beginRefreshing {
    [self.refreshControl beginRefreshing];
    WS(ws);
    [self.model refreshInternetRecordsDataComplete:^(BOOL success, NSString *data) {
        if (success) {
            
            _maxLineNumber = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView reloadData];
            });
        }
    }];
    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.0f];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NetworkInternetListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkTableViewCellInternetListReuseID];
    if (!cell) {
        cell = [[NetworkInternetListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkTableViewCellInternetListReuseID];
    }
    cell.infoBean = self.model.internetRecordInfoArray[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.internetRecordInfoArray.count;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_maxLineNumber) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 50)];
        _indicatorView.center = CGPointMake(SCREEN_WIDTH_ACTUAL * 0.5, footerView.frame.origin.y + 5);
        footerView.backgroundColor = [UIColor clearColor];
        [footerView addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
        _tableView.tableFooterView.hidden = NO;
        _tableView.tableFooterView = footerView;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_indicatorView stopAnimating];
        });
    } else {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 50)];
        self.footerLabel.frame = CGRectMake(0, footerView.frame.origin.y, SCREEN_WIDTH_ACTUAL, 20);
        [footerView addSubview:_footerLabel];
        _tableView.tableFooterView.hidden = NO;
        _tableView.tableFooterView = footerView;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height) {
        WS(ws);

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [ws.model queryUserOnlineLogDetailListComplete:^(BOOL success, NSString *data) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ws.tableView reloadData];
                    });
                } else {
                    _maxLineNumber = ws.model.internetRecordInfoArray.count;
                }
            }];
        });
    }
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.allowsSelection = NO;
        [self.indicatorView startAnimating];
        [self.scrollView addSubview:_tableView];
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

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        _indicatorView.transform = transform;
    }
    return _indicatorView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate  = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UILabel *)footerLabel {
    if (!_footerLabel) {
        _footerLabel = [[UILabel alloc] init];
        _footerLabel.text = @"已经没有更多消息了~";
        _footerLabel.textAlignment = NSTextAlignmentCenter;
        _footerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _footerLabel.textColor = [UIColor lightGrayColor];
    }
    return _footerLabel;
}

@end
