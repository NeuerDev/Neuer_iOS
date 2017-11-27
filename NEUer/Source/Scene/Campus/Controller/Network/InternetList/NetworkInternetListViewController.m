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
@property (nonatomic, strong) NetworkReuseFooterView *footerView;

@end

@implementation NetworkInternetListViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Init

- (void)initData {
    self.title = @"上网明细";

    [self beginRefreshing];
}

- (void)initConstraints {
    
    self.tableView.frame = self.view.frame;

}

#pragma mark - Response Method

- (void)beginRefreshing {
    self.baseActivityIndicatorView.hidden = NO;
    [self.baseActivityIndicatorView startAnimating];
    WS(ws);
    
    [self.model refreshInternetRecordsDataComplete:^(BOOL success, NSString *data) {
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.baseActivityIndicatorView stopAnimating];
                if ([ws.tableView numberOfSections] == 0) {
                    if (self.model.internetRecordInfoArray.count == 0) {
                        [ws.tableView reloadData];
                    } else {
                        [ws.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    }
                } else {
                    if ([ws.tableView numberOfRowsInSection:0] == ws.model.internetRecordInfoArray.count) {
                        [ws.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            });
        } else {
            NSLog(@"加载失败");
        }
    }];

}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NetworkInternetListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkTableViewCellInternetListReuseID];
    if (!cell) {
        cell = [[NetworkInternetListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkTableViewCellInternetListReuseID];
    }
    cell.infoBean = self.model.internetRecordInfoArray[indexPath.row];
    if (self.model.internetRecordInfoArray.count - indexPath.row <= 2) {
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
                    [ws.footerView setAnimated:YES];
                    if (ws.model.appendingInternetRecordInfoArray.count > 0) {
                        [ws appendingDataWithArray:self.model.appendingInternetRecordInfoArray];
                    } else {
                        [ws.footerView setAnimated:NO];
                    }
                });
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
    if (![self.footerView isAnimated]) {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    }
}


#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.allowsSelection = NO;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 64)];
        [footerView addSubview:self.footerView];
        [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(footerView);
        }];
        [footerView layoutIfNeeded];

        _tableView.tableFooterView = footerView;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NetworkReuseFooterView *)footerView {
    if (!_footerView) {
        _footerView = [[NetworkReuseFooterView alloc] init];
    }
    return _footerView;
}

@end
