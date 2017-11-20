//
//  TelevisionWallViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/23.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TelevisionWallViewController.h"
#import "TelevisionDetailViewController.h"
#import "TelevisionChannelSearchViewController.h"

#import "SpringCollectionViewLayout.h"

#import "TelevisionWallModel.h"

#import "TouchableCollectionViewCell.h"

#define SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)

static NSString * const kChannelCellId = @"kChannelCellId";

@interface TelevisionWallChannelCell : TouchableCollectionViewCell
@property (nonatomic, strong) TelevisionWallChannelBean *channelBean;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *viewerCountLabel;

@end

@implementation TelevisionWallChannelCell

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.layer.cornerRadius = 8;
        self.contentView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self.contentView.layer.shadowOffset = CGSizeMake(0, 4);
        self.contentView.layer.shadowOpacity = 0.5;
        self.contentView.layer.shadowRadius = 4;
        self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-12);
    }];
    
    [self.viewerCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.bottom.equalTo(self.titleLabel.mas_top).with.offset(-4);
    }];
}

#pragma mark - Setter

- (void)setChannelBean:(TelevisionWallChannelBean *)channelBean {
    _channelBean = channelBean;
    
    self.contentView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    __weak typeof(self)weakSelf=self;
    
    NSInteger timestamp = [[[NSDate alloc] init] timeIntervalSince1970]/60;
    NSString *previewUrl = [NSString stringWithFormat:@"%@?time=%ld", _channelBean.previewImageUrl, timestamp];
//    NSString *previewUrl = _channelBean.previewImageUrl;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:previewUrl] placeholderImage:[UIImage imageNamed:@"neu_placeholder_16_9_gray"] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image||error) {
            return;
        }
        
        if (image.size.height / image.size.width - 9.0f / 16.0f < 0.1) {
            weakSelf.imageView.backgroundColor = [UIColor clearColor];
        } else {
            weakSelf.imageView.backgroundColor = [UIColor blackColor];
        }
        
        if (cacheType==SDImageCacheTypeNone || !weakSelf.channelBean.mainColor) {
            weakSelf.channelBean.mainColor = [image mainColor].compressRangeColor;
            weakSelf.contentView.layer.shadowColor = weakSelf.channelBean.mainColor.CGColor;
        } else {
            weakSelf.contentView.layer.shadowColor = weakSelf.channelBean.mainColor.CGColor;
        }
    }];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2.0;
    shadow.shadowOffset = CGSizeMake(0, 0);
    shadow.shadowColor = [UIColor blackColor];
    
    NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:_channelBean.channelName attributes:@{NSShadowAttributeName:shadow}];
    NSAttributedString *viewerCountString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld 人正在观看", _channelBean.viewerCount] attributes:@{NSShadowAttributeName:shadow}];
    
    self.titleLabel.attributedText = titleString;
    self.viewerCountLabel.attributedText = viewerCountString;
    
    [self layoutIfNeeded];
    [_imageView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(8, 8)];
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.hidden = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)viewerCountLabel {
    if (!_viewerCountLabel) {
        _viewerCountLabel = [[UILabel alloc] init];
        _viewerCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _viewerCountLabel.numberOfLines = 1;
        _viewerCountLabel.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_viewerCountLabel];
    }
    
    return _viewerCountLabel;
}

@end

@interface TelevisionWallViewController () <TelevisionWallDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>
@property (nonatomic, strong) TelevisionChannelSearchViewController *searchViewController;

@property (nonatomic, strong) TelevisionWallModel *wallModel;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIBarButtonItem *sortBarButtonItem;

@end

@implementation TelevisionWallViewController
{
    NSString *_sourceName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"TelevisionWallTitle", nil);
    self.navigationItem.rightBarButtonItem = self.sortBarButtonItem;
    if (@available(iOS 11.0, *)) {
#ifdef __IPHONE_11_0
        self.navigationItem.searchController = self.searchViewController;
        [self.navigationItem setHidesSearchBarWhenScrolling:YES];
#endif
    } else {
        
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self initConstraints];
    
    [self.wallModel fetchWallData];
    [self.collectionView reloadData];
}

- (instancetype)initWithUrl:(NSURL *)url params:(NSDictionary *)params {
    if (self = [super init]) {
        NSLog(@"%@", url);
        NSLog(@"%@", params);
        _sourceName = [params objectForKey:@"sourcename"];
        
    }
    return self;
}

- (void)initConstraints {
    self.collectionView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Response Methods

- (void)changeChannelType {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择频道类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof(self) weakSelf = self;
    for (NSString *channelType in self.wallModel.channelTypeArray) {
        [alertVC addAction:[UIAlertAction actionWithTitle:channelType style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.wallModel setCurrentTypeWithName:channelType];
            weakSelf.sortBarButtonItem.title = channelType;
            [weakSelf.collectionView reloadData];
        }]];
    }
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - TelevisionWallDelegate

- (void)fetchWallDataDidSuccess {
    
    [self.collectionView reloadData];
//    跳转到指定节目单
    TelevisionDetailViewController *detailViewController = [[TelevisionDetailViewController alloc] init];
    for (TelevisionWallChannelBean *bean in self.wallModel.channelArray) {
        if ([bean.channelDetailUrl isEqualToString:_sourceName]) {
            detailViewController.channelBean = bean;
        }
    }
    if (detailViewController.channelBean) {
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
}

- (void)fetchWallDataDidFail:(NSString *)message {
    
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    NSString *searchString = [self.searchViewController.searchBar text];
    [self.wallModel queryWallWithKeyword:searchString];
    
    [self.collectionView reloadData];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.collectionView reloadData];
    self.searchViewController.searchBar.text = searchBar.text;
    [self.searchViewController.searchBar resignFirstResponder];
    self.searchViewController.active = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TelevisionDetailViewController *detailVC = [[TelevisionDetailViewController alloc] init];

    if (self.searchViewController.active) {
        detailVC.channelBean = self.wallModel.resultArray[indexPath.item];
    } else {
        detailVC.channelBean = self.wallModel.channelArray[indexPath.item];
    }
    
    self.searchViewController.active = NO;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TelevisionWallChannelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelCellId forIndexPath:indexPath];
    
    if (self.searchViewController.active) {

        if (self.wallModel.resultArray.count != 0) {
            cell.channelBean = self.wallModel.resultArray[indexPath.item];
        }
    }
    else{
        cell.channelBean = self.wallModel.channelArray[indexPath.item];
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.searchViewController.isActive) {
        return self.wallModel.resultArray.count;
    } else {
        return self.wallModel.channelArray.count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - Getter

- (TelevisionChannelSearchViewController *)searchViewController {
    if (!_searchViewController) {
        _searchViewController = [[TelevisionChannelSearchViewController alloc] initWithSearchResultsController:nil];
        _searchViewController.delegate = self;
        _searchViewController.dimsBackgroundDuringPresentation = YES;
        _searchViewController.searchResultsUpdater = self;
        _searchViewController.searchBar.delegate = self;
        _searchViewController.obscuresBackgroundDuringPresentation = NO;
    }
    
    return _searchViewController;
}

- (TelevisionWallModel *)wallModel {
    if (!_wallModel) {
        _wallModel = [[TelevisionWallModel alloc] init];
        _wallModel.delegate = self;
    }
    
    return _wallModel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH-32.0f, (SCREEN_WIDTH-32.0f)*9.0f/16.0f);
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16);
        flowLayout.minimumLineSpacing = 24.0f;
        flowLayout.minimumInteritemSpacing = 8.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[TelevisionWallChannelCell class] forCellWithReuseIdentifier:kChannelCellId];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollsToTop = YES;
        [self.view addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (UIBarButtonItem *)sortBarButtonItem {
    if (!_sortBarButtonItem) {
        _sortBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.wallModel.channelTypeArray[0] style:UIBarButtonItemStylePlain target:self action:@selector(changeChannelType)];
    }
    
    return _sortBarButtonItem;
}

@end
