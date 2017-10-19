//
//  EcardViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardMainViewController.h"
#import "EcardMyViewController.h"
#import "EcardModel.h"

#import "CustomSectionHeaderFooterView.h"

static NSString * const kEcardCustomHeaderViewId = @"kEcardCustomHeaderViewId";
static NSString * const kEcardConsumeHistoryCellId = @"kEcardConsumeHistoryCellId";

@interface EcardTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *moneyLabel;

@property (nonatomic, strong) EcardConsumeBean *consumeBean;

@end

@implementation EcardTableViewCell

#pragma mark - Init Methods

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initConstraints];
        
        self.separatorInset = UIEdgeInsetsMake(0, 72, 0, 16);
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)initConstraints {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.mas_equalTo(@(48));
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
    }];
    
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).with.offset(8);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.height.mas_greaterThanOrEqualTo(self.iconImageView.mas_height).multipliedBy(0.8).priorityHigh();
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(self.infoView);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_greaterThanOrEqualTo(self.titleLabel.mas_bottom).priorityLow();
        make.left.and.bottom.equalTo(self.infoView);
    }];
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.centerY.equalTo(self.infoView);
    }];
}

#pragma mark - Setter

- (void)setConsumeBean:(EcardConsumeBean *)consumeBean {
    _consumeBean = consumeBean;
    _titleLabel.text = consumeBean.title;
    _timeLabel.text = consumeBean.time;
    _moneyLabel.text = [NSString stringWithFormat:@"%.2f", consumeBean.cost.floatValue];
    
    _iconImageView.image = [UIImage imageNamed:@[@"", @"ecard_bath", @"ecard_food"][consumeBean.consumeType]];
//    _titleLabel.textColor = [UIColor colorWithHexStr:@[@"#FFFFFF", @"#91BBF2", @"#DE8753"][consumeBean.consumeType]];
//    _moneyLabel.textColor = [UIColor colorWithHexStr:@[@"#FFFFFF", @"#91BBF2", @"#DE8753"][consumeBean.consumeType]];
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_iconImageView];
    }
    
    return _iconImageView;
}

- (UIView *)infoView {
    if (!_infoView) {
        _infoView = [[UIView alloc] init];
        [self.contentView addSubview:_infoView];
    }
    
    return _infoView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.infoView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.numberOfLines = 0;
        _timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _timeLabel.textColor = [UIColor lightGrayColor];
        [self.infoView addSubview:_timeLabel];
    }
    
    return _timeLabel;
}

- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [self.infoView addSubview:_moneyLabel];
    }
    
    return _moneyLabel;
}

@end

@interface EcardMainViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) EcardModel *ecardModel;

@property (nonatomic, strong) UIView *balanceView;
@property (nonatomic, strong) UILabel *balanceValueLabel;
@property (nonatomic, strong) UILabel *balanceInfoLabel;

@property (nonatomic, strong) NSArray<UIButton *> *balanceViewButtons;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UITableView *cardTableView;

@property (nonatomic, strong) UIBarButtonItem *changePasswordButtonItem;

@property (nonatomic, strong) NSArray<NSDictionary *> *sectionDataArray;
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
//    self.navigationItem.rightBarButtonItem = self.changePasswordButtonItem;
//    self.cardTableView.refreshControl = self.refreshControl;
    [self initConstraints];
    [self setMainColor:[UIColor colorWithHexStr:@"#64B74E"] animated:NO];
//    [self test];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)test {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 300, 200, 50)];
    imageView.backgroundColor = [UIColor beautyBlue];
    [self.view addSubview:imageView];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 350, 200, 50)];
    _textField.backgroundColor = [UIColor beautyPurple];
    [self.view addSubview:_textField];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 400, 200, 50)];
    button.backgroundColor = [UIColor beautyGreen];
    [button setTitle:@"login" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self.ecardModel getVerifyImage:^(UIImage *verifyImage, NSString *message) {
        imageView.image = verifyImage;
    }];
}

- (void)initConstraints {

    [self.cardTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.and.right.and.bottom.equalTo(self.view);
    }];
    
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
    
}

- (void)beginRefreshing {
    NSLog(@"refresh");
    [self.refreshControl beginRefreshing];
    [self performSelector:@selector(endRefreshing) withObject:nil afterDelay:3.0f];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

#pragma mark - Private Methods

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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

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
    EcardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEcardConsumeHistoryCellId];
    if (!cell) {
        cell = [[EcardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEcardConsumeHistoryCellId];
    }
    
    EcardConsumeBean *consumeBean0 = [[EcardConsumeBean alloc] init];
    consumeBean0.title = @"手抓饼(浑南三楼79#)";
    consumeBean0.consumeType = EcardConsumeTypeFood;
    consumeBean0.time = @"19:01";
    consumeBean0.cost = [NSNumber numberWithInteger:-8.00];
    
    EcardConsumeBean *consumeBean1 = [[EcardConsumeBean alloc] init];
    consumeBean1.title = @"沐浴(浑南二楼1#)";
    consumeBean1.consumeType = EcardConsumeTypeBath;
    consumeBean1.time = @"20:01";
    consumeBean1.cost = [NSNumber numberWithInteger:-3.50];
    
    if (indexPath.row == 0) {
        cell.consumeBean = consumeBean1;
    } else {
        cell.consumeBean = consumeBean0;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomSectionHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kEcardCustomHeaderViewId];
    if (!headerView) {
        headerView = [[CustomSectionHeaderFooterView alloc] initWithReuseIdentifier:kEcardCustomHeaderViewId];
    }
    
    headerView.section = section;
    headerView.titleLabel.text = @"今日消费";
    [headerView.actionButton setTitle:@"历史账单" forState:UIControlStateNormal];
    [headerView setPerformActionBlock:^(NSInteger section) {
        
    }];
//    [headerView.actionButton setTitle:@"历史账单" forState:UIControlStateNormal];
    [headerView setPerformActionBlock:^(NSInteger section) {
        switch (section) {
            case 0:
                NSLog(@"more");
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

- (UIView *)balanceView {
    if (!_balanceView) {
        _balanceView = [[UIView alloc] init];
        _balanceView.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
        _balanceView.layer.borderWidth = 1.0f;
        _balanceView.layer.cornerRadius = 8.0f;
        _balanceView.layer.borderColor = [UIColor grayColor].CGColor;
        _balanceView.userInteractionEnabled = YES;
        [_balanceView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMyCard)]];
    }
    
    return _balanceView;
}

- (UILabel *)balanceValueLabel {
    if (!_balanceValueLabel) {
        _balanceValueLabel = [[UILabel alloc] init];
        _balanceValueLabel.font = [UIFont systemFontOfSize:48.0 weight:UIFontWeightLight];
        _balanceValueLabel.text = @"123.45";
        _balanceValueLabel.textColor = [UIColor colorWithHexStr:@"#64B74E"];
        [self.balanceView addSubview:_balanceValueLabel];
    }
    
    return _balanceValueLabel;
}

- (UILabel *)balanceInfoLabel {
    if (!_balanceInfoLabel) {
        _balanceInfoLabel = [[UILabel alloc] init];
        _balanceInfoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _balanceInfoLabel.text = @"余额充足 今天09:35更新";
        _balanceInfoLabel.textColor = [UIColor colorWithHexStr:@"#64B74E"];
        [self.balanceView addSubview:_balanceInfoLabel];
    }
    
    return _balanceInfoLabel;
}

- (UITableView *)cardTableView {
    if (!_cardTableView) {
        _cardTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _cardTableView.delegate = self;
        _cardTableView.dataSource = self;
        _cardTableView.showsVerticalScrollIndicator = NO;
        _cardTableView.allowsSelection = NO;
        _cardTableView.backgroundColor = [UIColor whiteColor];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_WIDTH_ACTUAL*0.5)];
        [headerView addSubview:self.balanceView];
        [self.balanceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(headerView);
            make.width.mas_equalTo(@(SCREEN_WIDTH_ACTUAL-32));
            make.height.mas_equalTo(@((SCREEN_WIDTH_ACTUAL-32)*0.5));
        }];
        [headerView layoutIfNeeded];
        _cardTableView.tableHeaderView = headerView;
        _cardTableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_cardTableView];
    }
    
    return _cardTableView;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
    }
    
    return _refreshControl;
}

- (NSArray<NSDictionary *> *)sectionDataArray {
    if (!_sectionDataArray) {
        _sectionDataArray = @[
                              ];
    }
    
    return _sectionDataArray;
}

- (UIBarButtonItem *)changePasswordButtonItem {
    if (!_changePasswordButtonItem) {
        _changePasswordButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改密码" style:UIBarButtonItemStylePlain target:self action:@selector(changePassword)];
    }
    
    return _changePasswordButtonItem;
}

- (NSArray<UIButton *> *)balanceViewButtons {
    if (!_balanceViewButtons) {
        UIButton *statisticButton = [[UIButton alloc] init];
        [statisticButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [statisticButton setTitle:@"消费统计" forState:UIControlStateNormal];
        [statisticButton addTarget:self action:@selector(showStatistics) forControlEvents:UIControlEventTouchUpInside];
        [self.balanceView addSubview:statisticButton];
        
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

        
        _balanceViewButtons = @[changePasswordButton, statisticButton, reportLostButton];
    }
    
    return _balanceViewButtons;
}
@end
