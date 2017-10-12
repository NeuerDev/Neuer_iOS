//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "CampusViewController.h"
#import "EcardViewController.h"
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
        
        self.contentView.layer.cornerRadius = 16;
        self.contentView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self.contentView.layer.shadowOffset = CGSizeMake(0, 4);
        self.contentView.layer.shadowOpacity = 0.5;
        self.contentView.layer.shadowRadius = 4;
        
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
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.contentView).with.offset(12);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.detailLabel);
        make.top.equalTo(self.detailLabel.mas_bottom).with.offset(4);
    }];
}

- (void)update:(NSDictionary *)dictionary {
    _imageView.image = [UIImage imageNamed:dictionary[@"image"]];
    _titleLabel.text = dictionary[@"title"];
    _detailLabel.text = dictionary[@"detail"];
    self.layer.shadowColor = _imageView.image.mainColor.CGColor;
    [self layoutIfNeeded];
    [_imageView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(16, 16)];
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
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        
        [self.imageView addSubview:_blurView];
    }
    
    return _blurView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        _detailLabel.numberOfLines = 1;
        _detailLabel.textColor = [UIColor darkGrayColor];
        
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
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.and.right.and.bottom.equalTo(self.view);
    }];
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
        flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH_ACTUAL-32.0f, (SCREEN_WIDTH_ACTUAL-32.0f)*3.0f/4.0f);
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16);
        flowLayout.minimumLineSpacing = 24.0f;
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
                               @"title":@"教务处",
                               @"detail":@"关心你 更关心你的成绩",
                               @"url":@"",
                               @"image":@"aao_campus_background",
                               },
                           @{
                               @"title":@"校卡中心",
                               @"detail":@"再也不怕打菜时余额不足了",
                               @"url":@"",
                               @"image":@"ecard_campus_background",
                               },
                           @{
                               @"title":@"图书馆",
                               @"detail":@"在图书馆邂逅那个抠脚大汉",
                               @"url":@"",
                               @"image":@"library_campus_background",
                               },
                           @{
                               @"title":@"网络中心",
                               @"detail":@"看个剧分分钟爆流量的网关",
                               @"url":@"",
                               @"image":@"ipgw_campus_background",
                               },
                           @{
                               @"title":@"东大食堂",
                               @"detail":@"据说三楼的甜辣鸡最好吃",
                               @"url":@"",
                               @"image":@"",
                               },
                           ];
    }
    
    return _cellDataArray;
}

@end
