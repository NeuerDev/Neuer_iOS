//
//  NetworkPersonalInfoViewController.m
//  NEUer
//
//  Created by lanya on 2017/11/6.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkPersonalInfoViewController.h"
#import "GatewaySelfServiceMenuModel.h"
#import "CustomSectionHeaderFooterView.h"

static NSString *kNetworkPersonalInfoTableViewCellReuseID = @"kNetworkPersonalInfoTableViewCellReuseID";
static NSString *kNetworkProductInfoTableViewCellReuseID = @"kNetworkProductInfoTableViewCellReuseID";
static NSString *kNetworkHeaderFooterViewReuseID = @"kNetworkHeaderFooterViewReuseID";

@interface NetworkPersonalInfoTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *msgTypeLabel;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIView *infoView;

@property (nonatomic, strong) GatewayCellBasicInfoBean *cellInfoBean;

@end

@implementation NetworkPersonalInfoTableViewCell

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        
        if ([reuseIdentifier isEqualToString:kNetworkPersonalInfoTableViewCellReuseID]) {
            self.separatorInset = UIEdgeInsetsMake(0, 72, 0, 16);
            [self initBasicConstaints];
        } else {
            [self initProductConstraints];
        }
    }
    return self;
}

- (void)initBasicConstaints {
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.mas_equalTo(@(40));
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
    }];
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.logoImageView.mas_right).with.offset(16);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
    }];
    [self.msgTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.infoView);
        make.width.equalTo(@110);
        make.left.equalTo(self.infoView);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.infoView);
        make.left.equalTo(self.msgTypeLabel.mas_right).with.offset(20);
    }];
}

- (void)initProductConstraints {
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.right.equalTo(self.contentView).with.offset(-16);
        make.top.and.bottom.equalTo(self.contentView);
    }];
    [self.msgTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.centerY.equalTo(self.infoView);
        make.width.equalTo(@90);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.infoView);
        make.left.equalTo(self.msgTypeLabel.mas_right).with.offset(20);
    }];
}

#pragma mark - Setter

- (void)setCellInfoBean:(GatewayCellBasicInfoBean *)cellInfoBean {
    _cellInfoBean = cellInfoBean;
    
    _msgTypeLabel.text = cellInfoBean.messageName;
    _msgLabel.text = cellInfoBean.message;
    
    if ([cellInfoBean.message isEqualToString:@"正常"]) {
        _msgLabel.textColor = [UIColor beautyGreen];
    } else if ([_msgLabel.text isEqualToString:@"暂停"]) {
        _msgLabel.textColor = [UIColor beautyRed];
    } else {
        _msgLabel.textColor = [UIColor blackColor];
    }
    
    if ([_msgTypeLabel.text isEqualToString:@"姓名"]) {
        _logoImageView.image = [UIImage imageNamed:@"network_name"];
    } else if ([_msgTypeLabel.text isEqualToString:@"学号"]) {
        _logoImageView.image = [UIImage imageNamed:@"network_number"];
    } else if ([_msgLabel.text isEqualToString:@"正常"]) {
        _logoImageView.image = [UIImage imageNamed:@"network_state_normal"];
    } else if ([_msgLabel.text isEqualToString:@"暂停"]) {
        _logoImageView.image = [UIImage imageNamed:@"network_state_pause"];
    } else if ([_msgTypeLabel.text isEqualToString:@"电子钱包"]) {
        _logoImageView.image = [UIImage imageNamed:@"network_E_wallet"];
    } else {
        _logoImageView = nil;
    }
}

#pragma mark - Getter

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.numberOfLines = 0;
        _msgLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self.infoView addSubview:_msgLabel];
    }
    return _msgLabel;
}

- (UILabel *)msgTypeLabel {
    if (!_msgTypeLabel) {
        _msgTypeLabel = [[UILabel alloc] init];
        _msgTypeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _msgTypeLabel.textColor = [UIColor lightGrayColor];
        [self.infoView addSubview:_msgTypeLabel];
    }
    return _msgTypeLabel;
}

- (UIView *)infoView {
    if (!_infoView) {
        _infoView = [[UIView alloc] init];
        [self.contentView addSubview:_infoView];
    }
    return _infoView;
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_logoImageView];
    }
    return _logoImageView;
}

@end

@interface NetworkPersonalInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation NetworkPersonalInfoViewController

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
    self.title = @"基本信息";
//    self.tableView.refreshControl = self.refreshControl;
}

- (void)initConstaints {
    self.tableView.frame = self.view.frame;
}

#pragma mark - Response Method

//- (void)beginRefreshing {
//    [self.refreshControl beginRefreshing];
//    [self.model refreshPayInfoData];
//    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.0f];
//}
//
//- (void)endRefreshing {
//    [self.refreshControl endRefreshing];
//    [self.tableView reloadData];
//}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            NetworkPersonalInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkPersonalInfoTableViewCellReuseID];
            if (!cell) {
                cell = [[NetworkPersonalInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkPersonalInfoTableViewCellReuseID];
                cell.cellInfoBean = self.infoBean.userInfoBeanArray[indexPath.row];
            }
            return cell;
        }
            break;
        case 1:
        {
            NetworkPersonalInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkProductInfoTableViewCellReuseID];
            if (!cell) {
                cell = [[NetworkPersonalInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkProductInfoTableViewCellReuseID];
                cell.cellInfoBean = self.infoBean.productInfoBeanArray[indexPath.row];
            }
            return cell;
        }
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.infoBean.userInfoBeanArray.count;
            break;
        case 1:
            return self.infoBean.productInfoBeanArray.count;
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.infoBean) {
        return 2;
    } else {
        return 0;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == self.model.financialPayInfoArray.count - 1) {
//        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 50)];
//        _indicatorView.center = CGPointMake(SCREEN_WIDTH_ACTUAL * 0.5, footerView.frame.origin.y + 20);
//        footerView.backgroundColor = [UIColor clearColor];
//        [footerView addSubview:self.indicatorView];
//        [self.indicatorView startAnimating];
//        _tableView.tableFooterView.hidden = NO;
//        _tableView.tableFooterView = footerView;
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            _tableView.tableFooterView.hidden = YES;
//            [_indicatorView stopAnimating];
//        });
//    }
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomSectionHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kNetworkHeaderFooterViewReuseID];
    if (!headerView) {
        headerView = [[CustomSectionHeaderFooterView alloc] initWithReuseIdentifier:kNetworkHeaderFooterViewReuseID];
    }
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    headerView.section = section;
    
    switch (section) {
        case 0:
        {
            headerView.titleLabel.text = @"用户信息";
        }
            break;
        case 1:
        {
            headerView.titleLabel.text = @"产品信息";
        }
        default:
            break;
    }
    
    return headerView;
    
}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height) {
//        WS(ws);
//        [self.model queryUserOnlineFinancialPayListComplete:^(BOOL success, NSString *data) {
//            if (success) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [ws.tableView reloadData];
//                });
//            }
//        }];
//    }
//}

#pragma mark - Setter

- (void)setInfoBean:(GatewaySelfServiceMenuBasicInfoBean *)infoBean {
    _infoBean = infoBean;
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.allowsSelection = NO;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.indicatorView startAnimating];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

//- (UIRefreshControl *)refreshControl {
//    if (!_refreshControl) {
//        _refreshControl = [[UIRefreshControl alloc] init];
//        [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
//    }
//    return _refreshControl;
//}

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
