//
//  TelevisionManageOrderedViewController.m
//  NEUer
//
//  Created by lanya on 2017/11/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TelevisionManageOrderedViewController.h"
#import "AppDelegate.h"

#import "TelevisionWallModel.h"

static NSString * const kTelevisionManageOrderedCell = @"kTelevisionManageOrderedCell";
@interface TelevisionWallOrderCell : UITableViewCell

@property (nonatomic, strong) UILabel *showNameLabel;
@property (nonatomic, strong) UILabel *channelLabel;
@property (nonatomic, strong) UILabel *showTimeLabel;
@property (nonatomic, strong) TelevisionWallOrderBean *bean;

@end

@implementation TelevisionWallOrderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initConstaints];
    }
    return self;
}

- (void)initConstaints {
    [self.showNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(self.contentView).with.offset(8);
    }];
    [self.showTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.showNameLabel);
        make.top.equalTo(self.showNameLabel.mas_bottom).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-8);
    }];
    [self.channelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-16);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)setBean:(TelevisionWallOrderBean *)bean {
    _bean = bean;
    _showNameLabel.text = bean.showName;
    _showTimeLabel.text = bean.showTime;
    _channelLabel.text = bean.channelName;
}

#pragma mark - Getter

- (UILabel *)showNameLabel {
    if (!_showNameLabel) {
        _showNameLabel = [[UILabel alloc] init];
        _showNameLabel.numberOfLines = 1;
        _showNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _showNameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_showNameLabel];
    }
    return _showNameLabel;
}

- (UILabel *)showTimeLabel {
    if (!_showTimeLabel) {
        _showTimeLabel = [[UILabel alloc] init];
        _showTimeLabel.numberOfLines = 1;
        _showTimeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _showTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_showTimeLabel];
    }
    return _showTimeLabel;
}

- (UILabel *)channelLabel {
    if (!_channelLabel) {
        _channelLabel = [[UILabel alloc] init];
        _channelLabel.numberOfLines = 1;
        _channelLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _channelLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_channelLabel];
    }
    return _channelLabel;
}

@end


@interface TelevisionManageOrderedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation TelevisionManageOrderedViewController

#pragma mark - LifeCycle

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
    self.title = @"预约节目";
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TelevisionWallOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:kTelevisionManageOrderedCell];
    if (!cell) {
        cell = [[TelevisionWallOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTelevisionManageOrderedCell];
    }
    cell.bean = self.wallModel.orderedArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == self.wallModel.orderedArray.count) {
        [self setBaseViewState:JHBaseViewStateEmptyContent];
        self.baseRetryButton.hidden = YES;
        self.baseStateDetailLabel.text = @"暂无预约节目";
        return 0;
    } else {
        return self.wallModel.orderedArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TelevisionWallOrderBean *bean = self.wallModel.orderedArray[indexPath.row];
        [self.wallModel removeTVShowOrderFromOrderArray:bean];
        [((AppDelegate *)[UIApplication sharedApplication].delegate).center  removePendingNotificationRequestsWithIdentifiers:@[[NSString stringWithFormat:@"requestId_%@_%@", bean.sourceString, bean.showTime]]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
