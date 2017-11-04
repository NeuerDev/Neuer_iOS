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

#import "SearchListComponent.h"

#import "SearchLibraryNewBookModel.h"
#import "SearchLibraryBorrowingModel.h"
#import "LibraryLoginModel.h"
#import "LibraryLoginMyInfoModel.h"


@interface LibraryViewController () <SearchListComponentDelegate,SearchLibraryNewBookDelegate,SearchLibraryBorrowingDelegate,UITableViewDelegate,UITableViewDataSource>
//信息
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIBarButtonItem *loginButtonItem;
@property (nonatomic, strong) UITableView *infoTableView;
@property (nonatomic, strong) UIView *infoView;
//新书和热门
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) SearchListComponent *newbookSearchComponent;
@property (nonatomic, strong) SearchListComponent *mostSearchComponent;

@property (nonatomic, strong) SearchLibraryNewBookModel *newbookModel;
@property (nonatomic, strong) SearchLibraryBorrowingModel *mostModel;
@property (nonatomic, strong) LibraryLoginModel *loginModel;
@property (nonatomic, strong) LibraryLoginMyInfoModel *infoModel;


@end

@implementation LibraryViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
    
}

#pragma mark - Init Methods
- (void)initData {
    [self setTitle:@"图书馆"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.scrollView.refreshControl = self.refreshControl;
    self.navigationItem.rightBarButtonItem = self.loginButtonItem;
    [self.newbookModel search];
    [self.mostModel search];
}

- (void)initConstraints {
    self.scrollView.frame = self.view.frame;
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.infoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(SCREEN_WIDTH_ACTUAL*0.5);
    }];
    
    [self.newbookSearchComponent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.infoTableView.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
        make.height.mas_equalTo(20 * 44);
    }];
    
    [self.mostSearchComponent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.newbookSearchComponent.view.mas_bottom);
        make.bottom.and.left.and.right.equalTo(self.contentView);
    }];
}

#pragma mark - Respond Methods
- (void)beginRefreshing {
    [self.refreshControl beginRefreshing];
    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:3.0f];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)login {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.modalPresentationStyle = UIModalPresentationCustom;
    loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [loginVC setupWithTitle:@"登录图书馆" inputType:LoginInputTypeAccount|LoginInputTypePassword resultBlock:^(NSDictionary<NSNumber *,NSString *> *result, BOOL complete) {
        if (complete) {
            NSLog(@"yes");
        } else {
            NSLog(@"no");
        }
    }];
    
    [self presentViewController:loginVC animated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

#pragma mark - SearchListComponentDelegate
- (void)component:(SearchListComponent *)component didSelectedString:(NSString *)string {
    SearchLibraryResultViewController *resultVC = [[SearchLibraryResultViewController alloc] init];
    [resultVC.view setBackgroundColor:[UIColor whiteColor]];
    [resultVC searchWithKeyword:string scope:0];
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (void)component:(SearchListComponent *)component willPerformAction:(NSString *)action {
    if (component.view.tag == 101) {
        LibraryNewBookViewController *newbookVC = [[LibraryNewBookViewController alloc] init];
        [self.navigationController pushViewController:newbookVC animated:YES];
    } else {
        LibraryMostViewController *mostVC =[[LibraryMostViewController alloc] init];
        [self.navigationController pushViewController:mostVC animated:YES];
    }
}

#pragma mark - SearchLibraryBorrowingDelegate
#pragma mark - SearchLibraryNewBookDelegate
- (void)searchDidSuccess {
    if (self.newbookModel.resultArray.count && self.mostModel.resultArray.count) {
        NSMutableArray *newbookArr = [NSMutableArray array];
        for (SearchLibraryNewBookBean *bean in self.newbookModel.resultArray) {
            [newbookArr addObject:bean.title];
        }
        
        NSMutableArray *mostArr = [NSMutableArray array];
        for (SearchLibraryBorrowingBean *bean in self.mostModel.resultArray) {
            [mostArr addObject:bean.title];
        }
        
        self.newbookSearchComponent.strings = newbookArr;
        self.mostSearchComponent.strings = mostArr;
    }
}

- (void)searchDidFail:(NSString *)message {
    
}


#pragma mark - Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self.scrollView addSubview:_contentView];
    }
    return _contentView;
}

- (SearchListComponent *)newbookSearchComponent {
    if (!_newbookSearchComponent) {
        _newbookSearchComponent = [[SearchListComponent alloc] initWithTitle:@"新书通报" action:@"查看全部"];
        _newbookSearchComponent.delegate = self;
        _newbookSearchComponent.view.tag = 101;
        [self.contentView addSubview:_newbookSearchComponent.view];
    }
    return _newbookSearchComponent;
}

- (SearchListComponent *)mostSearchComponent {
    if (!_mostSearchComponent) {
        _mostSearchComponent = [[SearchListComponent alloc] initWithTitle:@"热门排行" action:@"查看全部"];
        _mostSearchComponent.delegate = self;
        _mostSearchComponent.view.tag = 102;
        [self.contentView addSubview:_mostSearchComponent.view];
    }
    return _mostSearchComponent;
}

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

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
    }
   return _refreshControl;
}

- (UIBarButtonItem *)loginButtonItem {
    if (!_loginButtonItem) {
        _loginButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStylePlain target:self action:@selector(login)];
    }
   return _loginButtonItem;
}

- (LibraryLoginModel *)loginModel {
    if (!_loginModel) {
        _loginModel = [[LibraryLoginModel alloc] init];
    }
   return _loginModel;
}

- (LibraryLoginMyInfoModel *)infoModel {
    if (!_infoModel) {
        _infoModel = [[LibraryLoginMyInfoModel alloc] init];
    }
   return _infoModel;
}

- (UITableView *)infoTableView {
    if (!_infoTableView) {
        _infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _infoTableView.dataSource = self;
        _infoTableView.delegate = self;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_WIDTH_ACTUAL*0.5)];
        [headerView addSubview:self.infoView];
        [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(headerView);
            make.width.mas_equalTo(@(SCREEN_WIDTH_ACTUAL-32));
            make.height.mas_equalTo(@((SCREEN_WIDTH_ACTUAL-32)*0.5));
        }];
        [headerView layoutIfNeeded];
        
        _infoTableView.tableHeaderView = headerView;
        _infoTableView.tableFooterView = [[UIView alloc] init];
        [self.contentView addSubview:_infoTableView];
    }
   return _infoTableView;
}

- (UIView *)infoView {
    if (!_infoView) {
        _infoView = [[UIView alloc] init];
        _infoView.layer.borderWidth = 1.0f;
        _infoView.layer.cornerRadius = 8.0f;
        //@[@"#9C9C9C",@"#64B74E",@"#FFBA13",@"#FF5100"]
        UIColor *mainColor = [UIColor colorWithHexStr:@"#9C9C9C"];
        _infoView.layer.borderColor = mainColor.CGColor;
        _infoView.backgroundColor = [mainColor colorWithAlphaComponent:0.1];
        _infoView.userInteractionEnabled = YES;
    }
   return _infoView;
}

@end
