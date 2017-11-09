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

static NSString *kNetworkTableViewCellCheckoutListReuseID = @"kNetworkTableViewCellCheckoutListReuseID";
@interface NetworkCheckoutListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UILabel *yearsLabel;
@property (nonatomic, strong) UILabel *usedFlowLabel;
@property (nonatomic, strong) UILabel *sumTimeLabel;
@property (nonatomic, strong) UILabel *consumeLabel;
@property (nonatomic, strong) UIView *timeView;
@property (nonatomic, strong) UIView *seperatorView;

@property (nonatomic, strong) GatewaySelfServiceMenuFinancialCheckOutInfoBean *infoBean;

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
        make.width.equalTo(@(80));
        make.centerY.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16);
    }];
    [self.monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeView);
        make.top.equalTo(self.timeView.mas_top).with.offset(8);
    }];
    [self.yearsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeView);
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
    _sumTimeLabel.text = [NSString stringWithFormat:@"总时长：%@", infoBean.checkout_time];
    _consumeLabel.text = [NSString stringWithFormat:@"-%@", infoBean.checkout_payAmmount];
    
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
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation NetworkCheckoutListViewController

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
    self.title = @"结算清单";
    WS(ws);
    [self.model refreshCheckoutDataComplete:^(BOOL success, NSString *data) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.tableView reloadData];
            });
            
        }
    }];
    self.tableView.refreshControl = self.refreshControl;
}

- (void)initConstaints {
    self.tableView.frame = self.view.frame;
}

#pragma mark - Response Method

- (void)beginRefreshing {
    [self.refreshControl beginRefreshing];
    WS(ws);
    [self.model refreshCheckoutDataComplete:^(BOOL success, NSString *data) {
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.0f];
                [ws.tableView reloadData];
            });
        } else {
            [ws performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.0f];
        }
    }];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NetworkCheckoutListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkTableViewCellCheckoutListReuseID];
    if (!cell) {
        cell = [[NetworkCheckoutListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkTableViewCellCheckoutListReuseID];
    }
    cell.infoBean = self.model.financialCheckoutInfoArray[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.financialCheckoutInfoArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.model.financialCheckoutInfoArray.count > 0) {
        return 1;
    } else {
        return 0;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.model.internetRecordInfoArray.count - 1) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 50)];
        _indicatorView.center = CGPointMake(SCREEN_WIDTH_ACTUAL * 0.5, footerView.frame.origin.y + 20);
        footerView.backgroundColor = [UIColor clearColor];
        [footerView addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
        _tableView.tableFooterView.hidden = NO;
        _tableView.tableFooterView = footerView;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _tableView.tableFooterView.hidden = YES;
            [_indicatorView stopAnimating];
        });
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height) {
        WS(ws);
        [self.model queryUserFinancialCheckOutListComlete:^(BOOL success, NSString *data) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ws.tableView reloadData];
                });
            }
        }];
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

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        _indicatorView.transform = transform;
    }
    return _indicatorView;
}

@end
