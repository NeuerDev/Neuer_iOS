//
//  EcardHistoryViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/22.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardHistoryViewController.h"
#import "EcardTableViewCell.h"
#import "EcardHeadlineTableViewCell.h"
#import "CustomSectionHeaderFooterView.h"

static NSString * const kEcardConsumeHistoryHeaderViewId = @"kEcardConsumeHistoryHeaderViewId";
static NSString * const kEcardConsumeHistoryCellId = @"kEcardConsumeHistoryCellId";
static NSString * const kEcardConsumeHistoryHeadlineCellId = @"kEcardConsumeHistoryHeadlineCellId";

@interface EcardHistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) EcardModel *ecardModel;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *consumeHistoryTableView;

@end

@implementation EcardHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"本月账单";
    self.view.backgroundColor = [UIColor whiteColor];
    self.consumeHistoryTableView.refreshControl = self.refreshControl;
    self.navigationItem.titleView = self.segmentedControl;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
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
    [self.ecardModel queryThisMonthConsumeHistoryComplete:^(BOOL success, NSError *error) {
        
    }];
}

- (void)endRefreshing {
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row==0) {
        EcardHeadlineTableViewCell *headlineCell = [tableView dequeueReusableCellWithIdentifier:kEcardConsumeHistoryCellId];
        [tableView dequeueReusableCellWithIdentifier:kEcardConsumeHistoryHeadlineCellId];
        if (!headlineCell) {
            headlineCell = [[EcardHeadlineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEcardConsumeHistoryHeadlineCellId];
        }
        
        cell = headlineCell;
    } else {
        EcardTableViewCell *consumeCell = [tableView dequeueReusableCellWithIdentifier:kEcardConsumeHistoryCellId];
        if (!consumeCell) {
            consumeCell = [[EcardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEcardConsumeHistoryCellId];
        }
        
        cell = consumeCell;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
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
        _segmentedControl.selectedSegmentIndex = 0;
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
        
//        UIView *headerView = [UIView]
        _consumeHistoryTableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_consumeHistoryTableView];
    }
    
    return _consumeHistoryTableView;
}

@end
