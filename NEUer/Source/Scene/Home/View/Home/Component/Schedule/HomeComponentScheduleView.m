//
//  HomeComponentScheduleView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeComponentScheduleView.h"

static NSString * const kHomeComponentScheduleCellId = @"kCellId";

@interface HomeComponentScheduleCell : UICollectionViewCell

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UILabel *orderLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *classLabel;
@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation HomeComponentScheduleCell

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 8;
//        self.contentView.layer.borderWidth = 1.0/[UIScreen mainScreen].scale;
//        self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
//        self.layer.shadowColor = [UIColor grayColor].CGColor;
//        self.layer.shadowOffset = CGSizeMake(0, 2);
//        self.layer.shadowOpacity = 0.2;
//        self.layer.shadowRadius = 4;
//        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(@(90));
    }];
    
    [self.orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.leftView);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.leftView.mas_right).with.offset(16);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
    }];
    
    [self.classLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.right.equalTo(self.rightView);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.classLabel.mas_bottom);
        make.left.and.right.and.bottom.equalTo(self.rightView);
    }];
    
    [self layoutIfNeeded];
    [_leftView roundCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft radii:CGSizeMake(8, 8)];
}

- (UILabel *)orderLabel {
    if (!_orderLabel) {
        _orderLabel = [[UILabel alloc] init];
        _orderLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        _orderLabel.textColor = [UIColor whiteColor];
        _orderLabel.textAlignment = NSTextAlignmentCenter;
        [self.leftView addSubview:_orderLabel];
    }
    
    return _orderLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.leftView addSubview:_timeLabel];
    }
    
    return _timeLabel;
}

- (UILabel *)classLabel {
    if (!_classLabel) {
        _classLabel = [[UILabel alloc] init];
        _classLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _classLabel.textAlignment = NSTextAlignmentLeft;
        [self.rightView addSubview:_classLabel];
    }
    
    return _classLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _infoLabel.textColor = [UIColor grayColor];
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        [self.rightView addSubview:_infoLabel];
    }
    
    return _infoLabel;
}

- (UIView *)leftView {
    if (!_leftView) {
        _leftView = [[UIView alloc] init];
        [self.contentView addSubview:_leftView];
    }
    
    return _leftView;
}

- (UIView *)rightView {
    if (!_rightView) {
        _rightView = [[UIView alloc] init];
        [self.contentView addSubview:_rightView];
    }
    
    return _rightView;
}

@end

@interface HomeComponentScheduleView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSDictionary *> *cellDataArray;
@end

@implementation HomeComponentScheduleView

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        self.titleLabel.text = @"今日课程";
        [self.actionButton setTitle:@"完整课表" forState:UIControlStateNormal];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    CGFloat cellHeight = 64;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.height.mas_equalTo(@((self.cellDataArray.count*cellHeight+self.cellDataArray.count*8.0f)));
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeComponentScheduleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHomeComponentScheduleCellId forIndexPath:indexPath];
    NSDictionary *item = self.cellDataArray[indexPath.item];
    cell.timeLabel.text = item[@"time"];
    cell.classLabel.text = item[@"class"];
    cell.orderLabel.text = item[@"order"];
    cell.infoLabel.text = [NSString stringWithFormat:@"%@ %@", item[@"location"], item[@"teacher"]];
    cell.leftView.backgroundColor = [UIColor colorWithHexStr:item[@"color"]];
    cell.contentView.backgroundColor = [[UIColor colorWithHexStr:item[@"color"]] colorWithAlphaComponent:0.1];
//    cell.contentView.layer.borderColor = [UIColor colorWithHexStr:item[@"color"]].CGColor;
//    cell.layer.shadowColor = [UIColor colorWithHexStr:item[@"color"]].CGColor;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellDataArray.count;
}

#pragma mark - Getter

- (UIView *)bodyView {
    return self.contentView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 355, 375)];
        
        [self addSubview:_contentView];
    }
    
    return _contentView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = SCREEN_WIDTH_ACTUAL - 16 -16;
        CGFloat cellHeight = 64;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
        flowLayout.minimumLineSpacing = 8.0f;
        flowLayout.minimumInteritemSpacing = 8.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.layer.masksToBounds = NO;
        [_collectionView registerClass:[HomeComponentScheduleCell class] forCellWithReuseIdentifier:kHomeComponentScheduleCellId];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        _collectionView.scrollEnabled = NO;
        [self.contentView addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (NSArray<NSDictionary *> *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = @[
                           @{
                               @"class":@"计算机网络",
                               @"location":@"信息B123",
                               @"teacher":@"刘益先",
                               @"time":@"08:30-10:20",
                               @"order":@"一二",
                               @"color":@"#66A149",
                               },
                           @{
                               @"class":@"马克思原理",
                               @"location":@"信息B321",
                               @"teacher":@"恩格斯",
                               @"time":@"10:40-12:30",
                               @"order":@"三四",
                               @"color":@"#F5C046",
                               },
                           @{
                               @"class":@"计算机组成原理",
                               @"location":@"文馆A247",
                               @"teacher":@"刘国奇",
                               @"time":@"14:00-15:50",
                               @"order":@"五六",
                               @"color":@"#F5C046",
                               },
                           @{
                               @"class":@"数据结构与算法导论",
                               @"location":@"信息B123",
                               @"teacher":@"赵继",
                               @"time":@"16:10-18:00",
                               @"order":@"七八",
                               @"color":@"#F5C046",
                               },
                           ];
    }
    
    return _cellDataArray;
}

@end
