//
//  HomeComponentCoverView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeComponentCoverView.h"
#import "TouchableCollectionViewCell.h"
static NSString * const kHomeComponentCoverCellId = @"kCellId";

@interface HomeComponentCoverCell : TouchableCollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@end

@interface HomeComponentCoverLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) NSInteger currentPage;
@end

@interface HomeComponentCoverView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSDictionary *> *cellDataArray;
@end

@implementation HomeComponentCoverView

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        self.titleLabel.text = [NSLocalizedString(@"HomeCoverTitle", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:@"987"];
        [self.actionButton setTitle:NSLocalizedString(@"HomeCoverActionButton", nil) forState:UIControlStateNormal];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    
    CGFloat cellWidth = SCREEN_WIDTH_ACTUAL - 16 - 16;
    CGFloat cellHeight = cellWidth * 10.0f / 16.0f;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.height.mas_equalTo(cellHeight);
    }];
}

#pragma mark - Override

- (void)initBaseConstraints {
    
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeComponentCoverCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHomeComponentCoverCellId forIndexPath:indexPath];
    NSDictionary *item = self.cellDataArray[indexPath.item];
    cell.imageView.image = [UIImage imageNamed:item[@"image"]];
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
        HomeComponentCoverLayout *flowLayout = [[HomeComponentCoverLayout alloc] init];
        CGFloat cellWidth = SCREEN_WIDTH_ACTUAL - 16 - 16;
        CGFloat cellHeight = cellWidth * 10.0f / 16.0f;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[HomeComponentCoverCell class] forCellWithReuseIdentifier:kHomeComponentCoverCellId];
        _collectionView.delegate = self;
        _collectionView.layer.masksToBounds = NO;
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
                               @"image":@"home3",
                               },
                           @{
                               @"image":@"home2",
                               },
                           @{
                               @"image":@"home1",
                               },
                           ];
    }
    
    return _cellDataArray;
}

@end

@implementation HomeComponentCoverCell

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.layer.cornerRadius = 12;
        self.layer.shadowOffset = CGSizeMake(0, 8);
        self.layer.shadowOpacity = 1.0f/3.0f;
        self.layer.shadowRadius = 8;
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self layoutIfNeeded];
    [_imageView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(12, 12)];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:12].CGPath;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
}

@end

@implementation HomeComponentCoverLayout

- (CGFloat)pageWidth {
    return self.itemSize.width + self.minimumLineSpacing;
}

- (CGPoint)offsetAtCurrentPage {
    
    CGFloat width = -self.collectionView.contentInset.left - self.sectionInset.left;
    for (int i = 0; i < self.currentPage; i++)
        width += [self pageWidth];
    
    return CGPointMake(width, 0);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    
    return [self offsetAtCurrentPage];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    // To scroll paginated
    /*
     if (velocity.x > 0 && self.currentPage < [self.collectionView numberOfItemsInSection:0]-1) self.currentPage += 1;
     else if (velocity.x < 0 && self.currentPage > 0) self.currentPage -= 1;
     
     return  [self offsetAtCurrentPage];
     */
    
    // To scroll and stop always at the center of a page
    CGRect proposedRect = CGRectMake(proposedContentOffset.x+self.collectionView.bounds.size.width/2 - self.pageWidth/2, 0, self.pageWidth, self.collectionView.bounds.size.height);
    NSMutableArray <__kindof UICollectionViewLayoutAttributes *> *allAttributes = [[self layoutAttributesForElementsInRect:proposedRect] mutableCopy];
    __block UICollectionViewLayoutAttributes *proposedAttributes = nil;
    __block CGFloat minDistance = CGFLOAT_MAX;
    [allAttributes enumerateObjectsUsingBlock:^(__kindof UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat distance = CGRectGetMidX(proposedRect) - obj.center.x;
        
        if (ABS(distance) < minDistance) {
            proposedAttributes = obj;
            minDistance = distance;
        }
    }];
    
    
    // Scroll always
    if (self.currentPage == proposedAttributes.indexPath.row) {
        if (velocity.x > 0 && self.currentPage < [self.collectionView numberOfItemsInSection:0]-1) self.currentPage += 1;
        else if (velocity.x < 0 && self.currentPage > 0) self.currentPage -= 1;
    }
    else  {
        self.currentPage = proposedAttributes.indexPath.row;
    }
    
    return  [self offsetAtCurrentPage];
}

@end
