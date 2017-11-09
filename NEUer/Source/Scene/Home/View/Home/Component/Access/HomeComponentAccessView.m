//
//  HomeComponentAccessView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeComponentAccessView.h"
#import "TouchableCollectionViewCell.h"

static NSString * const kHomeComponentAccessCellId = @"kCellId";

@interface HomeComponentAccessCell : TouchableCollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation HomeComponentAccessCell

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.layer.cornerRadius = 8;
//        self.layer.shadowColor = [UIColor grayColor].CGColor;
//        self.layer.shadowOffset = CGSizeMake(0, 4);
//        self.layer.shadowOpacity = 0.2;
//        self.layer.shadowRadius = 4;
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self layoutIfNeeded];
    [self.contentView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(8, 8)];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

@end

@interface HomeComponentAccessView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSDictionary *> *cellDataArray;
@end

@implementation HomeComponentAccessView

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
//        self.titleLabel.text = @"快速链接";
//        [self.actionButton setTitle:@"更多" forState:UIControlStateNormal];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    CGFloat cellHeight = 54;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.height.mas_equalTo(@(((self.cellDataArray.count+1)/3*cellHeight+(self.cellDataArray.count-3)/3*8.0f)));
    }];
}

#pragma mark - Override

- (void)initBaseConstraints {
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 16, 0, 16));
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = [NSURL URLWithString:self.cellDataArray[indexPath.item][@"url"]];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeComponentAccessCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHomeComponentAccessCellId forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithHexStr:self.cellDataArray[indexPath.item][@"color"]];
//    cell.layer.shadowColor = [UIColor colorWithHexStr:self.cellDataArray[indexPath.item][@"color"]].CGColor;
    cell.titleLabel.text = self.cellDataArray[indexPath.item][@"title"];
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
        CGFloat cellWidth = (SCREEN_WIDTH_ACTUAL - 32 - 16)/3;
        CGFloat cellHeight = 54;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
        flowLayout.minimumLineSpacing = 8.0f;
        flowLayout.minimumInteritemSpacing = 8.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.layer.masksToBounds = NO;
        [_collectionView registerClass:[HomeComponentAccessCell class] forCellWithReuseIdentifier:kHomeComponentAccessCellId];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollsToTop = YES;
        _collectionView.scrollEnabled = NO;
        _collectionView.delaysContentTouches = NO;
        [self.contentView addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (NSArray<NSDictionary *> *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = @[
                           @{
                               @"title":NSLocalizedString(@"HomeAccessARCampus", nil),
                               @"url":@"",
                               @"color":@"#DFC3BB",
                               },
                           @{
                               @"title":NSLocalizedString(@"HomeAccessScore", nil),
                               @"url":@"neu://go/aao",
                               @"color":@"#E7D1B4",
                               },
                           @{
                               @"title":NSLocalizedString(@"HomeAccessIPGateway", nil),
                               @"url":@"neu://handle/ipgw",
                               @"color":@"#E7D1B4",
                               },
                           @{
                               @"title":NSLocalizedString(@"HomeAccessLibraryBooks", nil),
                               @"url":@"neu://go/lib",
                               @"color":@"#A2C9B4",
                               },
                           @{
                               @"title":NSLocalizedString(@"HomeAccessEcard", nil),
                               @"url":@"neu://go/ecard",
                               @"color":@"#92AFC0",
                               },
                           @{
                               @"title":NSLocalizedString(@"HomeAccessTelevision", nil),
                               @"url":@"neu://go/tv",
                               @"color":@"#A2C9B4",
                               },
                           ];
    }
    
    return _cellDataArray;
}

@end
