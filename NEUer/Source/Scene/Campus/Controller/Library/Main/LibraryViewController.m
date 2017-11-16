//
//  LibraryViewController.m
//  NEUer
//
//  Created by kl h on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryViewController.h"
#import "LibraryNewBookViewController.h"
#import "LibraryMostViewController.h"
#import "SearchLibraryResultViewController.h"
#import "LoginViewController.h"
#import "SearchLibraryViewController.h"
#import "LibraryHistoryViewController.h"
#import "LibraryRecommendViewController.h"

#import "CustomSectionHeaderFooterView.h"


#import "SearchLibraryNewBookModel.h"
#import "SearchLibraryBorrowingModel.h"
#import "LibraryLoginModel.h"

static NSString * const kLibraryReturnConsumeHistoryHeaderViewId = @"kLibraryReturnConsumeHistoryHeaderViewId";
static NSString * const kLibraryDefaultCellId = @"kLibraryDefaultCellId";
static NSString * const kLibraryResultCellId = @"kLibraryResultCellId";

@interface LibraryViewController () <UITableViewDelegate,UITableViewDataSource,LibraryLoginDelegate,SearchLibraryBorrowingDelegate,SearchLibraryNewBookDelegate>
//全局
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIBarButtonItem *loginButtonItem;
//信息
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UILabel *bookNumLabel;
@property (strong ,nonatomic) UITapGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) UILabel *bookNumInfoLabel;
@property (nonatomic, strong) NSArray<UIButton *> *infoViewBtns;
@property (nonatomic, strong) UITableView *infoTableView;
//model
@property (nonatomic, strong) SearchLibraryNewBookModel *newbookModel;
@property (nonatomic, strong) SearchLibraryBorrowingModel *mostModel;
@property (nonatomic, strong) LibraryLoginModel *loginModel;

@property (nonatomic, strong) NSArray<NSString *> *bookStrings;
@property (nonatomic, strong) NSArray<NSString *> *mostStrings;
@property (nonatomic, assign) BOOL isButtonEnabled;

@end

@implementation LibraryViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
    //@[@"#9C9C9C",@"#64B74E",@"#FFBA13",@"#FF5100"]
    UIColor *mainColor = [UIColor colorWithHexStr:@"#9C9C9C"];
    [self setMainColor:mainColor animated:YES];

}

#pragma mark - Init Methods
- (void)initData {
    [self setTitle:@"图书馆"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.infoTableView.refreshControl = self.refreshControl;
    self.navigationItem.rightBarButtonItem = self.loginButtonItem;
    _isButtonEnabled = YES;
    [self autoLogin];
    [self.newbookModel search];
    [self.mostModel search];
}

- (void)initConstraints {
    self.infoTableView.frame = self.view.frame;
    
    [self.bookNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.infoView.mas_bottom).multipliedBy(1-0.618);
        make.centerX.equalTo(self.infoView);
    }];
    
    [self.bookNumInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bookNumLabel.mas_bottom);
        make.centerX.equalTo(self.bookNumLabel);
    }];
    
    for (int i = 0; i < self.infoViewBtns.count; i++) {
        UIView *view = self.infoViewBtns[i];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.infoView.mas_right).multipliedBy((float)(2*i+1)/(float)(self.infoViewBtns.count*2)).with.offset(24*((float)(self.infoViewBtns.count+1)/2-(float)(i+1)));
            make.bottom.equalTo(self.infoView.mas_bottom);
            make.height.mas_equalTo(@(54));
        }];
    }
}

#pragma mark - Private Methods
- (void)checkLoginState {
    LibraryLoginBean *loginBean = self.loginModel.loginBean;
    UIColor *mainColor = [UIColor colorWithHexStr:@[@"#64B74E",@"#FFBA13",@"#FF5100"][loginBean.returnDateLevel]];
    [self setMainColor:mainColor animated:YES];
    if (loginBean.days == 30000000) {
        [self.bookNumLabel setText:@"当前无借阅"];
    } else {
        [self.bookNumLabel setText:[NSString stringWithFormat:@"%ld天",(long)loginBean.days]];
    }
    [self.infoView removeGestureRecognizer:_gestureRecognizer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.infoTableView.numberOfSections == 2) {
            [self.infoTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            if ([self.infoTableView numberOfRowsInSection:0] == self.loginModel.borrowingArr.count) {
                [self.infoTableView reloadData];
            } else {
                [self.infoTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    });
    
}

#pragma mark - Respond Methods
- (void)beginRefreshing {
    [self.refreshControl beginRefreshing];
    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:3.0f];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)autoLogin {
//    User *currentUser = [UserCenter defaultCenter].currentUser;
//    NSString *account = currentUser.number ? : @"";
//    NSLog(@"account - %@",account);
    NSString *account = @"20154858";
    if (account.length) {
        NSString *password = [account substringFromIndex:2];
        self.loginModel.username = account;
        self.loginModel.password = password;
        [self.loginModel gotoLogin];
    } 
}

- (void)login {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.modalPresentationStyle = UIModalPresentationCustom;
    loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [loginVC setupWithTitle:@"登录图书馆" inputType:NEUInputTypeAccount|NEUInputTypePassword resultBlock:^(NSDictionary<NSNumber *,NSString *> *result, BOOL complete) {
        if (complete) {
            NSString *userName = result[@(NEUInputTypeAccount)]?:@"";
            NSString *password = result[@(NEUInputTypePassword)]?:@"";
            self.loginModel.username = userName;
            self.loginModel.password = password;
            [self.loginModel gotoLogin];
        } else {
            NSLog(@"no");
        }
    }];
    
    [self presentViewController:loginVC animated:YES completion:^{
        
    }];
}

- (void)searchBook {
    SearchLibraryViewController *searchVC = [[SearchLibraryViewController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)checkHistory {
    LibraryHistoryViewController *historyVC = [[LibraryHistoryViewController alloc] init];
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (void)recommendBook {
    LibraryRecommendViewController *recommendVC = [[LibraryRecommendViewController alloc] init];
    [self.navigationController pushViewController:recommendVC animated:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.loginModel.borrowingArr.count) {
        switch (indexPath.section) {
            case 0: {
                
            }
                break;
                
            case 1: {
                SearchLibraryResultViewController *resultVC = [[SearchLibraryResultViewController alloc] init];
                [resultVC.view setBackgroundColor:[UIColor whiteColor]];
                [resultVC searchWithKeyword:self.bookStrings[indexPath.row] scope:0];
                [self.navigationController pushViewController:resultVC animated:YES];
            }
                break;
                
            case 2: {
                SearchLibraryResultViewController *resultVC = [[SearchLibraryResultViewController alloc] init];
                [resultVC.view setBackgroundColor:[UIColor whiteColor]];
                [resultVC searchWithKeyword:self.mostStrings[indexPath.row] scope:0];
                [self.navigationController pushViewController:resultVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0: {
                SearchLibraryResultViewController *resultVC = [[SearchLibraryResultViewController alloc] init];
                [resultVC.view setBackgroundColor:[UIColor whiteColor]];
                [resultVC searchWithKeyword:self.bookStrings[indexPath.row] scope:0];
                [self.navigationController pushViewController:resultVC animated:YES];
            }
                break;
                
            case 1: {
                SearchLibraryResultViewController *resultVC = [[SearchLibraryResultViewController alloc] init];
                [resultVC.view setBackgroundColor:[UIColor whiteColor]];
                [resultVC searchWithKeyword:self.mostStrings[indexPath.row] scope:0];
                [self.navigationController pushViewController:resultVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomSectionHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kLibraryReturnConsumeHistoryHeaderViewId];
    if (!headerView) {
        headerView = [[CustomSectionHeaderFooterView alloc] initWithReuseIdentifier:kLibraryReturnConsumeHistoryHeaderViewId];
        headerView.contentView.backgroundColor = [UIColor whiteColor];
    }
    headerView.section = section;
    if (self.loginModel.borrowingArr.count) {
        switch (section) {
            case 0: {
                headerView.titleLabel.text = @"当前借阅";
                [headerView.actionButton setTitle:@"全部续借" forState:UIControlStateNormal];
            }
                break;
                
            case 1: {
                headerView.titleLabel.text = @"新书通报";
                [headerView.actionButton setTitle:@"查看全部" forState:UIControlStateNormal];
            }
                break;
                
            case 2: {
                headerView.titleLabel.text = @"热门排行";
                [headerView.actionButton setTitle:@"查看全部" forState:UIControlStateNormal];
            }
                break;
                
            default:
                break;
        }
        
        [headerView setPerformActionBlock:^(NSInteger section) {
            switch (section) {
                case 0: {
                    [self.loginModel allRenewal];
                }
                    break;
                    
                case 1: {
                    LibraryNewBookViewController *newbookVC = [[LibraryNewBookViewController alloc] init];
                    [self.navigationController pushViewController:newbookVC animated:YES];
                }
                    break;
                    
                case 2: {
                    LibraryMostViewController *mostVC =[[LibraryMostViewController alloc] init];
                    [self.navigationController pushViewController:mostVC animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }];
    } else {
        switch (section) {
            case 0: {
                headerView.titleLabel.text = @"新书通报";
                [headerView.actionButton setTitle:@"查看全部" forState:UIControlStateNormal];
            }
                break;
                
            case 1: {
                headerView.titleLabel.text = @"热门排行";
                [headerView.actionButton setTitle:@"查看全部" forState:UIControlStateNormal];
            }
                break;
                
            default:
                break;
        }
        
        [headerView setPerformActionBlock:^(NSInteger section) {
            switch (section) {
                case 0: {
                    LibraryNewBookViewController *newbookVC = [[LibraryNewBookViewController alloc] init];
                    [self.navigationController pushViewController:newbookVC animated:YES];
                }
                    break;
                    
                case 1: {
                    LibraryMostViewController *mostVC =[[LibraryMostViewController alloc] init];
                    [self.navigationController pushViewController:mostVC animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }];
    }
    
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.loginModel.borrowingArr.count) {
        if (indexPath.section == 0) {
            return 144;
        } else {
            return 44;
        }
    } else {
        return 44;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.loginModel.borrowingArr.count) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.loginModel.borrowingArr.count) {
        switch (section) {
            case 0:
                return self.loginModel.borrowingArr.count;
                break;
                
            case 1:
                return self.bookStrings.count;
                break;
                
            case 2:
                return self.mostStrings.count;
                break;
                
            default:
                break;
        }
    } else {
        switch (section) {
            case 0:
                return self.bookStrings.count;
                break;
                
            case 1:
                return self.mostStrings.count;
                break;
                
            default:
                break;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.loginModel.borrowingArr.count) {
        if (indexPath.section == 0) {
            LibraryReturnCell *cell = [tableView dequeueReusableCellWithIdentifier:kLibraryResultCellId];
            if (!cell) {
                cell = [[LibraryReturnCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLibraryResultCellId];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setButtonUserInteractionEnabled:_isButtonEnabled];
            if (self.loginModel.borrowingArr.count) {
                [cell setContent:self.loginModel.borrowingArr[indexPath.row]];
            }
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLibraryDefaultCellId];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLibraryDefaultCellId];
                cell.textLabel.textColor = [UIColor beautyBlue];
                cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
            }
            if (indexPath.section == 1) {
                cell.textLabel.text = self.bookStrings[indexPath.row];
            } else {
                cell.textLabel.text = self.mostStrings[indexPath.row];
            }
            
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLibraryDefaultCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLibraryDefaultCellId];
            cell.textLabel.textColor = [UIColor beautyBlue];
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        }
        if (indexPath.section == 1) {
            cell.textLabel.text = self.bookStrings[indexPath.row];
        } else {
            cell.textLabel.text = self.mostStrings[indexPath.row];
        }
        
        return cell;
    }
}

#pragma mark - SearchLibraryBorrowingDelegate
#pragma mark - SearchLibraryNewBookDelegate
- (void)searchDidSuccess {
    if (self.newbookModel.resultArray.count && self.mostModel.resultArray.count) {
        NSMutableArray *newbookArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 6; i++) {
            [newbookArr addObject:self.newbookModel.resultArray[i].title];
        }

        NSMutableArray *mostArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 6; i++) {
            [mostArr addObject:self.mostModel.resultArray[i].title];
        }
        
        self.bookStrings = newbookArr;
        self.mostStrings = mostArr;
        [self.infoTableView reloadData];

    }
}

- (void)searchDidFail:(NSString *)message {
    
}

#pragma mark - LibraryLoginDelegate
- (void)loginDidSuccess {
    [self checkLoginState];
}

- (void)allRenewal:(NSArray *)info {
    _isButtonEnabled = NO;
    [self.infoTableView reloadData];
    for (NSString *str in info) {
        NSLog(@"%@",str);
    }
}


#pragma mark - Getter
- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (UIBarButtonItem *)loginButtonItem {
    if (!_loginButtonItem) {
        _loginButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(login)];
    }
    return _loginButtonItem;
}

- (UIView *)infoView {
    if (!_infoView) {
        _infoView = [[UIView alloc] init];
        _infoView.layer.borderWidth = 1.0f;
        _infoView.layer.cornerRadius = 8.0f;
        _infoView.userInteractionEnabled = YES;
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login)];
        _gestureRecognizer.numberOfTapsRequired = 1;
        [_infoView addGestureRecognizer:_gestureRecognizer];
    }
    return _infoView;
}

- (UILabel *)bookNumLabel {
    if (!_bookNumLabel) {
        _bookNumLabel = [[UILabel alloc] init];
        _bookNumLabel.font = [UIFont systemFontOfSize:48.0 weight:UIFontWeightLight];
        _bookNumLabel.text = @"点击登录";
        [self.infoView addSubview:_bookNumLabel];
    }
    return _bookNumLabel;
}

- (UILabel *)bookNumInfoLabel {
    if (!_bookNumInfoLabel) {
        _bookNumInfoLabel = [[UILabel alloc] init];
        _bookNumInfoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _bookNumInfoLabel.text = @"距还书日期";
        [self.infoView addSubview:_bookNumInfoLabel];
    }
   return _bookNumInfoLabel;
}

- (NSArray<UIButton *> *)infoViewBtns {
    if (!_infoViewBtns) {
        UIButton *searchButton = [[UIButton alloc] init];
        [searchButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [searchButton setTitle:@"书刊查询" forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(searchBook) forControlEvents:UIControlEventTouchUpInside];
        [self.infoView addSubview:searchButton];
        
        UIButton *changePasswordButton = [[UIButton alloc] init];
        [changePasswordButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [changePasswordButton setTitle:@"借阅历史" forState:UIControlStateNormal];
        [changePasswordButton addTarget:self action:@selector(checkHistory) forControlEvents:UIControlEventTouchUpInside];
        [self.infoView addSubview:changePasswordButton];
        
        UIButton *reportLostButton = [[UIButton alloc] init];
        [reportLostButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [reportLostButton setTitle:@"荐购新书" forState:UIControlStateNormal];
        [reportLostButton addTarget:self action:@selector(recommendBook) forControlEvents:UIControlEventTouchUpInside];
        [self.infoView addSubview:reportLostButton];
        
        
        _infoViewBtns = @[searchButton, changePasswordButton, reportLostButton];
    }
   return _infoViewBtns;
}

- (UITableView *)infoTableView {
    if (!_infoTableView) {
        _infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _infoTableView.dataSource = self;
        _infoTableView.delegate = self;
        _infoView.backgroundColor = [UIColor clearColor];
        _infoTableView.showsVerticalScrollIndicator = NO;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_WIDTH_ACTUAL*9.0f/16.0f)];
        [headerView addSubview:self.infoView];
        [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(headerView);
            make.width.mas_equalTo(@(SCREEN_WIDTH_ACTUAL-32));
            make.height.mas_equalTo(@((SCREEN_WIDTH_ACTUAL-32)*9.0f/16.0f));
        }];
        [headerView layoutIfNeeded];
        
        _infoTableView.tableHeaderView = headerView;
        _infoTableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_infoTableView];
    }
    return _infoTableView;
}

//model
- (SearchLibraryNewBookModel *)newbookModel {
    if (!_newbookModel) {
        _newbookModel = [[SearchLibraryNewBookModel alloc] init];
        _newbookModel.languageType = @"ALL";
        _newbookModel.sortType = @"ALL";
        _newbookModel.date = @"180";
        _newbookModel.delegate = self;
    }
    return _newbookModel;
}

- (SearchLibraryBorrowingModel *)mostModel {
    if (!_mostModel) {
        _mostModel = [[SearchLibraryBorrowingModel alloc] init];
        _mostModel.languageType = @"ALL";
        _mostModel.sortType = @"ALL";
        _mostModel.date = @"y";
        _mostModel.delegate = self;
    }
    return _mostModel;
}

- (LibraryLoginModel *)loginModel {
    if (!_loginModel) {
        _loginModel = [LibraryCenter defaultCenter].currentModel;
        _loginModel.delegate = self;
    }
    return _loginModel;
}

- (NSArray<NSString *> *)bookStrings {
   if (!_bookStrings) {
       _bookStrings = [[NSArray alloc] init];
    }
   return _bookStrings;
}

- (NSArray<NSString *> *)mostStrings {
    if (!_mostStrings) {
        _mostStrings = [[NSArray alloc] init];
    }
    return _mostStrings;
}


#pragma mark - Setter
- (void)setMainColor:(UIColor *)color animated:(BOOL)animated{
    NSTimeInterval interval = animated ? 0.3f : 0;
    
    [UIView animateWithDuration:interval animations:^{
        self.infoView.layer.borderColor = color.CGColor;
        self.infoView.backgroundColor = [color colorWithAlphaComponent:0.1];
        self.bookNumLabel.textColor = color;
        self.bookNumInfoLabel.textColor = color;
        for (UIButton *button in self.infoViewBtns) {
            [button setTitleColor:color forState:UIControlStateNormal];
            [button setTitleColor:[color colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        }
    }];
}
@end

@interface LibraryReturnCell () <LibraryLoginDelegate>

@end

@implementation LibraryReturnCell
#pragma mark - Init Methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.right.equalTo(self.contentView.mas_right);
        make.top.equalTo(self.contentView.mas_top).with.offset(16);
    }];
    
    [self.returndateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).with.offset(-14);
        make.left.equalTo(self.titleLabel);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.titleLabel);
    }];
    
    [self.refurbishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(72);
        make.right.equalTo(self.contentView).with.offset(-16);
        make.bottom.equalTo(self.returndateLabel);
    }];
}

#pragma mark - Respond Methods
- (void)partRenewal {
    [self.loginModel partRenewalWithBean:_borrowingBean];
}

#pragma mark - LibraryLoginDelegate
- (void)partRenewalDidSuccess {
    [self.refurbishBtn setTitle:@"已续借" forState:UIControlStateNormal];
    [self.refurbishBtn.titleLabel setAlpha:0.5];
    [self.refurbishBtn setUserInteractionEnabled:NO];
}

- (void)partRenewalDidFail:(NSString *)errorMessage {
    [self.refurbishBtn setTitle:@"已续借" forState:UIControlStateNormal];
    [self.refurbishBtn.titleLabel setAlpha:0.5];
    [self.refurbishBtn setUserInteractionEnabled:NO];
    NSLog(@"%@",errorMessage);
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
       _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _titleLabel.numberOfLines = 2;
       [self.contentView addSubview:_titleLabel];
    }
   return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [UIColor grayColor];
        _infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _infoLabel.numberOfLines = 1;
        [self.contentView addSubview:_infoLabel];
    }
   return _infoLabel;
}

- (UILabel *)returndateLabel {
    if (!_returndateLabel) {
        _returndateLabel = [[UILabel alloc] init];
        _returndateLabel.textColor = [UIColor grayColor];
        _returndateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _returndateLabel.numberOfLines = 1;
        [self.contentView addSubview:_returndateLabel];
    }
   return _returndateLabel;
}

- (UIButton *)refurbishBtn {
    if (!_refurbishBtn) {
        _refurbishBtn = [[UIButton alloc] init];
        _refurbishBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _refurbishBtn.layer.cornerRadius = 15;
        _refurbishBtn.layer.borderColor = [UIColor beautyBlue].CGColor;
        _refurbishBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_refurbishBtn setTitle:@"续借" forState:UIControlStateNormal];
        [_refurbishBtn setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
        [_refurbishBtn addTarget:self action:@selector(partRenewal) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_refurbishBtn];
    }
   return _refurbishBtn;
}

- (LibraryLoginModel *)loginModel {
    if (!_loginModel) {
        _loginModel = [LibraryCenter defaultCenter].currentModel;
        _loginModel.delegate = self;
    }
    return _loginModel;
}

#pragma mark - Setter
- (void)setContent:(LibraryLoginMyInfoBorrowingBean *)bean {
    _borrowingBean = bean;
    self.titleLabel.text = bean.title;
    NSString *year = [bean.shouldReturnDate substringToIndex:4];
    NSString *month = [[bean.shouldReturnDate substringFromIndex:4] substringToIndex:2];
    NSString *day = [[bean.shouldReturnDate substringFromIndex:6] substringToIndex:2];
    self.returndateLabel.text = [NSString stringWithFormat:@"%@/%@/%@前归还",year,month,day];
    self.infoLabel.text = ({
        NSString *info = @"";
        if (bean.author.length>0&&bean.claimNumber.length>0) {
            info = [NSString stringWithFormat:@"%@ %@", bean.author, bean.claimNumber];
        } else {
            info = [NSString stringWithFormat:@"%@%@", bean.author, bean.claimNumber];
        }
        info;
    });
    if (bean.returnDateLevel == LibraryInfoReturnDateLevelHigh) {
        [self setMainColor:[UIColor beautyRed]];
    }
}

- (void)setMainColor:(UIColor *)color {
    self.titleLabel.textColor = color;
    self.returndateLabel.textColor = color;
    self.infoLabel.textColor = color;
}

- (void)setButtonUserInteractionEnabled:(BOOL)enabled {
    if (!enabled) {
        [self.refurbishBtn setTitle:@"已续借" forState:UIControlStateNormal];
        [self.refurbishBtn.titleLabel setAlpha:0.5];
        [self.refurbishBtn setUserInteractionEnabled:NO];
    }
}

@end
