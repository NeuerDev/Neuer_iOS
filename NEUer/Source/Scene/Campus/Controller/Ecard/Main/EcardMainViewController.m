//
//  EcardViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardMainViewController.h"
#import "EcardMyViewController.h"
#import "EcardTableViewCell.h"
#import "EcardModel.h"

#import "LoginViewController.h"
#import "EcardHistoryViewController.h"

#import "CustomSectionHeaderFooterView.h"

static NSString * const kEcardTodayConsumeHistoryHeaderViewId = @"kEcardTodayConsumeHistoryHeaderViewId";
static NSString * const kEcardTodayConsumeHistoryCellId = @"kEcardTodayConsumeHistoryCellId";

@interface EcardMainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) EcardModel *ecardModel;
@property (nonatomic, strong) EcardInfoBean *infoBean;

// 余额 view
@property (nonatomic, strong) UIView *balanceView;
@property (nonatomic, strong) UILabel *balanceValueLabel;
@property (nonatomic, strong) UILabel *balanceInfoLabel;
@property (nonatomic, strong) NSArray<UIButton *> *balanceViewButtons;

// 下拉刷新 充值 以及 tableView
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIBarButtonItem *rechargeButtonItem;
@property (nonatomic, strong) UITableView *consumeHistoryTableView;

@end

@implementation EcardMainViewController

#pragma mark - Init Methods

- (instancetype)initWithEcardModel:(EcardModel *)model {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"校卡中心";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.rechargeButtonItem;
    self.consumeHistoryTableView.refreshControl = self.refreshControl;
    [self initConstraints];
    [self setInfoBean:[EcardInfoBean infoWithUser:[UserCenter defaultCenter].currentUser]];
    [self checkLoginState];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)initConstraints {
    self.consumeHistoryTableView.frame = self.view.frame;
    
    [self.balanceValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.balanceView.mas_top).with.offset(32);
        make.centerX.equalTo(self.balanceView);
    }];
    
    [self.balanceInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.balanceValueLabel.mas_bottom);
        make.centerX.equalTo(self.balanceValueLabel);
    }];
    
    for (int index = 0; index < self.balanceViewButtons.count; index++) {
        UIView *view = self.balanceViewButtons[index];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.balanceView.mas_right).multipliedBy((float)(2*index+1)/(float)(self.balanceViewButtons.count*2)).with.offset(24*((float)(self.balanceViewButtons.count+1)/2-(float)(index+1)));
            make.bottom.equalTo(self.balanceView.mas_bottom);
            make.height.mas_equalTo(@(54));
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)checkLoginState {
    WS(ws);
    User *currentUser = [UserCenter defaultCenter].currentUser;
    NSString *account = currentUser.number ? : @"";
    NSString *password = [currentUser.keychain passwordForKeyType:UserKeyTypeCard] ? : @"";
    
    // 如果用户、密码都存在 则进行登录（查询信息）操作
    if (account.length>0 && password.length>0) {
        [ws.ecardModel queryInfoComplete:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"success query info");
                ws.infoBean = ws.ecardModel.info;
                
                // 查询今日消费记录
                [ws.ecardModel queryTodayConsumeHistoryComplete:^(BOOL success, BOOL hasMore, NSError *error) {
                    if (success) {
                        [ws.consumeHistoryTableView reloadData];
                    }
                }];
            } else {
                [ws handleError:error];
            }
        }];
    } else {
        [ws showLoginBox];
    }
}

- (void)handleError:(NSError *)error {
    switch (error.code) {
        case JHErrorTypeUnknown:
            
            break;
        case JHErrorTypeRequireLogin:
            [self showLoginBox];
            break;
            
        default:
            break;
    }
}

- (void)showLoginBox {
    WS(ws);
    User *currentUser = [UserCenter defaultCenter].currentUser;
    NSString *account = currentUser.number ? : @"";
    NSString *password = [currentUser.keychain passwordForKeyType:UserKeyTypeCard]  ? : @"";
    LoginViewController *signinVC = [[LoginViewController alloc] init];
    signinVC.modalPresentationStyle = UIModalPresentationCustom;
    signinVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [signinVC setupWithTitle:@"登录校卡中心"
                   inputType:NEUInputTypeAccount|NEUInputTypePassword|NEUInputTypeVerifyCode
                    contents:@{
                               @(NEUInputTypeAccount):account,
                               @(NEUInputTypePassword):password,
                               }
                 resultBlock:^(NSDictionary<NSNumber *,NSString *> *result, BOOL complete) {
                     if (complete) {
                         NSString *userName = result[@(NEUInputTypeAccount)]?:@"";
                         NSString *password = result[@(NEUInputTypePassword)]?:@"";
                         NSString *verifyCode = result[@(NEUInputTypeVerifyCode)]?:@"";
                         [ws loginWithUser:userName password:password verifyCode:verifyCode];
                     } else {
                         [ws.navigationController popViewControllerAnimated:YES];
                     }
                 }];
    
    __weak LoginViewController *weakSigninVC = signinVC;
    signinVC.changeVerifyImageBlock = ^{
        [ws.ecardModel getVerifyImage:^(UIImage *verifyImage, NSString *message) {
            weakSigninVC.verifyImage = verifyImage;
        }];
    };
    [self presentViewController:signinVC animated:YES completion:^{
        [ws.ecardModel getVerifyImage:^(UIImage *verifyImage, NSString *message) {
            weakSigninVC.verifyImage = verifyImage;
        }];
    }];
}

- (void)loginWithUser:(NSString *)user password:(NSString *)password verifyCode:(NSString *)verifyCode {
    WS(ws);
    [self.ecardModel authorUser:user password:password verifyCode:verifyCode complete:^(BOOL success, NSError *error) {
        if (success) {
            [[UserCenter defaultCenter] setAccount:user password:password forKeyType:UserKeyTypeCard];
            
            [ws.ecardModel queryInfoComplete:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"success query info");
                    ws.infoBean = ws.ecardModel.info;
                }
            }];
            
            [ws.ecardModel queryTodayConsumeHistoryComplete:^(BOOL success, BOOL hasMore, NSError *error) {
                if (success) {
                    [ws.consumeHistoryTableView reloadData];
                }
            }];
        }
    }];
}

- (void)setMainColor:(UIColor *)color animated:(BOOL)animated {
    NSTimeInterval interval = animated ? 0.3f : 0;
    
    [UIView animateWithDuration:interval animations:^{
        _balanceView.layer.borderColor = color.CGColor;
        _balanceView.backgroundColor = [color colorWithAlphaComponent:0.1];
        _balanceValueLabel.textColor = color;
        _balanceInfoLabel.textColor = color;
        for (UIButton *button in _balanceViewButtons) {
            [button setTitleColor:color forState:UIControlStateNormal];
            [button setTitleColor:[color colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        }
    }];
}



#pragma mark - Respond Methods

- (void)showMyCard {
    EcardMyViewController *ecardMyVC = [[EcardMyViewController alloc] init];
    [ecardMyVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [ecardMyVC setModalPresentationStyle:UIModalPresentationCustom];
    [self presentViewController:ecardMyVC animated:YES completion:nil];
}

- (void)showStatistics {
    
}

- (void)showBills {
    
}

- (void)changePassword {
    
}

- (void)reportLost {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确认挂失校园卡" message:@"一旦确认挂失，您的校园卡将暂时无法使用，直到您到校园卡服务中心重新激活或补办校园卡" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确认挂失" style:UIAlertActionStyleDestructive handler:nil]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertVC animated:YES completion:nil];
    });
}

- (void)recharge {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"wx2654d9155d70a468://"] options:@{} completionHandler:^(BOOL success) {
        if (!success) {
            NSLog(@"assssddd");
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"打开中国建设银行App失败" message:@"请检查是否已正确安装\"中国建设银行App\"" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertVC animated:YES completion:nil];
            });
        }
    }];
}

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
    EcardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEcardTodayConsumeHistoryCellId];
    if (!cell) {
        cell = [[EcardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEcardTodayConsumeHistoryCellId];
    }
    
    EcardConsumeBean *consumeBean = self.ecardModel.todayConsumeArray[indexPath.row];
    
    cell.consumeBean = consumeBean;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ecardModel.todayConsumeArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomSectionHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kEcardTodayConsumeHistoryHeaderViewId];
    if (!headerView) {
        headerView = [[CustomSectionHeaderFooterView alloc] initWithReuseIdentifier:kEcardTodayConsumeHistoryHeaderViewId];
    }
    
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    headerView.section = section;
    headerView.titleLabel.text = @"今日消费";
    [headerView.actionButton setTitle:@"历史账单" forState:UIControlStateNormal];
    [headerView setPerformActionBlock:^(NSInteger section) {
        
    }];
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

#pragma mark - Setter

- (void)setInfoBean:(EcardInfoBean *)infoBean {
    _infoBean = infoBean;
    UIColor *mainColor = [UIColor colorWithHexStr:@[@"#9C9C9C",@"#64B74E",@"#FFBA13",@"#FF5100"][infoBean.balanceLevel]];
    
    if (infoBean) {
        [_balanceView.gestureRecognizers lastObject].enabled = YES;
        _balanceValueLabel.text = infoBean.balance;
        
        if (infoBean.enable) {
            _balanceInfoLabel.text = [NSString stringWithFormat:@"%@ %@", @[@"",@"余额充足",@"余额偏低",@"尽快充值"][infoBean.balanceLevel], infoBean.lastUpdate];
        } else {
            _balanceInfoLabel.text = @"校卡不可用";
        }
    } else {
        
    }
    
    [self setMainColor:mainColor animated:NO];
}

#pragma mark - Getter

- (EcardModel *)ecardModel {
    if (!_ecardModel) {
        _ecardModel = [[EcardCenter defaultCenter] currentModel];
    }
    
    return _ecardModel;
}

- (UIView *)balanceView {
    if (!_balanceView) {
        _balanceView = [[UIView alloc] init];
        _balanceView.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
        _balanceView.layer.borderWidth = 1.0f;
        _balanceView.layer.cornerRadius = 8.0f;
        _balanceView.layer.borderColor = [UIColor grayColor].CGColor;
        _balanceView.userInteractionEnabled = YES;
        [_balanceView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showStatistics)]];
        [_balanceView.gestureRecognizers lastObject].enabled = NO;
    }
    
    return _balanceView;
}

- (UILabel *)balanceValueLabel {
    if (!_balanceValueLabel) {
        _balanceValueLabel = [[UILabel alloc] init];
        _balanceValueLabel.font = [UIFont systemFontOfSize:48.0 weight:UIFontWeightLight];
        _balanceValueLabel.text = @"0.00";
        [self.balanceView addSubview:_balanceValueLabel];
    }
    
    return _balanceValueLabel;
}

- (UILabel *)balanceInfoLabel {
    if (!_balanceInfoLabel) {
        _balanceInfoLabel = [[UILabel alloc] init];
        _balanceInfoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _balanceInfoLabel.text = @"未获取";
        [self.balanceView addSubview:_balanceInfoLabel];
    }
    
    return _balanceInfoLabel;
}

- (UITableView *)consumeHistoryTableView {
    if (!_consumeHistoryTableView) {
        _consumeHistoryTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _consumeHistoryTableView.delegate = self;
        _consumeHistoryTableView.dataSource = self;
        _consumeHistoryTableView.showsVerticalScrollIndicator = NO;
        _consumeHistoryTableView.allowsSelection = NO;
        _consumeHistoryTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _consumeHistoryTableView.backgroundColor = [UIColor clearColor];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_WIDTH_ACTUAL*0.5)];
        [headerView addSubview:self.balanceView];
        [self.balanceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(headerView);
            make.width.mas_equalTo(@(SCREEN_WIDTH_ACTUAL-32));
            make.height.mas_equalTo(@((SCREEN_WIDTH_ACTUAL-32)*0.5));
        }];
        [headerView layoutIfNeeded];
        _consumeHistoryTableView.tableHeaderView = headerView;
        _consumeHistoryTableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_consumeHistoryTableView];
    }
    
    return _consumeHistoryTableView;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
    }
    
    return _refreshControl;
}

- (UIBarButtonItem *)rechargeButtonItem {
    if (!_rechargeButtonItem) {
        _rechargeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"充值" style:UIBarButtonItemStylePlain target:self action:@selector(recharge)];
    }
    
    return _rechargeButtonItem;
}

- (NSArray<UIButton *> *)balanceViewButtons {
    if (!_balanceViewButtons) {
        UIButton *mycardButton = [[UIButton alloc] init];
        [mycardButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [mycardButton setTitle:@"我的校卡" forState:UIControlStateNormal];
        [mycardButton addTarget:self action:@selector(showMyCard) forControlEvents:UIControlEventTouchUpInside];
        [self.balanceView addSubview:mycardButton];
        
        UIButton *changePasswordButton = [[UIButton alloc] init];
        [changePasswordButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [changePasswordButton setTitle:@"修改密码" forState:UIControlStateNormal];
        [changePasswordButton addTarget:self action:@selector(changePassword) forControlEvents:UIControlEventTouchUpInside];
        [self.balanceView addSubview:changePasswordButton];
        
        UIButton *reportLostButton = [[UIButton alloc] init];
        [reportLostButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [reportLostButton setTitle:@"自助挂失" forState:UIControlStateNormal];
        [reportLostButton addTarget:self action:@selector(reportLost) forControlEvents:UIControlEventTouchUpInside];
        [self.balanceView addSubview:reportLostButton];
        
        
        _balanceViewButtons = @[mycardButton, changePasswordButton, reportLostButton];
    }
    
    return _balanceViewButtons;
}

@end
