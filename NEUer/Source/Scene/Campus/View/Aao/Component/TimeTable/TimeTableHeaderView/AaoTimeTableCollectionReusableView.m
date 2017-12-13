//
//  AaoTimeTableCollectionReusableView.m
//  NEUer
//
//  Created by lanya on 2017/12/8.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoTimeTableCollectionReusableView.h"

static NSString * const kAaoTimeTableReusableViewCellId = @"kAaoTimeTableReusableViewCellId";

@interface AaoTimeTableCollectionReusableViewCell : UICollectionViewCell
@property (nonatomic, strong) UIView *detailView;
@property (nonatomic, strong) UILabel *weekdayLabel;
@property (nonatomic, strong) UILabel *enDateLabel;

@end
@implementation AaoTimeTableCollectionReusableViewCell

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.layer.backgroundColor = random(244, 248, 248).CGColor;
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    
    self.detailView.frame = self.contentView.frame;
    
    [self.weekdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.detailView);
        make.width.equalTo(self.detailView);
        make.centerY.equalTo(self.contentView.mas_bottom).multipliedBy(1 - 0.618);
    }];
    [self.enDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.weekdayLabel.mas_bottom).with.offset(2);
        make.left.and.right.equalTo(self.detailView);
        make.centerX.equalTo(self.weekdayLabel);
    }];
}

#pragma mark - Getter

- (UIView *)detailView {
    if (!_detailView) {
        _detailView = [[UIView alloc] init];
        [self.contentView addSubview:_detailView];
    }
    return _detailView;
}

- (UILabel *)weekdayLabel {
    if (!_weekdayLabel) {
        _weekdayLabel = [[UILabel alloc] init];
        _weekdayLabel.textAlignment = NSTextAlignmentCenter;
        _weekdayLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _weekdayLabel.textColor = [UIColor darkGrayColor];
        [self.detailView addSubview:_weekdayLabel];
    }
    return _weekdayLabel;
}

- (UILabel *)enDateLabel {
    if (!_enDateLabel) {
        _enDateLabel = [[UILabel alloc] init];
        _enDateLabel.textAlignment = NSTextAlignmentCenter;
        _enDateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _enDateLabel.textColor = [UIColor darkGrayColor];
        [self.detailView addSubview:_enDateLabel];
    }
    return _enDateLabel;
}

@end



@interface AaoTimeTableCollectionReusableView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <NSDictionary *> *cellDataArray;

@end

@implementation AaoTimeTableCollectionReusableView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initConstraints];
    }
    return self;
}


- (void)initConstraints {
    self.collectionView.frame = self.frame;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AaoTimeTableCollectionReusableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAaoTimeTableReusableViewCellId forIndexPath:indexPath];
    cell.weekdayLabel.text = self.cellDataArray[indexPath.item][@"zhDate"];
    cell.enDateLabel.text = self.cellDataArray[indexPath.item][@"enDate"];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        return CGSizeMake(32.0f, 44.0f);
    } else {
        CGFloat itemWidth = (SCREEN_WIDTH_ACTUAL - 32.0) / 7.0f;
        return CGSizeMake(itemWidth, 44.0f);
    }
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //        同行不同列
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[AaoTimeTableCollectionReusableViewCell class] forCellWithReuseIdentifier:kAaoTimeTableReusableViewCellId];
        _collectionView.scrollEnabled = NO;
        
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (NSArray<NSDictionary *> *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = @[
                           @{
                               @"zhDate" : @"课程",
                               @"enDate" : @""
                               },
                           @{
                               @"zhDate" : @"周一",
                               @"enDate" : @"MON"
                               },
                           @{
                               @"zhDate" : @"周二",
                               @"enDate" : @"TUE"
                               },
                           @{
                               @"zhDate" : @"周三",
                               @"enDate" : @"WEN"
                               },
                           @{
                               @"zhDate" : @"周四",
                               @"enDate" : @"THU"
                               },
                           @{
                               @"zhDate" : @"周五",
                               @"enDate" : @"FRI"
                               },
                           @{
                               @"zhDate" : @"周六",
                               @"enDate" : @"SAT"
                               },
                           @{
                               @"zhDate" : @"周日",
                               @"enDate" : @"SUN"
                               }
                           ];
    }
    return _cellDataArray;
}

@end
