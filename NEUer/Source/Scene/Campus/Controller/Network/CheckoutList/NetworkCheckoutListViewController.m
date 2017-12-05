//
//  NetworkCheckoutListViewController.m
//  NEUer
//
//  Created by lanya on 2017/11/6.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkCheckoutListViewController.h"
#import "GatewaySelfServiceMenuModel.h"
#import "LYTool.h"
#import "NetworkReuseFooterView.h"

static NSString *kNetworkTableViewCellCheckoutListReuseID = @"kNetworkTableViewCellCheckoutListReuseID";
static NSString *kNetworkTableViewCellPayListReuseID = @"kNetworkTableViewCellPayListReuseID";

@interface NetworkCheckoutListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UILabel *yearsLabel;
@property (nonatomic, strong) UILabel *usedFlowLabel;
@property (nonatomic, strong) UILabel *sumTimeLabel;
@property (nonatomic, strong) UILabel *consumeLabel;
@property (nonatomic, strong) UIView *timeView;
@property (nonatomic, strong) UIView *seperatorView;

@property (nonatomic, strong) GatewaySelfServiceMenuFinancialCheckOutInfoBean *infoBean;
@property (nonatomic, strong) GatewaySelfServiceMenuFinancialPayInfoBean *payBean;

@end
@implementation NetworkCheckoutListTableViewCell

#pragma mark - Init Method
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.contentView).with.offset(16);
        make.width.equalTo(@(70));
        make.centerY.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16);
    }];
    [self.monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeView).with.offset(5);
        make.top.equalTo(self.timeView.mas_top);
    }];
    [self.yearsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.monthLabel);
        make.top.equalTo(self.monthLabel.mas_bottom).with.offset(4);
    }];
    [self.seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeView.mas_right);
        make.width.equalTo(@1);
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(@40);
    }];
    [self.usedFlowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.seperatorView.mas_right).with.offset(10);
        make.top.equalTo(self.timeView);
    }];
    [self.sumTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.usedFlowLabel.mas_bottom).with.offset(4);
        make.left.equalTo(self.usedFlowLabel);
        make.bottom.equalTo(self.timeView);
    }];
    [self.consumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.centerY.equalTo(self.contentView);
    }];
}

#pragma mark - Setter

- (void)setInfoBean:(GatewaySelfServiceMenuFinancialCheckOutInfoBean *)infoBean {
    _infoBean = infoBean;
    
    _monthLabel.text = [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"MM-dd" withDateString:infoBean.checkout_creatTime];
    _yearsLabel.text = [NSString stringWithFormat:@"%@年", [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"yyyy" withDateString:infoBean.checkout_creatTime]];
    _usedFlowLabel.text = infoBean.checkout_flow;
    _sumTimeLabel.text = [NSString stringWithFormat:@"%@", infoBean.checkout_time];
    _consumeLabel.text = [NSString stringWithFormat:@"-%@", infoBean.checkout_payAmmount];
    
}

- (void)setPayBean:(GatewaySelfServiceMenuFinancialPayInfoBean *)payBean {
    _payBean = payBean;
    
    _monthLabel.text = [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"MM-dd" withDateString:payBean.financial_creatTime];
    _yearsLabel.text = [NSString stringWithFormat:@"%@年", [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"yyyy" withDateString:payBean.financial_creatTime]];
    
    if ([payBean.financial_product isEqualToString:@"std"]) {
        _usedFlowLabel.text = @"25G下行流量";
    } else {
        _usedFlowLabel.text = @"50G下行流量";
    }
    
    _sumTimeLabel.text = [NSString stringWithFormat:@"%@", payBean.financial_payWay];
    _consumeLabel.text = [NSString stringWithFormat:@"+%@", payBean.financial_payAmmount];
}

#pragma mark - Getter

- (UIView *)timeView {
    if (!_timeView) {
        _timeView = [[UIView alloc] init];
        [self.contentView addSubview:_timeView];
    }
    return _timeView;
}

- (UIView *)seperatorView {
    if (!_seperatorView) {
        _seperatorView = [[UIView alloc] init];
        _seperatorView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_seperatorView];
    }
    return _seperatorView;
}

- (UILabel *)monthLabel {
    if (!_monthLabel) {
        _monthLabel = [[UILabel alloc] init];
        _monthLabel.textColor = [UIColor darkGrayColor];
        _monthLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        [self.contentView addSubview:_monthLabel];
    }
    return _monthLabel;
}

- (UILabel *)yearsLabel {
    if (!_yearsLabel) {
        _yearsLabel = [[UILabel alloc] init];
        _yearsLabel.textColor = [UIColor lightGrayColor];
        _yearsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        [self.contentView addSubview:_yearsLabel];
    }
    return _yearsLabel;
}

- (UILabel *)sumTimeLabel {
    if (!_sumTimeLabel) {
        _sumTimeLabel = [[UILabel alloc] init];
        _sumTimeLabel.numberOfLines = 1;
        _sumTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _sumTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_sumTimeLabel];
    }
    
    return _sumTimeLabel;
}

- (UILabel *)usedFlowLabel {
    if (!_usedFlowLabel) {
        _usedFlowLabel = [[UILabel alloc] init];
        _usedFlowLabel.numberOfLines = 1;
        _usedFlowLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self.contentView addSubview:_usedFlowLabel];
    }
    return _usedFlowLabel;
}

- (UILabel *)consumeLabel {
    if (!_consumeLabel) {
        _consumeLabel = [[UILabel alloc] init];
        _consumeLabel.numberOfLines = 1;
        _consumeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [self.contentView addSubview:_consumeLabel];
    }
    return _consumeLabel;
}

@end

@interface NetworkCheckoutListViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NetworkReuseFooterView *footerView;

@end

@implementation NetworkCheckoutListViewController

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
    self.title = @"缴费清单";

    self.navigationItem.titleView = self.segmentedControl;
    [self beginRefreshing];
}

- (void)initConstraints {
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL);
}

#pragma mark - Response Method

- (void)beginRefreshing {
    self.baseActivityIndicatorView.hidden = NO;
    [self.baseActivityIndicatorView startAnimating];
    WS(ws);
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            [self.model refreshPayInfoDataComplete:^(BOOL success, NSString *data) {
                if (success) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ws.baseActivityIndicatorView stopAnimating];
                        
                        if (0 == ws.tableView.numberOfSections) {
                            [ws.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                        } else {
                            if ([ws.tableView numberOfRowsInSection:0] == self.model.financialPayInfoArray.count) {
                                [ws.tableView reloadData];
                            } else {
                                [ws.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                            }
                        }
                    });
                }
            }];
        }
            break;
        case 1:
        {
            [self.model refreshCheckoutDataComplete:^(BOOL success, NSString *data) {
                if (success) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ws.baseActivityIndicatorView stopAnimating];
                        
                        if (0 == ws.tableView.numberOfSections) {
                            [ws.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                        } else {
                            if ([ws.tableView numberOfRowsInSection:0] == self.model.financialCheckoutInfoArray.count) {
                                [ws.tableView reloadData];
                            } else {
                                [ws.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                            }
                        }
                    });
                }
            }];
        }
        default:
            break;
    }
}

- (void)didClickedSegmentedControl {
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            self.title = @"缴费清单";
            [self beginRefreshing];
        }
            break;
        case 1:
        {
            self.title = @"结算清单";
            [self beginRefreshing];
        }
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            NetworkCheckoutListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkTableViewCellCheckoutListReuseID];
            if (!cell) {
                cell = [[NetworkCheckoutListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkTableViewCellCheckoutListReuseID];
            }
            if (self.model.financialPayInfoArray.count >= indexPath.row && self.model.financialPayInfoArray.count > 0) {
                cell.payBean = self.model.financialPayInfoArray[indexPath.row];
            }
            if (self.model.financialPayInfoArray.count - indexPath.row < 5) {
                [self loadMore];
            }
            
            return cell;
        }
            break;
        case 1:
        {
            NetworkCheckoutListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkTableViewCellPayListReuseID];
            if (!cell) {
                cell = [[NetworkCheckoutListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkTableViewCellPayListReuseID];
            }
            if (self.model.financialCheckoutInfoArray.count >= indexPath.row && self.model.financialCheckoutInfoArray.count > 0) {
                cell.infoBean = self.model.financialCheckoutInfoArray[indexPath.row];
            }
            
            if (self.model.financialCheckoutInfoArray.count - indexPath.row < 5) {
                [self loadMore];
            }
            
            return cell;
        }
        default:
            break;
    }
    
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            return self.model.financialPayInfoArray.count;
        }
            break;
        case 1:
        {
            return self.model.financialCheckoutInfoArray.count;
        }
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            if (self.model.financialPayInfoArray.count > 0) {
                return 1;
            } else {
                return 0;
            }
        }
            break;
        case 1:
        {
            if (self.model.financialCheckoutInfoArray.count > 0) {
                return 1;
            } else {
                return 0;
            }
        }
        default:
            break;
    }
    
    return 0;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (void)loadMore {
    WS(ws);
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [ws.model queryUserOnlineFinancialPayListComplete:^(BOOL success, NSString *data) {
                    
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [ws appendingDataWithArray: self.model.appendingFinancePayInfoArray];
                            [self.footerView setAnimated:YES];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.footerView setAnimated:NO];
                        });
                    }
                }];
            });
        }
            break;
        case 1:
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [ws.model queryUserFinancialCheckOutListComlete:^(BOOL success, NSString *data) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                           [ws appendingDataWithArray: self.model.appendingFinanceCheckoutInfoArray];
                            [self.footerView setAnimated:YES];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.footerView setAnimated:NO];
                        });
                    }
                }];
            });
        }
        default:
            break;
    }
}

- (void)appendingDataWithArray:(NSArray *)array {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (GatewaySelfServiceMenuFinancialPayInfoBean *bean in array) {
                if ([self.model.financialPayInfoArray containsObject:bean]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.model.financialPayInfoArray indexOfObject:bean] inSection:0];
                    [indexPaths addObject:indexPath];
                } else {
                    continue;
                }
            }
            
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case 1:
        {
            NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (GatewaySelfServiceMenuFinancialCheckOutInfoBean *bean in array) {
                if ([self.model.financialCheckoutInfoArray containsObject:bean]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.model.financialCheckoutInfoArray indexOfObject:bean] inSection:0];
                    [indexPaths addObject:indexPath];
                } else {
                    continue;
                }
            }
            
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        default:
            break;
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

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"缴费清单", @"结算清单"]];
        [_segmentedControl addTarget:self action:@selector(didClickedSegmentedControl) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.selectedSegmentIndex = 0;
        [self.view addSubview:_segmentedControl];
    }
    return _segmentedControl;
}

- (NetworkReuseFooterView *)footerView {
    if (!_footerView) {
        _footerView = [[NetworkReuseFooterView alloc] init];
    }
    return _footerView;
}

@end
