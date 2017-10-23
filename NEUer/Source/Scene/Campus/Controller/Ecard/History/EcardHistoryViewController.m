//
//  EcardHistoryViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/22.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardHistoryViewController.h"
#import "EcardTableViewCell.h"
#import "CustomSectionHeaderFooterView.h"

static NSString * const kEcardConsumeHistoryHeaderViewId = @"kEcardConsumeHistoryHeaderViewId";
static NSString * const kEcardConsumeHistoryCellId = @"kEcardConsumeHistoryCellId";

@interface EcardHistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) EcardModel *ecardModel;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *consumeHistoryTableView;

@end

@implementation EcardHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史账单";
    self.view.backgroundColor = [UIColor whiteColor];
    self.consumeHistoryTableView.refreshControl = self.refreshControl;
    self.navigationItem.titleView = self.segmentedControl;
    [self initConstraints];
}

- (void)initConstraints {
    self.consumeHistoryTableView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Response Methods

- (void)beginRefreshing {
    NSLog(@"refresh");
    [self.refreshControl beginRefreshing];
    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:3.0f];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EcardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEcardConsumeHistoryCellId];
    if (!cell) {
        cell = [[EcardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEcardConsumeHistoryCellId];
    }
    
    EcardConsumeBean *consumeBean = self.ecardModel.consumeHistoryArray[indexPath.row];
    
    cell.consumeBean = consumeBean;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ecardModel.consumeHistoryArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomSectionHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kEcardConsumeHistoryHeaderViewId];
    if (!headerView) {
        headerView = [[CustomSectionHeaderFooterView alloc] initWithReuseIdentifier:kEcardConsumeHistoryHeaderViewId];
    }
    
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    headerView.section = section;
    headerView.titleLabel.text = @"今日消费";
    [headerView setPerformActionBlock:^(NSInteger section) {
        switch (section) {
            case 0:
            {
                EcardHistoryViewController *historyViewController = [[EcardHistoryViewController alloc] init];
                [self.navigationController pushViewController:historyViewController animated:YES];
            }
                break;
                
            default:
                break;
        }
    }];
    
    return headerView;
}

#pragma mark - Getter

- (EcardModel *)ecardModel {
    if (!_ecardModel) {
        _ecardModel = [[EcardCenter defaultCenter] currentModel];
    }
    
    return _ecardModel;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
    }
    
    return _refreshControl;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"消费记录", @"充值记录"]];
    }
    
    return _segmentedControl;
}

- (UITableView *)consumeHistoryTableView {
    if (!_consumeHistoryTableView) {
        _consumeHistoryTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _consumeHistoryTableView.delegate = self;
        _consumeHistoryTableView.dataSource = self;
        _consumeHistoryTableView.showsVerticalScrollIndicator = NO;
        _consumeHistoryTableView.allowsSelection = NO;
        _consumeHistoryTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _consumeHistoryTableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_consumeHistoryTableView];
    }
    
    return _consumeHistoryTableView;
}

@end
