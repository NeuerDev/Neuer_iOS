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
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation HomeComponentAccessCell

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.layer.cornerRadius = 8;
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView.mas_bottom).multipliedBy(1-0.618);
        make.height.and.width.mas_equalTo(@28);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).with.offset(2);
        make.left.and.right.equalTo(self.contentView);
    }];
    
    [self layoutIfNeeded];
    [self.contentView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(8, 8)];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
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
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    MASAttachKeys(self, self.collectionView, self.contentView);
    CGFloat cellWidth = (SCREEN_WIDTH_ACTUAL - 32 - 3*8)/4;
    CGFloat cellHeight = cellWidth*5.0f/6.0f;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.height.mas_equalTo(@(cellHeight));
    }];
}

#pragma mark - Override

- (void)initBaseConstraints {
    
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(24);
        make.left.equalTo(self.mas_left).with.offset(16);
        make.right.equalTo(self.mas_right).with.offset(-16);
        make.bottom.equalTo(self.mas_bottom);
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
    cell.titleLabel.textColor = [UIColor colorWithHexStr:self.cellDataArray[indexPath.item][@"textcolor"]];
    cell.imageView.image = [[UIImage imageNamed:self.cellDataArray[indexPath.item][@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.tintColor = [UIColor colorWithHexStr:self.cellDataArray[indexPath.item][@"textcolor"]];
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
        CGFloat cellWidth = (SCREEN_WIDTH_ACTUAL - 32 - 3*8)/4;
        CGFloat cellHeight = cellWidth*4.0f/5.0f;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
        flowLayout.minimumLineSpacing = 8.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
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
//                           @{
//                               @"title":@"AR 校园",
//                               @"url":@"neu://go/ar",
//                               @"color":@"#DFC3BB",
//                               },
                           @{
                               @"title":NSLocalizedString(@"HomeAccessScore", nil),
                               @"url":@"neu://go/aao",
                               @"icon":@"home_access_rank",
                               @"color":@"#F6F0D0",
                               @"textcolor":@"#DA862D",
                               },
                           @{
                               @"title":NSLocalizedString(@"HomeAccessIPGateway", nil),
                               @"url":@"neu://handle/ipgw",
                               @"icon":@"home_access_net",
                               @"color":@"#F6E6DA",
                               @"textcolor":@"#E67347",
                               },
                           @{
                               @"title":NSLocalizedString(@"HomeAccessLibraryBooks", nil),
                               @"url":@"neu://go/lib/search",
                               @"title":@"书刊查询",
                               @"icon":@"home_access_book",
                               @"color":@"#F1F8CE",
                               @"textcolor":@"#B4CA45",
                               },
                           @{
                               @"title":NSLocalizedString(@"HomeAccessEcard", nil),
                               @"url":@"neu://go/ecard",
                               @"icon":@"home_access_card",
                               @"color":@"#D5F6F2",
                               @"textcolor":@"#6AC6B3",
                               },
//                           @{
//                               @"title":NSLocalizedString(@"HomeAccessTelevision", nil),
//                               @"url":@"neu://go/tv",
//                               @"color":@"#A2C9B4",
//                               },
                           ];
    }
    
    return _cellDataArray;
}

@end
