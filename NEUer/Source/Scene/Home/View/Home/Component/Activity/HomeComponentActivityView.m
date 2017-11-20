//
//  HomeComponentActivityView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/18.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeComponentActivityView.h"
#import "TouchableCollectionViewCell.h"

static NSString * const kHomeComponentActivityCellId = @"kCellId";

@interface HomeComponentActivityCell : TouchableCollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@end

@interface HomeComponentActivityLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) NSInteger currentPage;
@end

@interface HomeComponentActivityView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSDictionary *> *cellDataArray;
@end

@implementation HomeComponentActivityView
#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        self.titleLabel.text = NSLocalizedString(@"HomeActivityTitle", nil);
        [self.actionButton setTitle:NSLocalizedString(@"HomeActivityActionButton", nil) forState:UIControlStateNormal];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@150);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = [NSURL URLWithString:self.cellDataArray[indexPath.item][@"url"]];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeComponentActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHomeComponentActivityCellId forIndexPath:indexPath];
    NSDictionary *item = self.cellDataArray[indexPath.item];
    cell.imageView.image = [UIImage imageNamed:item[@"image"]];
    cell.titleLabel.text = item[@"title"];
    cell.subtitleLabel.text = item[@"subtitle"];
    cell.layer.shadowColor = [UIImage imageNamed:item[@"image"]].mainColor.CGColor;
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
        _contentView = [[UIView alloc] init];
        
        [self addSubview:_contentView];
    }
    
    return _contentView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = (SCREEN_WIDTH_ACTUAL - 16 - 16 - 8)/2;
        CGFloat cellHeight = 150.0f;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
        flowLayout.minimumInteritemSpacing = 8.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.layer.masksToBounds = NO;
        [_collectionView registerClass:[HomeComponentActivityCell class] forCellWithReuseIdentifier:kHomeComponentActivityCellId];
        _collectionView.delegate = self;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _collectionView.dataSource = self;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        [self.contentView addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (NSArray<NSDictionary *> *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = @[
                           @{
                               @"image":@"home_activity_arcampus",
                               @"title":NSLocalizedString(@"HomeActivityARCampusTitle", nil),
                               @"subtitle":NSLocalizedString(@"HomeActivityARCampusSubtitle", nil),
                               @"url":@"neu://go/ar",
                               },
                           @{
                               @"image":@"home_activity_television",
                               @"title":NSLocalizedString(@"HomeActivityTelevisionTitle", nil),
                               @"subtitle":NSLocalizedString(@"HomeActivityTelevisionSubtitle", nil),
                               @"url":@"neu://go/tv",
                               },
                           @{
                               @"image":@"home_activity_share",
                               @"title":NSLocalizedString(@"HomeActivityShareTitle", nil),
                               @"subtitle":NSLocalizedString(@"HomeActivityShareSubtitle", nil),
                               @"url":@"neu://go/tv",
                               },
                           ];
    }
    
    return _cellDataArray;
}

@end

@implementation HomeComponentActivityCell

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.contentView);
        make.height.mas_equalTo(self.imageView.mas_width).multipliedBy(10.0f/16.0f);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.imageView);
        make.top.equalTo(self.imageView.mas_bottom).with.offset(4);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(2);
    }];
    
    [self layoutIfNeeded];
    [_imageView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(8, 8)];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _subtitleLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_subtitleLabel];
    }
    
    return _subtitleLabel;
}

@end
