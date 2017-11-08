//
//  NetworkMainViewController.m
//  NEUer
//
//  Created by lanya on 2017/11/4.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "NetworkMainViewController.h"
#import "NetworkPayListViewController.h"
#import "NetworkCheckoutListViewController.h"
#import "NetworkPersonalInfoViewController.h"
#import "NetworkInternetListViewController.h"

#import "CustomSectionHeaderFooterView.h"
#import "LoginViewController.h"
#import "NetworkOnlineDevicesTableViewCell.h"
#import "NetworkInternetListTableViewCell.h"

#import "GatewaySelfServiceMenuModel.h"

static NSString *kNetworkHeaderFooterViewReuseID = @"headerFooterViewReuseID";
static NSString *kNetworkTableViewCellInternetListReuseID = @"internetListCellID";
static NSString *kNetworkTableViewCellOnlineDevicesReuseID = @"onlineDevicesCellID";

@interface NetworkRestFlowView : UIView
typedef void(^NetwerkRestFlowViewSetActionBlock)(NSInteger tag);

@property (nonatomic, strong) UILabel *restFlowLabel;
@property (nonatomic, strong) UILabel *restFlowLevelLabel;
@property (nonatomic, strong) NSArray <UIButton *> *restFlowViewButtons;

@property (nonatomic, strong) GatewaySelfServiceMenuBasicInfoBean *basicInfo;

- (void)setActionBlock:(NetwerkRestFlowViewSetActionBlock)block;

@end

@implementation NetworkRestFlowView
{
    NetwerkRestFlowViewSetActionBlock _actionBlock;
}

#pragma mark - Init
- (instancetype)init {
    if (self = [super init]) {
        
        [self initData];
        [self initConstraints];
    }
    return self;
}

- (void)initData {
    self.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 8.0f;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.userInteractionEnabled = YES;
    [self.gestureRecognizers lastObject].enabled = NO;
}

- (void)initConstraints {

    [self.restFlowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(32);
        make.centerX.equalTo(self);
    }];
    [self.restFlowLevelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.restFlowLabel.mas_bottom);
        make.centerX.equalTo(self.restFlowLabel);
    }];
}

- (void)layoutSubviews {
    for (int index = 0; index < self.restFlowViewButtons.count; index++) {
        UIView *view = self.restFlowViewButtons[index];

        float xValue = (float)self.frame.size.width / self.restFlowViewButtons.count;
        view.frame = CGRectMake(xValue * index, self.frame.origin.y + self.frame.size.height - 54 - 15, xValue, 54);
    }
}

#pragma mark - PrivateMethod

- (void)setMainColor:(UIColor *)color animated:(BOOL)animated {
    NSTimeInterval interval = animated ? 0.3f : 0;
    
    [UIView animateWithDuration:interval animations:^{
        self.layer.borderColor = color.CGColor;
        self.backgroundColor = [color colorWithAlphaComponent:0.1];
        _restFlowLabel.textColor = color;
        _restFlowLevelLabel.textColor = color;
        for (UIButton *button in _restFlowViewButtons) {
            [button setTitleColor:color forState:UIControlStateNormal];
            [button setTitleColor:[color colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        }
    }];
}

#pragma mark - Setter
- (void)setBasicInfo:(GatewaySelfServiceMenuBasicInfoBean *)basicInfo {
    
    _basicInfo = basicInfo;
    if (basicInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _restFlowLevelLabel.text = [[_basicInfo.restFlowLevelDictionary allValues] lastObject];
            _restFlowLabel.text = [NSString stringWithFormat:@"%@ G", _basicInfo.product_restFlow];
            GatewaySelfServiceMenuRestFlowLevel level = [[_basicInfo.restFlowLevelDictionary allKeys] lastObject].integerValue;
            UIColor *mainColor = [UIColor colorWithHexStr:@[@"#9C9C9C",@"#64B74E",@"#FFBA13",@"#FF5100"][level]];
            [self setMainColor:mainColor animated:YES];
        });
    }
}

#pragma mark - Response Method
- (void)didClickedButtonWithTag:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (_actionBlock) {
        _actionBlock(tag);
    }
}

- (void)setActionBlock:(NetwerkRestFlowViewSetActionBlock)block {
    _actionBlock = block;
}

#pragma mark - Getter

- (UILabel *)restFlowLabel {
    if (!_restFlowLabel) {
        _restFlowLabel = [[UILabel alloc] init];
        _restFlowLabel.font = [UIFont systemFontOfSize:48.0 weight:UIFontWeightLight];
        _restFlowLabel.text = @"0.00";
        _restFlowLabel.textColor = [UIColor grayColor];
        [self addSubview:_restFlowLabel];
    }
    return _restFlowLabel;
}

- (UILabel *)restFlowLevelLabel {
    if (!_restFlowLevelLabel) {
        _restFlowLevelLabel = [[UILabel alloc] init];
        _restFlowLevelLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _restFlowLevelLabel.text = @"未获取";
        _restFlowLevelLabel.textColor = [UIColor grayColor];
        [self addSubview:_restFlowLevelLabel];
    }
    return _restFlowLevelLabel;
}

- (NSArray<UIButton *> *)restFlowViewButtons {
    if (!_restFlowViewButtons) {
        
        UIButton *personalInfoButton = [[UIButton alloc] init];
        personalInfoButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [personalInfoButton addTarget:self action:@selector(didClickedButtonWithTag:) forControlEvents:UIControlEventTouchUpInside];
        [personalInfoButton setTitle:@"基本信息" forState:UIControlStateNormal];
        personalInfoButton.tag = 0000;
        [personalInfoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self addSubview:personalInfoButton];
        
        UIButton *modifyPasswordButton = [[UIButton alloc] init];
        modifyPasswordButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [modifyPasswordButton addTarget:self action:@selector(didClickedButtonWithTag:) forControlEvents:UIControlEventTouchUpInside];
        [modifyPasswordButton setTitle:@"修改密码" forState:UIControlStateNormal];
        modifyPasswordButton.tag = 0001;
        modifyPasswordButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [modifyPasswordButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self addSubview:modifyPasswordButton];
        
        UIButton *financeListButton = [[UIButton alloc] init];
        [financeListButton setTitle:@"缴费清单" forState:UIControlStateNormal];
        financeListButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [financeListButton addTarget:self action:@selector(didClickedButtonWithTag:) forControlEvents:UIControlEventTouchUpInside];
        financeListButton.tag = 0002;
        financeListButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [financeListButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self addSubview:financeListButton];
        
        UIButton *financeCheckoutButton = [[UIButton alloc] init];
        financeCheckoutButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [financeCheckoutButton addTarget:self action:@selector(didClickedButtonWithTag:) forControlEvents:UIControlEventTouchUpInside];
        [financeCheckoutButton setTitle:@"结算清单" forState:UIControlStateNormal];
        financeCheckoutButton.tag = 0003;
        financeCheckoutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [financeCheckoutButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self addSubview:financeCheckoutButton];
        
        _restFlowViewButtons = @[personalInfoButton, modifyPasswordButton, financeListButton, financeCheckoutButton];
    }
    return _restFlowViewButtons;
}

@end

@interface NetworkMainViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NetworkRestFlowView *restFlowView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIBarButtonItem *pauseAccountItem;

@property (nonatomic, strong) GatewaySelfServiceMenuModel *model;

@end

@implementation NetworkMainViewController

#pragma mark - LifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstrains];
    [self showLoginBox];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Init
- (void)initData {
    self.title = @"网络中心";
    self.tableView.refreshControl = self.refreshControl;
    self.navigationItem.rightBarButtonItem = self.pauseAccountItem;
    
    WS(ws);
    [self.restFlowView setActionBlock:^(NSInteger tag) {
        switch (tag) {
            case 0000:
            {
//                个人信息
                [ws pushPersonalInfoViewController];
            }
                break;
            case 0001:
            {
//                修改密码
                [ws showModifyPasswordBox];
            }
                break;
            case 0002:
            {
//                缴费清单
                [ws pushPayListViewController];
            }
                break;
            case 0003:
            {
//                结算清单
                [ws pushCheckoutListViewController];
            }
            default:
                break;
        }
    }];
}

- (void)initConstrains {
    self.tableView.frame = self.view.frame;
}


#pragma mark - Response Method

- (void)beginRefreshing {
    [self.refreshControl beginRefreshing];
    [self.model refreshData];
    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:2];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)showLoginBox {
    WS(ws);
//    User *currentUser = [UserCenter defaultCenter].currentUser;
//    NSString *account = currentUser.number ? : @"20155057";
//    NSString *password = [currentUser.keychain passwordForKeyType:UserKeyTypeIPGW]  ? : @"009974";
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.modalPresentationStyle = UIModalPresentationCustom;
    loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [loginVC setupWithTitle:@"登录校卡中心"
                   inputType:LoginInputTypeAccount|LoginInputTypePassword|LoginInputTypeVerifyCode
                    contents:@{
                               @(LoginInputTypeAccount):@"20154883",
                               @(LoginInputTypePassword):@"123456",
                               }
                 resultBlock:^(NSDictionary<NSNumber *,NSString *> *result, BOOL complete) {
                     if (complete) {
                         NSString *userName = result[@(LoginInputTypeAccount)]?:@"";
                         NSString *password = result[@(LoginInputTypePassword)]?:@"";
                         NSString *verifyCode = result[@(LoginInputTypeVerifyCode)]?:@"";
                         [ws loginWithUser:userName password:password verifyCode:verifyCode];
                     } else {
                         [ws.navigationController popViewControllerAnimated:YES];
                     }
                 }];
    
    __weak LoginViewController *weakLoginVC = loginVC;
    loginVC.changeVerifyImageBlock = ^{
        [ws.model getVerifyImage:^(UIImage *verifyImage, NSString *message) {
            weakLoginVC.verifyImage = verifyImage;
        }];
    };
    [self presentViewController:loginVC animated:YES completion:^{
        [ws.model getVerifyImage:^(UIImage *verifyImage, NSString *message) {
            loginVC.verifyImage = verifyImage;
        }];
    }];
}

- (void)loginWithUser:(NSString *)user password:(NSString *)password verifyCode:(NSString *)verifyCode {
    WS(ws);
    [self.model loginGatewaySelfServiceMenuWithUser:user password:password verifyCode:verifyCode loginState:^(BOOL success, NSString *msg) {
        if (success) {
            
            [[UserCenter defaultCenter] setAccount:user password:password forKeyType:UserKeyTypeIPGW];
            [ws.model queryUserBasicInformationListComplete:^(BOOL success, NSString *data) {
                if (success) {
                    [_restFlowView setBasicInfo:ws.model.basicInfo];
                }
            }];
            [ws.model queryUserOnlineInformationListComplete:^(BOOL success, NSString *data) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ws.tableView reloadData];
                    });
                }
            }];
            [ws.model queryUserOnlineLogDetailListComplete:^(BOOL success, NSString *data) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ws.tableView reloadData];
                    });
                }
            }];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws showLoginBox];
            });
        }
    }];
}

- (void)didClickedChangeAccountStateButton {
    
    WS(ws);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"请问您确定要%@该账户吗？", self.model.basicInfo.user_state] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if ([ws.model.basicInfo.user_state isEqualToString:@"暂停"]) {
            [ws.model pauseAccountComplete:^(BOOL success, NSString *data) {
                if (success) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [ws.pauseAccountItem setTitle:@"开启"];
                    });
                    [ws.model queryUserBasicInformationListComplete:^(BOOL success, NSString *data) {}];
                }
            }];
        } else {
            [ws.model openAccountComplete:^(BOOL success, NSString *data) {
                if (success) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [ws.pauseAccountItem setTitle:@"暂停"];
                    });
                    [ws.model queryUserBasicInformationListComplete:^(BOOL success, NSString *data) {}];
                }
            }];
        }
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)pushPersonalInfoViewController {
    NetworkPersonalInfoViewController *personalInfoViewController = [[NetworkPersonalInfoViewController alloc] init];
    if (self.model) {
        personalInfoViewController.infoBean = self.model.basicInfo;
        [self.navigationController pushViewController:personalInfoViewController animated:YES];
    }
}

- (void)pushPayListViewController {
    NetworkPayListViewController *payListViewController = [[NetworkPayListViewController alloc] init];
    if (self.model) {
        payListViewController.model = self.model;
        [self.navigationController pushViewController:payListViewController animated:YES];
    }
}

- (void)pushCheckoutListViewController {
    NetworkCheckoutListViewController *checkoutListViewController = [[NetworkCheckoutListViewController alloc] init];
    if (self.model) {
        checkoutListViewController.model = self.model;
        [self.navigationController pushViewController:checkoutListViewController animated:YES];
    }
}

- (void)pushInternetListViewController {
    NetworkInternetListViewController *internetViewController = [[NetworkInternetListViewController alloc] init];
    if (self.model) {
        internetViewController.model = self.model;
        [self.navigationController pushViewController:internetViewController animated:YES];
    }
}


#pragma mark - Private Method

- (void)showModifyPasswordBox {
    
    WS(ws);
    LoginViewController *modifyVC = [[LoginViewController alloc] init];
    modifyVC.modalPresentationStyle = UIModalPresentationCustom;
    modifyVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [modifyVC setupWithTitle:@"修改密码" inputType:LoginInputTypePassword | LoginInputTypeNewPassword | LoginInputTypeRePassword resultBlock:^(NSDictionary<NSNumber *,NSString *> *result, BOOL complete) {
        
        if (complete) {
            NSString *oldPassword = result[@(LoginInputTypePassword)];
            NSString *newPassword = result[@(LoginInputTypeNewPassword)];
            NSString *rePassword = result[@(LoginInputTypeRePassword)];
//            NSLog(@"%@-----%@", oldPassword, newPassword);
            [ws modifyPasswordWithOldPassword:oldPassword newPassword:newPassword rePassword:rePassword];
        }
    }];
    [self presentViewController:modifyVC animated:YES completion:nil];
}

- (void)modifyPasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword rePassword:(NSString *)rePassword {
    [self.model modifyPasswordForIPGWwithOldPassword:oldPassword newPassword:newPassword confirmPassword:rePassword Complete:^(BOOL success, NSString *data) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLoginBox];
            });
        }
    }];
}

- (void)logoutUserWithTag:(NSInteger)tag {
    WS(ws);
    [self.model offLineTheIPGWWithDevicesID:tag];
    [self.model queryUserOnlineLogDetailListComplete:^(BOOL success, NSString *data) {
        if (success) {
            if (ws.model.onlineInfoArray.count > 0) {
                for (int i = 0; i < ws.model.onlineInfoArray.count; ++i) {
                    if ([ws.model.onlineInfoArray[i].online_ID isEqualToString:[NSString stringWithFormat:@"%ld", tag]]) {
                        NSLog(@"下线失败");
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [ws.tableView reloadData];
                        });
                    }
                }
            }
        }
    }];
}

#pragma mark - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        NetworkOnlineDevicesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkTableViewCellOnlineDevicesReuseID];
        if (!cell) {
            cell = [[NetworkOnlineDevicesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkTableViewCellOnlineDevicesReuseID];
            cell.onlineInfoBean = self.model.onlineInfoArray[indexPath.row];
        }
        
        WS(ws);
        [cell setOnlineDevicesActionBlock:^(NSInteger tag) {
            [ws logoutUserWithTag:tag];
        }];
        return cell;
    } else {
        NetworkInternetListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkTableViewCellInternetListReuseID];
        if (!cell) {
            cell = [[NetworkInternetListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNetworkTableViewCellInternetListReuseID];
            if (self.model.todayInternetRecordInfoArray.count > 0) {
                cell.infoBean = self.model.todayInternetRecordInfoArray[indexPath.row];
            }
        }
        
        return cell;
    }
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return self.model.onlineInfoArray.count;
        }
            break;
        case 1:
        {
            return self.model.todayInternetRecordInfoArray.count;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.model.onlineInfoArray.count > 0) {
        if (self.model.internetRecordInfoArray.count > 0) {
            return 2;
        } else {
            return 1;
        }
    } else {
        if (self.model.internetRecordInfoArray.count > 0) {
            return 1;
        } else {
            return 0;
        }
    }
}

#pragma mark - UITableViewDelegate
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
            headerView.titleLabel.text = @"当前在线设备";
            headerView.actionButton.hidden = YES;
        }
            break;
        case 1:
        {
            headerView.titleLabel.text = @"今日上网明细";
            headerView.actionButton.hidden = NO;
            [headerView.actionButton setTitle:@"详情" forState:UIControlStateNormal];
        }
        default:
            break;
    }
    
    WS(ws);
    [headerView setPerformActionBlock:^(NSInteger section) {
        switch (section) {
            case 0:
                
                break;
            case 1:
            {
                [ws pushInternetListViewController];
            }
                break;
            default:
                break;
        }
    }];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 64;
    } else {
        return 74;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64;
}

#pragma mark - GETTER
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_WIDTH_ACTUAL * 0.5)];
        [headerView addSubview:self.restFlowView];
        [self.restFlowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(headerView);
            make.width.equalTo(@(SCREEN_WIDTH_ACTUAL - 32));
            make.height.equalTo(@(SCREEN_WIDTH_ACTUAL * 0.5 - 32));
        }];
        [headerView layoutIfNeeded];
        _tableView.tableHeaderView = headerView;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.allowsSelection = NO;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NetworkRestFlowView *)restFlowView {
    if (!_restFlowView) {
        _restFlowView = [[NetworkRestFlowView alloc] init];
    }
    return _restFlowView;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (UIBarButtonItem *)pauseAccountItem {
    if (!_pauseAccountItem) {
        _pauseAccountItem = [[UIBarButtonItem alloc] initWithTitle:@"暂停" style:UIBarButtonItemStylePlain target:self action:@selector(didClickedChangeAccountStateButton)];
    }
    return _pauseAccountItem;
}

- (GatewaySelfServiceMenuModel *)model {
    if (!_model) {
        _model = [[GatewaySelfServiceMenuModel alloc] init];
    }
    return _model;
}

@end
