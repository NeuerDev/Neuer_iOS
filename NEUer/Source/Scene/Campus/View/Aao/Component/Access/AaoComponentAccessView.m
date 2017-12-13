//
//  AaoComponentAccessView.m
//  NEUer
//
//  Created by lanya on 2017/12/6.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoComponentAccessView.h"
#import "TouchableCollectionViewCell.h"

static NSString * const kAaoComponentReusableCell = @"kAaoComponentReusableCell";
NSString * const kAaoComponentCellDidClickedNotification = @"kAaoComponentCellDidClickedNotification";

@interface AaoComponentCollectionViewCell : TouchableCollectionViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation AaoComponentCollectionViewCell

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor yellowColor];
        self.contentView.layer.cornerRadius = 8;
        [self initConstraints];
    }
    return self;
}


- (void)initConstraints {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView.mas_bottom).multipliedBy(1 - 0.618);
        make.height.and.width.equalTo(@28);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.iconImageView.mas_bottom).with.offset(2);
    }];
    
    [self.contentView layoutIfNeeded];
    [self.contentView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(8, 8)];
}

#pragma mark - Getter

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

@end

@interface AaoComponentAccessView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray <NSDictionary *>*cellArray;

@end
@implementation AaoComponentAccessView

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.right.equalTo(self.contentView).with.offset(-16);
        make.height.and.top.equalTo(self.contentView);
    }];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAaoComponentCellDidClickedNotification
                                                        object:nil userInfo:@{
                                                                              @"param" : self.cellArray[indexPath.item][@"class"]
                                                                              }];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AaoComponentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAaoComponentReusableCell forIndexPath:indexPath];
    cell.iconImageView.image = [[UIImage imageNamed:self.cellArray[indexPath.item][@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.iconImageView.tintColor = [UIColor colorWithHexStr:self.cellArray[indexPath.item][@"textcolor"]];
    cell.nameLabel.text = self.cellArray[indexPath.item][@"title"];
    cell.contentView.backgroundColor = [UIColor colorWithHexStr:self.cellArray[indexPath.item][@"color"]];
    cell.nameLabel.textColor = [UIColor colorWithHexStr:self.cellArray[indexPath.item][@"textcolor"]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellArray.count;
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 68.0f)];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat itemWidth = (SCREEN_WIDTH_ACTUAL - 32 - 3.0 * 8.0)/4.0;
        flowlayout.itemSize = CGSizeMake(itemWidth, itemWidth * 4.0f/5.0f);
        flowlayout.minimumLineSpacing = 8.0f;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
        [_collectionView registerClass:[AaoComponentCollectionViewCell class] forCellWithReuseIdentifier:kAaoComponentReusableCell];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_collectionView];
    }
    return _collectionView;
}

- (NSArray<NSDictionary *> *)cellArray {
    if (!_cellArray) {
        _cellArray = @[
                       @{
                           @"title" : @"培养计划",
                           @"class" : @"AaoTrainingPlanViewController",
                           @"color":@"#FFD2D2",
                           @"textcolor":@"#FF9797",
                           @"icon":@"aao_access_plan"
                           },
                       @{
                           @"title" : @"成绩查询",
                           @"class" : @"AaoStudentScoreViewController",
                           @"icon":@"aao_access_score",
                           @"color":@"#FFE153",
                           @"textcolor":@"#EAC100"
                           },
                       @{
                           @"title" : @"教室查询",
                           @"class" : @"AaoClassroomViewController",
                           @"icon":@"aao_access_classroom",
                           @"color":@"#C2FF68",
                           @"textcolor":@"#73BF00"
                           },
                       @{
                           @"title" : @"考试日程",
                           @"class" : @"AaoExaminationScheduleViewController",
                           @"icon":@"aao_access_test",
                           @"color":@"#A3D1D1",
                           @"textcolor":@"#498080"
                           }
                       ];
    }
    return _cellArray;
}

@end
