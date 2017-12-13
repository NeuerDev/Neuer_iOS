//
//  AaoStudentScoreViewController.m
//  NEUer
//
//  Created by lanya on 2017/12/7.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoStudentScoreViewController.h"
#import "AaoModel.h"
#import "LoginViewController.h"

static NSString * const kAaoComponentScoreHeaderFooterView = @"kAaoComponentScoreHeaderFooterView";
static NSString * const kAaoComponentScoreCellReusableId = @"kAaoComponentScoreCellReusableId";

@interface AaoComponentScoreCell : UITableViewCell

@property (nonatomic, strong) AaoStudentScoreBean *bean;
@property (nonatomic, strong) UILabel *creditLabel;
@property (nonatomic, strong) UILabel *dailyScoreLabel;
@property (nonatomic, strong) UILabel *midScoreLabel;
@property (nonatomic, strong) UILabel *finalScoreLabel;

@end
@implementation AaoComponentScoreCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    [self.creditLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16 + 16 + 8);
        make.top.equalTo(self.contentView.mas_top).with.offset(8);
    }];
    [self.dailyScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.creditLabel);
        make.top.equalTo(self.creditLabel.mas_bottom).with.offset(8);
    }];
    [self.midScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.creditLabel);
        make.top.equalTo(self.dailyScoreLabel.mas_bottom).with.offset(8);
    }];
    [self.finalScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.creditLabel);
        make.top.equalTo(self.midScoreLabel.mas_bottom).with.offset(8);
    }];
}

- (void)setBean:(AaoStudentScoreBean *)bean {
    
    _bean = bean;
    
    self.creditLabel.text = [NSString stringWithFormat:@"学分：%@", bean.score_credit];
    self.dailyScoreLabel.text = [NSString stringWithFormat:@"平时成绩：%@", bean.score_dailyScore];
    self.midScoreLabel.text = [NSString stringWithFormat:@"期中成绩：%@", bean.score_midtermScore];
    self.finalScoreLabel.text = [NSString stringWithFormat:@"期末成绩：%@", bean.score_finalScore];
}

#pragma mark - Getter

- (UILabel *)creditLabel {
    if (!_creditLabel) {
        _creditLabel = [[UILabel alloc] init];
        _creditLabel.textAlignment = NSTextAlignmentCenter;
        _creditLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _creditLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_creditLabel];
    }
    return _creditLabel;
}

- (UILabel *)midScoreLabel {
    if (!_midScoreLabel) {
        _midScoreLabel = [[UILabel alloc] init];
        _midScoreLabel.textAlignment = NSTextAlignmentCenter;
        _midScoreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _midScoreLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_midScoreLabel];
    }
    return _midScoreLabel;
}

- (UILabel *)finalScoreLabel {
    if (!_finalScoreLabel) {
        _finalScoreLabel = [[UILabel alloc] init];
        _finalScoreLabel.textAlignment = NSTextAlignmentCenter;
        _finalScoreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _finalScoreLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_finalScoreLabel];
    }
    return _finalScoreLabel;
}

- (UILabel *)dailyScoreLabel {
    if (!_dailyScoreLabel) {
        _dailyScoreLabel = [[UILabel alloc] init];
        _dailyScoreLabel.textAlignment = NSTextAlignmentCenter;
        _dailyScoreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _dailyScoreLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_dailyScoreLabel];
    }
    return _dailyScoreLabel;
}


@end

typedef void(^AaoComponentScoreHeaderFooterViewPerformActionBlock)(NSInteger section);

@interface AaoComponentScoreHeaderFooterView : UITableViewHeaderFooterView
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) AaoComponentScoreHeaderFooterViewPerformActionBlock performBlock;

@end
@implementation AaoComponentScoreHeaderFooterView
{
    BOOL _flag;
}

#pragma mark - Init


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initData];
        [self initConstraints];
    }
    return self;
    
}

- (void)initData {
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedHeaderView)]];
}


- (void)initConstraints {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(16);
        make.centerY.equalTo(self);
        make.height.and.width.equalTo(@16);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).with.offset(8);
        make.centerY.equalTo(self.iconImageView);
    }];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-16);
        make.centerY.equalTo(self.iconImageView);
    }];
}

#pragma mark - Response Method

- (void)didClickedHeaderView {
    if (_performBlock) {
        _performBlock(_section);
    }
    
    if (!_flag) {
        _flag = !_flag;
        self.iconImageView.image = [UIImage imageNamed:@"aao_score_open"];
    } else {
        self.iconImageView.image = [UIImage imageNamed:@"aao_score_close"];
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)scoreLabel {
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] init];
        _scoreLabel.textAlignment = NSTextAlignmentCenter;
        _scoreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _scoreLabel.textColor = [UIColor blackColor];
        [self addSubview:_scoreLabel];
    }
    return _scoreLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aao_score_close"]];
        _flag = NO;
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

@end

@interface AaoComponentScoreTableViewHeaderView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *scoreLabel;

@end
@implementation AaoComponentScoreTableViewHeaderView

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(16);
        make.centerY.equalTo(self);
    }];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).with.offset(-16);
    }];
    
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = @"课程名称";
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)scoreLabel {
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] init];
        _scoreLabel.textAlignment = NSTextAlignmentCenter;
        _scoreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        _scoreLabel.textColor = [UIColor blackColor];
        _scoreLabel.text = @"总成绩";
        [self addSubview:_scoreLabel];
    }
    return _scoreLabel;
}

@end


@interface AaoComponentScoreView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray <AaoStudentScoreBean *>*scoreArray;
@property (nonatomic, strong) NSMutableArray <NSNumber *> *openedArray;
@property (nonatomic, strong) AaoComponentScoreHeaderFooterView *headerView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AaoComponentScoreView

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        
        [self initData];
        [self initConstraints];
    }
    return self;
}

- (void)initData {
    _scoreArray = @[];
    _openedArray = @[].mutableCopy;
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.scoreArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    for (NSNumber *number in self.openedArray) {
        if (section == [number integerValue]) {
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AaoComponentScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kAaoComponentScoreCellReusableId];
    if (!cell) {
        cell = [[AaoComponentScoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAaoComponentScoreCellReusableId];
    }
    cell.bean = self.scoreArray[indexPath.section];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    _headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kAaoComponentScoreHeaderFooterView];
    
    if (!_headerView) {
        _headerView = [[AaoComponentScoreHeaderFooterView alloc] init];
    }
    
    _headerView.titleLabel.text = self.scoreArray[section].score_name;
    _headerView.scoreLabel.text = self.scoreArray[section].score_totalScore;
    _headerView.section = section;
    WS(ws);
    
    [_headerView setPerformBlock:^(NSInteger section) {
        BOOL flag = NO;
        for (NSNumber *number in ws.openedArray) {
            if (section == [number integerValue]) {
                flag = YES;
            }
        }
        
        if (!flag) {
            [ws.openedArray addObject:@(section)];
            [ws.tableView reloadData];
        } else {
            [ws.openedArray removeObject:@(section)];
            [ws.tableView reloadData];
        }
        
    }];
    
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 44.0)];
        AaoComponentScoreTableViewHeaderView *tableHeaderView = [[AaoComponentScoreTableViewHeaderView alloc] init];
        [headerView addSubview:tableHeaderView];
        [tableHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(headerView);
        }];
        [headerView layoutIfNeeded];
        
        _tableView.tableHeaderView = headerView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self addSubview:_tableView];
    }
    return _tableView;
}

@end

@interface AaoStudentScoreViewController ()
@property (nonatomic, strong) UIBarButtonItem *changeTypeBarButtonItem;
@property (nonatomic, strong) AaoComponentScoreView *scoreView;

@end

@implementation AaoStudentScoreViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initData {
    self.title = @"成绩查询";
    self.navigationItem.rightBarButtonItem = self.changeTypeBarButtonItem;
    [self showAlert];
}

- (void)initConstraints {
    [self.scoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view layoutIfNeeded];
}

#pragma mark - Response Method

- (void)showAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"查询成绩需要您的二次登陆，点击登录进行查询" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showLoginBoxWithQueryType:1];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showLoginBoxWithQueryType:(AaoAtionQueryType)queryType {
    User *user = [UserCenter defaultCenter].currentUser;
    NSString *account = user.number ? : @"";
    NSString *password = [user.keychain passwordForKeyType:UserKeyTypeAAO] ? : @"";
    
    WS(ws);
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.modalPresentationStyle = UIModalPresentationCustom;
    loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [loginVC setupWithTitle:@"欢迎进行成绩查询" inputType:NEUInputTypeAccount | NEUInputTypePassword | NEUInputTypeVerifyCode
                   contents:@{
                              @(NEUInputTypeAccount) : account,
                              @(NEUInputTypePassword) : password
                              } resultBlock:^(NSDictionary<NSNumber *,NSString *> *result, BOOL complete) {
                                   if (complete) {
                                       NSString *number = [result objectForKey:@(NEUInputTypeAccount)];
                                       NSString *password = [result objectForKey:@(NEUInputTypePassword)];
                                       NSString *verifycode = [result objectForKey:@(NEUInputTypeVerifyCode)];
                                       [ws loginWithUserNumber:number password:password verifycode:verifycode queryType:queryType];
                                   }
    }];
    
    [self presentViewController:loginVC animated:YES completion:^{
        [ws.model getVerifyImage:^(BOOL success, UIImage *verifyImage) {
            if (success) {
                [loginVC setVerifyImage:verifyImage];
            }
        }];
    }];
    
    __weak LoginViewController *weakLoginVC = loginVC;
    loginVC.changeVerifyImageBlock = ^{
        [ws.model getVerifyImage:^(BOOL success, UIImage *verifyImage) {
            if (success) {
                weakLoginVC.verifyImage = verifyImage;
            }
        }];
    };
}

- (void)loginWithUserNumber:(NSString *)number password:(NSString *)password verifycode:(NSString *)verifycode queryType:(AaoAtionQueryType)queryType {
    WS(ws);
    [self.model authorUser:number password:password verifyCode:verifycode queryType:queryType callBack:^(BOOL success, NSString *message) {
        if (success) {
            [[UserCenter defaultCenter] setAccount:number password:password forKeyType:UserKeyTypeAAO];
            
            ws.scoreView.scoreArray = ws.model.scoreInfoArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                ws.scoreView.scoreArray = ws.model.scoreInfoArray;
                [ws.scoreView.tableView reloadData];
            });
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [ws showLoginBoxWithQueryType:0];
            }]];
            
            [ws presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

- (void)didClickedChangeTypeBarButtonItem {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择学期类型" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    WS(ws);
    for (NSDictionary *dic in self.model.scoreTypeArray) {
        [alertController addAction:[UIAlertAction actionWithTitle:[dic allKeys].firstObject style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws.model setCurrentTermTypeWithName:[dic allKeys].firstObject];
            [ws.changeTypeBarButtonItem setTitle:[dic allKeys].firstObject];
            [ws.model queryStudentScoreWithTermType:[[dic allValues].firstObject integerValue] Block:^(BOOL success, NSString *message) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ws.scoreView.scoreArray = ws.model.scoreInfoArray;
                        [ws.scoreView.openedArray removeAllObjects];
                        [ws.scoreView.tableView reloadData];
                    });
                } else {
                    NSLog(@"获取失败");
                }
            }];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - Getter

- (UIBarButtonItem *)changeTypeBarButtonItem {
    if (!_changeTypeBarButtonItem) {
        _changeTypeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"当前学期" style:UIBarButtonItemStyleDone target:self action:@selector(didClickedChangeTypeBarButtonItem)];
    }
    return _changeTypeBarButtonItem;
}

- (AaoComponentScoreView *)scoreView {
    if (!_scoreView) {
        _scoreView = [[AaoComponentScoreView alloc] init];
        [self.view addSubview:_scoreView];
    }
    return _scoreView;
}

@end
