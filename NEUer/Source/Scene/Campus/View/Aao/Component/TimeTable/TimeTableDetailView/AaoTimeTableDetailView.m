//
//  AaoTimeTableDetailView.m
//  NEUer
//
//  Created by lanya on 2017/12/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoTimeTableDetailView.h"
#import "AaoModel.h"

static NSString * const kAaoTimerTableDeatilReusableCellId = @"kAaoTimerTableDeatilReusableCellId";

@interface AaoTimeTableDetailCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *classNameLabel;
@property (nonatomic, strong) UILabel *classLabel;

@end

@implementation AaoTimeTableDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(8);
        make.centerY.equalTo(self.contentView);
        make.height.and.width.equalTo(@28);
    }];
    [self.classLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).with.offset(16);
        make.centerY.equalTo(self.iconView);
    }];
    [self.classLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.classLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.classNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.classLabel.mas_right).with.offset(32);
        make.centerY.equalTo(self.iconView);
    }];
    [self.classNameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.classNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - Getter

- (UILabel *)classLabel {
    if (!_classLabel) {
        _classLabel = [[UILabel alloc] init];
        _classLabel.textAlignment = NSTextAlignmentCenter;
        _classLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _classLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_classLabel];
    }
    return _classLabel;
}

- (UILabel *)classNameLabel {
    if (!_classNameLabel) {
        _classNameLabel = [[UILabel alloc] init];
        _classNameLabel.textAlignment = NSTextAlignmentCenter;
        _classNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _classNameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_classNameLabel];
    }
    return _classNameLabel;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconView];
    }
    return _iconView;
}

@end


@interface AaoTimeTableDetailView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <NSMutableDictionary *> *cellDataArray;

@end

@implementation AaoTimeTableDetailView

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)layoutSubviews {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AaoTimeTableDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kAaoTimerTableDeatilReusableCellId];
    
    if (!cell) {
        cell = [[AaoTimeTableDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAaoTimerTableDeatilReusableCellId];
    }
    cell.iconView.image = [UIImage imageNamed:self.cellDataArray[indexPath.row][@"icon"]];
    cell.classLabel.text = self.cellDataArray[indexPath.row][@"classtitle"];
    cell.classNameLabel.text = self.cellDataArray[indexPath.row][@"classmessage"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

#pragma mark - Setter

- (void)setBean:(AaoStudentScheduleBean *)bean {
    _bean = bean;
    
    [self.cellDataArray[0] setObject:self.bean.schedule_classroom forKey:@"classmessage"];
    self.cellDataArray[1][@"classmessage"] = self.bean.schedule_classWeek;
    self.cellDataArray[2][@"classmessage"] = self.bean.schedule_duringClasses;
    self.cellDataArray[3][@"classmessage"] = self.bean.schedule_teacherName;
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = @[
                           @{
                               @"icon" : @"aao_timetable_classplace",
                               @"classtitle" : @"教室",
                               @"classmessage" : @""
                               }.mutableCopy,
                           @{
                               @"icon" : @"aao_timetable_classweek",
                               @"classtitle" : @"周数",
                               @"classmessage" : @""
                               }.mutableCopy,
                           @{
                               @"icon" : @"aao_timetable_classsection",
                               @"classtitle" : @"节数",
                               @"classmessage" : @"hehe"
                               }.mutableCopy,
                           @{
                               @"icon" : @"aao_timetable_classteacher",
                               @"classtitle" : @"老师",
                               @"classmessage" : @""
                               }.mutableCopy
                           ];
    }
    return _cellDataArray;
}

@end
