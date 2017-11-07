//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "CampusViewController.h"
#import "EcardMainViewController.h"
#import "TouchableCollectionViewCell.h"

static NSString * const kCampusCellId = @"kCampusCellId";

@interface CampusSectionlCell : TouchableCollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

- (void)update:(NSDictionary *)dictionary;

@end

@implementation CampusSectionlCell

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.layer.cornerRadius = 8;
        self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 4;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
        self.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.contentView);
        make.bottom.equalTo(self.titleLabel.mas_bottom).with.offset(12);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.contentView).with.offset(12);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).with.offset(8);
        make.lastBaseline.equalTo(self.titleLabel.mas_lastBaseline);
    }];
}

- (void)update:(NSDictionary *)dictionary {
    _imageView.image = [UIImage imageNamed:dictionary[@"image"]];
    _titleLabel.text = dictionary[@"title"];
    _detailLabel.text = dictionary[@"detail"];
    CGColorRef mainColor = [[UIImage imageNamed:dictionary[@"image"]].mainColor colorWithAlphaComponent:0.8].CGColor;
    self.layer.shadowColor = mainColor;
    self.layer.borderColor = mainColor;
    [self layoutIfNeeded];
    [_imageView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(8, 8)];
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.hidden = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
        
        [self.imageView addSubview:_blurView];
    }
    
    return _blurView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _detailLabel.numberOfLines = 1;
        _detailLabel.textColor = [UIColor grayColor];
        
        [self.contentView addSubview:_detailLabel];
    }
    
    return _detailLabel;
}

@end

@interface CampusViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSDictionary *> *cellDataArray;

@end

@implementation CampusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"CampusNavigationBarTitle", nil);
    
    [self initConstraints];
}

- (void)initConstraints {
    self.collectionView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = [NSURL URLWithString:self.cellDataArray[indexPath.item][@"url"]];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CampusSectionlCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampusCellId forIndexPath:indexPath];
    [cell update:self.cellDataArray[indexPath.item]];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellDataArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH_ACTUAL-32.0f, (SCREEN_WIDTH_ACTUAL-32.0f)*1.0f/2.0f);
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16);
        flowLayout.minimumLineSpacing = 16.0f;
        flowLayout.minimumInteritemSpacing = 8.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[CampusSectionlCell class] forCellWithReuseIdentifier:kCampusCellId];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollsToTop = YES;
        [self.view addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (NSArray<NSDictionary *> *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = @[
                           @{
                               @"title":NSLocalizedString(@"CampusAAOSystemTitle", nil),
                               @"detail":NSLocalizedString(@"CampusAAOSystemSubtitle", nil),
                               @"url":@"",
                               @"image":@"aao_campus_background",
                               },
                           @{
                               @"title":NSLocalizedString(@"CampusEcardCenterTitle", nil),
                               @"detail":NSLocalizedString(@"CampusEcardCenterSubtitle", nil),
                               @"url":@"neu://go/ecard",
                               @"image":@"ecard_campus_background",
                               },
                           @{
                               @"title":NSLocalizedString(@"CampusLibraryTitle", nil),
                               @"detail":NSLocalizedString(@"CampusLibrarySubtitle", nil),
                               @"url":@"",
                               @"image":@"library_campus_background",
                               },
                           @{
                               @"title":NSLocalizedString(@"CampusNetworkCenterTitle", nil),
                               @"detail":NSLocalizedString(@"CampusNetworkCenterSubtitle", nil),
                               @"url":@"",
                               @"image":@"ipgw_campus_background",
                               },
                           @{
                               @"title":NSLocalizedString(@"CampusRestaurantTitle", nil),
                               @"detail":NSLocalizedString(@"CampusRestaurantSubtitle", nil),
                               @"url":@"",
                               @"image":@"",
                               },
                           ];
    }
    
    return _cellDataArray;
}

@end
