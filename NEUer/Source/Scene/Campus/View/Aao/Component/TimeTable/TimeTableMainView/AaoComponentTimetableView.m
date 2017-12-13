//
//  AaoComponentTimetableView.m
//  NEUer
//
//  Created by lanya on 2017/12/8.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "AaoComponentTimetableView.h"
#import "AaoTimeTableCollectionReusableView.h"
#import "AaoClassDetailViewController.h"
#import "AaoModel.h"

static NSString * const kAaoTimeTableEmptyReusableCell = @"kAaoTimeTableEmptyReusableCell";
static NSString * const kAaoTimeTableCourseNumberCell = @"kAaoTimeTableCourseNumberCell";
static NSString * const kAaoTimeTableCourceRusableCell = @"kAaoTimeTableCourceRusableCell";
static NSString * const kAaoTimeTableReusableHeaderFooterView = @"kAaoTimeTableReusableHeaderFooterView";

@interface AaoComponentTimeTableViewCell : UICollectionViewCell
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *classTitleLabel;
@property (nonatomic, strong) UILabel *classPlaceLabel;
@property (nonatomic, strong) AaoStudentScheduleBean *bean;

@end
@implementation AaoComponentTimeTableViewCell

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        self.contentView.layer.borderColor = random(244, 248, 248).CGColor;
        self.contentView.layer.borderWidth = 0.3;
        
    }
    return self;
}

- (void)setBean:(AaoStudentScheduleBean *)bean {
    if ([self.reuseIdentifier isEqualToString:kAaoTimeTableCourceRusableCell]) {
        self.classTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        self.classPlaceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        self.cardView.layer.cornerRadius = 8;
        self.cardView.backgroundColor = bean.schedule_color;
        _classTitleLabel.textColor = [UIColor whiteColor];
        _classPlaceLabel.textColor = [UIColor whiteColor];
        self.classTitleLabel.text = bean.schedule_courceName;
        self.classPlaceLabel.text = [NSString stringWithFormat:@"@%@", bean.schedule_classroom];
    
        [self initConstraints];
    }
}

- (void)setUpWithData:(NSDictionary *)data {
    if ([self.reuseIdentifier isEqualToString:kAaoTimeTableCourseNumberCell]) {
        self.classTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        self.classPlaceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        self.classTitleLabel.text = data[@"topClass"];
        self.classPlaceLabel.text = data[@"bottomClass"];
        _cardView.layer.cornerRadius = 0;
        _cardView.layer.backgroundColor = random(244, 248, 248).CGColor;
        _classTitleLabel.textColor = [UIColor darkGrayColor];
        _classPlaceLabel.textColor = [UIColor darkGrayColor];
        
        [self initCourceConstaints];
    }
}

- (void)initConstraints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(2, 2, 2, 2));
    }];
    
    [self.classTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.width.equalTo(self.cardView);
        make.top.equalTo(self.cardView.mas_top).with.offset(8);
    }];
    [self.classPlaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.width.equalTo(self.cardView);
        make.top.equalTo(self.classTitleLabel.mas_bottom).with.offset(2);
    }];
    [self layoutIfNeeded];
}

- (void)initCourceConstaints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    [self.classTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.width.equalTo(self.cardView);
        make.top.equalTo(self.contentView).with.offset(8);
    }];
    [self.classPlaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.width.equalTo(self.cardView);
        make.top.equalTo(self.classTitleLabel).with.offset(self.contentView.frame.size.height * 0.48);
    }];
//    [self layoutIfNeeded];
}

#pragma mark - Getter

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        [self.contentView addSubview:_cardView];
    }
    return _cardView;
}

- (UILabel *)classTitleLabel {
    if (!_classTitleLabel) {
        _classTitleLabel = [[UILabel alloc] init];
        _classTitleLabel.textAlignment = NSTextAlignmentCenter;
        _classTitleLabel.numberOfLines = 0;
        _classTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _classTitleLabel.textColor = [UIColor blueColor];
        [self.cardView addSubview:_classTitleLabel];
    }
    return _classTitleLabel;
}

- (UILabel *)classPlaceLabel {
    if (!_classPlaceLabel) {
        _classPlaceLabel = [[UILabel alloc] init];
        _classPlaceLabel.textAlignment = NSTextAlignmentCenter;
        _classPlaceLabel.numberOfLines = 0;
        _classPlaceLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _classPlaceLabel.textColor = [UIColor blueColor];
        [self.cardView addSubview:_classPlaceLabel];
    }
    return _classPlaceLabel;
}

@end


@interface AaoComponentTimetableView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <NSDictionary *> *classArrangementArray;


@end
@implementation AaoComponentTimetableView

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        [self initData];
        [self initConstraints];
    }
    return self;
}

- (void)initData {
    _classInfoArray = @[];
}

- (void)initConstraints {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
//    self.collectionView.frame = self.frame;
    [self layoutIfNeeded];
    NSLog(@"%f", self.collectionView.frame.size.width);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (AaoStudentScheduleBean *bean in self.classInfoArray) {
        if (indexPath.item == bean.schedule_classDay && indexPath.section == bean.schedule_classPeriod) {
            AaoClassDetailViewController *detailVC = [[AaoClassDetailViewController  alloc] init];
            detailVC.bean = bean;
            detailVC.modalPresentationStyle = UIModalPresentationCustom;
            detailVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [[self viewController].navigationController presentViewController:detailVC animated:YES completion:nil];
        }
    }
}

/**
 *  返回当前视图的控制器
 */

- (UIViewController *)viewController {
    for (UIView *nextView = [self superview]; nextView; nextView = nextView.superview) {
        UIResponder *nextResponder = [nextView nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(SCREEN_WIDTH_ACTUAL, 44);
    } else {
        return CGSizeMake(0, 0);
    }
}


#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    AaoComponentTimeTableViewCell *cell = nil;
    if (indexPath.item == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAaoTimeTableCourseNumberCell forIndexPath:indexPath];
        
        [cell setUpWithData:self.classArrangementArray[indexPath.section]];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAaoTimeTableEmptyReusableCell forIndexPath:indexPath];
        for (AaoStudentScheduleBean *bean in self.classInfoArray) {
            if (indexPath.item == bean.schedule_classDay && indexPath.section == bean.schedule_classPeriod) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAaoTimeTableCourceRusableCell forIndexPath:indexPath];
                cell.bean = bean;
                return cell;
            }
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    AaoTimeTableCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kAaoTimeTableReusableHeaderFooterView forIndexPath:indexPath];
    
    return headerView;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 6;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (SCREEN_WIDTH_ACTUAL - 32.0 - 0.01 * 6) / 7.0f;
    CGFloat itemHeight = itemWidth * 5.0 / 4.0 * 2;
    if (indexPath.item == 0) {
        return CGSizeMake(32.0, itemHeight);
    } else {
        return CGSizeMake(itemWidth - 0.01, itemHeight);
    }
}

#pragma mark - Getter


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//        同行不同列
        flowLayout.minimumInteritemSpacing = 0.01;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.sectionHeadersPinToVisibleBounds = YES;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_collectionView registerClass:[AaoComponentTimeTableViewCell class] forCellWithReuseIdentifier:kAaoTimeTableEmptyReusableCell];
        [_collectionView registerClass:[AaoComponentTimeTableViewCell class] forCellWithReuseIdentifier:kAaoTimeTableCourseNumberCell];
        [_collectionView registerClass:[AaoComponentTimeTableViewCell class] forCellWithReuseIdentifier:kAaoTimeTableCourceRusableCell];
        [_collectionView registerClass:[AaoTimeTableCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kAaoTimeTableReusableHeaderFooterView];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.bounces = NO;
        
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (NSArray<NSDictionary *> *)classArrangementArray {
    if (!_classArrangementArray) {
        _classArrangementArray = @[
                           @{
                               @"topClass" : @"1",
                               @"bottomClass" : @"2"
                               },
                           @{
                               @"topClass" : @"3",
                               @"bottomClass" : @"4"
                               },
                           @{
                               @"topClass" : @"5",
                               @"bottomClass" : @"6"
                               },
                           @{
                               @"topClass" : @"7",
                               @"bottomClass" : @"8"
                               },
                           @{
                               @"topClass" : @"9",
                               @"bottomClass" : @"10"
                               },
                           @{
                               @"topClass" : @"11",
                               @"bottomClass" : @"12"
                               },
                           ];
    }
    return _classArrangementArray;
}

@end
