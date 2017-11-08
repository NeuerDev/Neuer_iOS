//
//  NetworkPayListViewController.m
//  NEUer
//
//  Created by lanya on 2017/11/6.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkPayListViewController.h"
#import "GatewaySelfServiceMenuModel.h"
#import "LYTool.h"

static NSString *kNetworkTableViewCellPayListReuseID = @"kNetworkTableViewCellPayListReuseID";
@interface NetworkPayListTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UILabel *yearsLabel;
@property (nonatomic, strong) UILabel *productNameLabel;
@property (nonatomic, strong) UILabel *payWayLabel;
@property (nonatomic, strong) UILabel *consumeLabel;
@property (nonatomic, strong) UIView *timeView;
@property (nonatomic, strong) UIView *seperatorView;

@property (nonatomic, strong) GatewaySelfServiceMenuFinancialPayInfoBean *infoBean;

@end
@implementation NetworkPayListTableViewCell

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
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16);
    }];
    [self.monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.timeView);
    }];
    [self.yearsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.equalTo(self.timeView);
    }];
    [self.seperatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeView.mas_right);
        make.width.equalTo(@1);
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(@40);
    }];
    [self.productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.seperatorView.mas_right).with.offset(10);
        make.top.equalTo(self.timeView);
    }];
    [self.payWayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.productNameLabel.mas_bottom).with.offset(4);
        make.left.equalTo(self.productNameLabel);
        make.bottom.equalTo(self.timeView);
    }];
    [self.consumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.centerY.equalTo(self.contentView);
    }];
}

#pragma mark - Setter

- (void)setInfoBean:(GatewaySelfServiceMenuFinancialPayInfoBean *)infoBean {
    _infoBean = infoBean;
    
    _monthLabel.text = [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"MM-dd" withDateString:infoBean.financial_creatTime];
    _yearsLabel.text = [NSString stringWithFormat:@"%@年", [LYTool changeDateFormatterFromDateFormat:@"yyyy-MM-dd HH:mm:ss" toDateFormat:@"yyyy" withDateString:infoBean.financial_creatTime]];
    
    if ([infoBean.financial_product isEqualToString:@"std"]) {
        _productNameLabel.text = @"25G下行流量";
    } else {
        _productNameLabel.text = @"50G下行流量";
    }
    
    _payWayLabel.text = [NSString stringWithFormat:@"支付方式：%@", infoBean.financial_payWay];
    _consumeLabel.text = [NSString stringWithFormat:@"+%@", infoBean.financial_payAmmount];
    
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
        _monthLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        
        [self.contentView addSubview:_monthLabel];
    }
    return _monthLabel;
}

- (UILabel *)yearsLabel {
    if (!_yearsLabel) {
        _yearsLabel = [[UILabel alloc] init];
        _yearsLabel.textColor = [UIColor lightGrayColor];
        _yearsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        [self.contentView addSubview:_yearsLabel];
    }
    return _yearsLabel;
}

- (UILabel *)payWayLabel {
    if (!_payWayLabel) {
        _payWayLabel = [[UILabel alloc] init];
        _payWayLabel.numberOfLines = 1;
        _payWayLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _payWayLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_payWayLabel];
    }
    
    return _payWayLabel;
}

- (UILabel *)productNameLabel {
    if (!_productNameLabel) {
        _productNameLabel = [[UILabel alloc] init];
        _productNameLabel.numberOfLines = 1;
        _productNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.contentView addSubview:_productNameLabel];
    }
    return _productNameLabel;
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

@interface NetworkPayListViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation NetworkPayListViewController

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
    self.title = @"缴费清单";
    [self.model refreshPayInfoData];
    self.tableView.refreshControl = self.refreshControl;
}

- (void)initConstaints {
    self.tableView.frame = self.view.frame;
}

#pragma mark - Response Method

- (void)beginRefreshing {
    [self.refreshControl beginRefreshing];
    [self.model refreshPayInfoData];
    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.0f];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NetworkPayListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkTableViewCellPayListReuseID];
    if (!cell) {
        cell = [[NetworkPayListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkTableViewCellPayListReuseID];
    }
    cell.infoBean = self.model.financialPayInfoArray[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.financialPayInfoArray.count;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.model.financialPayInfoArray.count - 1) {
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
        [self.model queryUserOnlineFinancialPayListComplete:^(BOOL success, NSString *data) {
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
