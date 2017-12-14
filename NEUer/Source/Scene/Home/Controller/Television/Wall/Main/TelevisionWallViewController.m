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
#import "TelevisionManageOrderedViewController.h"

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "TelevisionWallModel.h"
#import "TouchableCollectionViewCell.h"

#define SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)

typedef void(^TelevisionWallToolBarChangeDisplayBlock)(BOOL isLargeImageShowing);

static NSString * const kChannelNormalCellId = @"kChannelNormalCellId";
static NSString * const kChannelDetailCellId = @"kChannelDetailCellId";
static NSString * const kChannelHeaderFooterView = @"kChannelWordHeaderFooterView";

@interface TelevisionWallToolBar : UIView
@property (nonatomic, assign) BOOL largeImageDisplay;
@property (nonatomic, strong) UIButton *categoryButton;
@property (nonatomic, strong) TelevisionWallToolBarChangeDisplayBlock changeDisplayBlock;
@end

@interface TelevisionWallChannelHeaderFooterView : UICollectionReusableView
@property (nonatomic, strong) UILabel *headerLabel;

@end

@interface TelevisionWallChannelNormalCell : TouchableCollectionViewCell
@property (nonatomic, strong) TelevisionWallChannelBean *channelBean;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *viewerCountLabel;

@end

@interface TelevisionWallChannelDetailCell : UICollectionViewCell
@property (nonatomic, strong) TelevisionWallChannelBean *channelBean;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *viewerCountLabel;

@end

@interface TelevisionWallViewController () <TelevisionWallDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchViewController;

@property (nonatomic, strong) TelevisionWallModel *wallModel;
@property (nonatomic, weak) GatewayCenter *center;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TelevisionWallToolBar *televisionToolBar;
@property (nonatomic, strong) UIBarButtonItem *orderedBarButtonItem;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@end

@implementation TelevisionWallViewController
{
    NSString *_sourceName;
    BOOL _isShowCollectionItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initConstraints];
    
    [self checkNetworkStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initData {
    
    self.title = NSLocalizedString(@"TelevisionWallTitle", nil);
    self.navigationItem.rightBarButtonItem = self.orderedBarButtonItem;
    if (@available(iOS 11.0, *)) {
#ifdef __IPHONE_11_0
        //        暂时把搜索框注释掉了
        //        self.navigationItem.searchController = self.searchViewController;
        //        [self.navigationItem setHidesSearchBarWhenScrolling:YES];
#endif
    } else {
        
    }
    
    _isShowCollectionItems = NO;
    
    self.view.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    self.definesPresentationContext = YES;
    
    WS(ws);
    self.televisionToolBar.changeDisplayBlock = ^(BOOL isLargeImageShowing) {
        [ws.collectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, ws.collectionView.numberOfSections)]];
    };
    [self.televisionToolBar.categoryButton setTitle:self.wallModel.channelTypeArray[0] forState:UIControlStateNormal];
    [self.televisionToolBar.categoryButton addTarget:self action:@selector(onCategoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.wallModel fetchWallData];
}

- (instancetype)initWithUrl:(NSURL *)url params:(NSDictionary *)params {
    if (self = [super init]) {
        if ([params objectForKey:@"sourcename"]) {
            _sourceName = [params objectForKey:@"sourcename"];
        }
    }
    return self;
}

- (void)initConstraints {
    
    self.collectionView.frame = self.view.frame;
}

#pragma mark - Response Method

- (void)onCategoryButtonClicked:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择频道类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    WS(ws);
    for (NSString *channelType in self.wallModel.channelTypeArray) {
        [alertVC addAction:[UIAlertAction actionWithTitle:channelType style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws.wallModel setCurrentTypeWithName:channelType];
            [ws.televisionToolBar.categoryButton setTitle:channelType forState:UIControlStateNormal];
            if (ws.wallModel.currentType != TelevisionChannelTypeAll) {
                _isShowCollectionItems = NO;
            } else {
                _isShowCollectionItems = YES;
            }
            [UIView animateWithDuration:0.3 animations:^{
                ws.collectionView.alpha = 0;
            } completion:^(BOOL finished) {
                [ws.collectionView reloadData];
                [UIView animateWithDuration:0.3 animations:^{
                    ws.collectionView.alpha = 1;
                }];
            }];
        }]];
    }
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)manageTheOrderedShows {
    TelevisionManageOrderedViewController *orderedViewController = [[TelevisionManageOrderedViewController alloc] init];
    orderedViewController.wallModel = self.wallModel;
    [self.navigationController pushViewController:orderedViewController animated:YES];
}

#pragma mark - TelevisionWallDelegate

- (void)fetchWallDataDidSuccess {
    
    WS(ws);
    __block NSArray<TelevisionWallOrderBean *> *notiArray = nil;
    [((AppDelegate *)[UIApplication sharedApplication].delegate).center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        notiArray = [NSArray arrayWithArray:requests];
        TelevisionWallOrderBean *bean = [[TelevisionWallOrderBean alloc] init];
        for (UNNotificationRequest *request in requests) {
            bean.showTime = [request.content.userInfo objectForKey:@"showtime"];
            bean.showName = [request.content.userInfo objectForKey:@"showname"];
            bean.sourceString = [request.content.userInfo objectForKey:@"showsource"];
            bean.channelName = [request.content.userInfo objectForKey:@"channelname"];
            [ws.wallModel addOrderedTVShow:bean];
            bean = [[TelevisionWallOrderBean alloc] init];
        }
    }];
    
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    
    //    跳转到指定节目单
    //    TelevisionDetailViewController *detailViewController = [[TelevisionDetailViewController alloc] init];
    //    for (TelevisionWallChannelBean *bean in self.wallModel.channelArray) {
    //        if (_sourceName && [bean.channelDetailUrl isEqualToString:_sourceName]) {
    //            detailViewController.wallModel = self.wallModel;
    //            detailViewController.channelBean = bean;
    //        } else if (!_sourceName) {
    //            return;
    //        }
    //    }
    //    if (detailViewController.channelBean) {
    //        [self.navigationController pushViewController:detailViewController animated:YES];
    //    }
    
    //   直接播放指定节目
    if (_sourceName) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://media2.neu6.edu.cn/hls/%@.m3u8", _sourceName]];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.updatesNowPlayingInfoCenter = NO;
        playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        [playerViewController.player play];
        
        [self presentViewController:playerViewController animated:YES completion:nil];
    }
}

- (void)fetchWallDataDidFail:(NSString *)message {
    
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    
    NSString *searchString = [self.searchViewController.searchBar text];
    WS(ws);
    [self.wallModel queryWallWithKeyword:searchString complete:^(BOOL success) {
        [ws.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchViewController.searchBar.text = searchBar.text;
    [self.searchViewController.searchBar resignFirstResponder];
    _searchViewController.dimsBackgroundDuringPresentation = NO;
    self.searchViewController.active = YES;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TelevisionDetailViewController *detailVC = [[TelevisionDetailViewController alloc] init];
    detailVC.wallModel = self.wallModel;
    
    if (_isShowCollectionItems && indexPath.section == 0) {
        detailVC.channelBean = self.wallModel.collectionArray[indexPath.item];
    } else {
        if (self.searchViewController.isActive) {
            detailVC.channelBean = self.wallModel.resultArray[indexPath.item];
        } else {
            detailVC.channelBean = self.wallModel.channelArray[indexPath.item];
        }
    }
    
    [self.navigationController pushViewController:detailVC animated:YES];
    self.searchViewController.active = NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_isShowCollectionItems && section == 0) {
        return CGSizeMake(SCREEN_WIDTH_ACTUAL, 72);
    } else {
        return CGSizeMake(SCREEN_WIDTH_ACTUAL, 44);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    TelevisionWallChannelHeaderFooterView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kChannelHeaderFooterView forIndexPath:indexPath];
    if (kind == UICollectionElementKindSectionHeader && _isShowCollectionItems) {
        if (indexPath.section == 0) {
            headerView.headerLabel.text = @"我的收藏";
        } else {
            headerView.headerLabel.text = @"全部频道";
        }
    } else {
        headerView.headerLabel.text = @"";
    }
    return headerView;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TelevisionWallChannelNormalCell *normalCell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelNormalCellId forIndexPath:indexPath];
    TelevisionWallChannelDetailCell *detailCell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelDetailCellId forIndexPath:indexPath];
    if (self.televisionToolBar.largeImageDisplay) {
        if (_isShowCollectionItems && indexPath.section == 0) {
            normalCell.channelBean = self.wallModel.collectionArray[indexPath.item];
            return normalCell;
        } else if ((_isShowCollectionItems && indexPath.section == 1) || (!_isShowCollectionItems && indexPath.section == 0)){
            if (self.searchViewController.isActive) {
                normalCell.channelBean = self.wallModel.resultArray[indexPath.item];
            } else{
                normalCell.channelBean = self.wallModel.channelArray[indexPath.item];
            }
            return normalCell;
        } else {
        }
    } else {
        if (_isShowCollectionItems && indexPath.section == 0) {
            detailCell.channelBean = self.wallModel.collectionArray[indexPath.item];
            return detailCell;
        }else if ((_isShowCollectionItems && indexPath.section == 1) || (!_isShowCollectionItems && indexPath.section == 0)){
            if (self.searchViewController.isActive) {
                detailCell.channelBean = self.wallModel.resultArray[indexPath.item];
            } else{
                detailCell.channelBean = self.wallModel.channelArray[indexPath.item];
            }
            return detailCell;
        } else {
        }
    }
    
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    if (self.baseViewState != JHBaseViewStateNormal) {
        self.televisionToolBar.hidden = YES;
        return 0;
    } else {
        self.televisionToolBar.hidden = NO;
    }
    
    if (_isShowCollectionItems) {
        if (!self.searchViewController.isActive) {
            if (section == 0) {
                return self.wallModel.collectionArray.count;
            } else {
                return self.wallModel.channelArray.count;
            }
        } else {
            return self.wallModel.resultArray.count;
        }
    } else {
        if (self.searchViewController.isActive) {
            return self.wallModel.resultArray.count;
        } else {
            return self.wallModel.channelArray.count;
        }
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (!self.searchViewController.isActive && self.wallModel.currentType == TelevisionChannelTypeAll && self.wallModel.collectionArray.count > 0) {
        _isShowCollectionItems = YES;
        return 2;
    } else {
        _isShowCollectionItems = NO;
        return 1;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat minimumLineSpacing = 24.0f;
    if (self.televisionToolBar.largeImageDisplay) {
        minimumLineSpacing = 24.0f;
    } else {
        minimumLineSpacing = 16.0f;
    }
    
    return minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat minimumInteritemSpacing = 8.0f;
    if (self.televisionToolBar.largeImageDisplay) {
        minimumInteritemSpacing = 8.0f;
    } else {
        minimumInteritemSpacing = 8.0f;
    }
    
    return minimumInteritemSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeZero;
    if (self.televisionToolBar.largeImageDisplay) {
        itemSize = CGSizeMake(SCREEN_WIDTH-32.0f, (SCREEN_WIDTH-32.0f)*9.0f/16.0f);
    } else {
        itemSize = CGSizeMake(SCREEN_WIDTH - 32.0f, 120.0f);
    }
    
    return itemSize;
}

#pragma mark - Private Method

- (void)checkNetworkStatus {
    if (self.center.networkEnable && self.center.campusStatus == GatewayStatusYES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setBaseViewState:JHBaseViewStateNormal];
            [self.collectionView reloadData];
        });
    } else {
        [self setBaseViewState:JHBaseViewStateConnectionLost];
        self.baseStateTitleLabel.text = @"没接入校园网";
        self.baseStateDetailLabel.text = @"电视直播仅支持在校园网环境下看哦\n请接入校园网环境的网络";
    }
}

#pragma mark - Override

- (void)onBaseRetryButtonClicked:(UIButton *)sender {
    [self checkNetworkStatus];
}

#pragma mark - Getter

- (GatewayCenter *)center {
    if (!_center) {
        _center = [GatewayCenter defaultCenter];
    }
    
    return _center;
}

- (UISearchController *)searchViewController {
    if (!_searchViewController) {
        _searchViewController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchViewController.delegate = self;
        _searchViewController.obscuresBackgroundDuringPresentation = NO;
        _searchViewController.searchResultsUpdater = self;
        _searchViewController.searchBar.delegate = self;
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
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[TelevisionWallChannelNormalCell class] forCellWithReuseIdentifier:kChannelNormalCellId];
        [_collectionView registerClass:[TelevisionWallChannelDetailCell class] forCellWithReuseIdentifier:kChannelDetailCellId];
        [_collectionView registerClass:[TelevisionWallChannelHeaderFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kChannelHeaderFooterView];
        
        self.televisionToolBar.frame = CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 44);
        [_collectionView addSubview:self.televisionToolBar];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    
    return _flowLayout;
}

- (UIBarButtonItem *)orderedBarButtonItem {
    if (!_orderedBarButtonItem) {
        _orderedBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tv_order"]  style:UIBarButtonItemStylePlain target:self action:@selector(manageTheOrderedShows)];
    }
    
    return _orderedBarButtonItem;
}

- (TelevisionWallToolBar *)televisionToolBar {
    if (!_televisionToolBar) {
        _televisionToolBar = [[TelevisionWallToolBar alloc] init];
    }
    
    return _televisionToolBar;
}

@end

@implementation TelevisionWallToolBar
{
    UIButton *_largeImageDisplayButton;
    UIButton *_listDisplayButton;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self initConstraints];
    }
    
    return self;
}

- (void)initData {
    self.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    
    _largeImageDisplayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _largeImageDisplayButton.dk_tintColorPicker = DKColorPickerWithKey(accent);
    [_largeImageDisplayButton addTarget:self action:@selector(onLargeImageDisplayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_largeImageDisplayButton];
    
    _listDisplayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _listDisplayButton.dk_tintColorPicker = DKColorPickerWithKey(accent);
    [_listDisplayButton addTarget:self action:@selector(onListDisplayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_listDisplayButton];
    
    _categoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _categoryButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    _categoryButton.dk_tintColorPicker = DKColorPickerWithKey(accent);
    [_categoryButton addTarget:self action:@selector(onCategoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_categoryButton];
    
    self.largeImageDisplay = YES;
}

- (void)initConstraints {
    
    [_listDisplayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self);
        make.right.equalTo(self.mas_right).with.offset(-16);
        make.width.equalTo(@(38));
    }];
    
    [_largeImageDisplayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self);
        make.right.equalTo(_listDisplayButton.mas_left);
        make.width.equalTo(@(38));
    }];
    
    [_categoryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self);
        make.left.equalTo(self.mas_left).with.offset(16);
    }];
}

#pragma mark - Response Method

- (void)onListDisplayButtonClicked:(id)sender {
    self.largeImageDisplay = NO;
}

- (void)onLargeImageDisplayButtonClicked:(id)sender {
    self.largeImageDisplay = YES;
}

- (void)onCategoryButtonClicked:(id)sender {
    
}

#pragma mark - Setter

- (void)setLargeImageDisplay:(BOOL)largeImageDisplay {
    if (_largeImageDisplay==largeImageDisplay) {
        return;
    }
    
    _largeImageDisplay = largeImageDisplay;
    
    if (largeImageDisplay) {
        [_largeImageDisplayButton setImage:[UIImage imageNamed:@"tv_simple_highlight"] forState:UIControlStateNormal];
        [_listDisplayButton setImage:[UIImage imageNamed:@"tv_detail_normal"] forState:UIControlStateNormal];
    } else {
        [_largeImageDisplayButton setImage:[UIImage imageNamed:@"tv_simple_normal"] forState:UIControlStateNormal];
        [_listDisplayButton setImage:[UIImage imageNamed:@"tv_detail_highlight"] forState:UIControlStateNormal];
    }
    
    if (_changeDisplayBlock) {
        _changeDisplayBlock(largeImageDisplay);
    }
}

@end

@implementation TelevisionWallChannelNormalCell

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.layer.cornerRadius = 8;
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.contentView.layer.shadowOffset = CGSizeMake(0, 4);
        self.contentView.layer.shadowOpacity = 0.3;
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
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
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

@implementation TelevisionWallChannelDetailCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initConstaints];
    }
    return self;
}

- (void)initConstaints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.equalTo(self.contentView);
        make.width.equalTo(@((self.contentView.frame.size.height) * 16.0f/10.0f));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView).with.offset(8);
        make.right.equalTo(self.contentView);
        make.left.equalTo(self.imageView.mas_right).with.offset(8);
    }];
    
    [self.viewerCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(8);
        make.left.equalTo(self.titleLabel);
    }];
    
    [self layoutIfNeeded];
    [_imageView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(4, 4)];
}

- (void)setChannelBean:(TelevisionWallChannelBean *)channelBean {
    _channelBean = channelBean;
    
    __weak typeof(self) weakSelf = self;
    
    NSInteger timestamp = [[[NSDate alloc] init] timeIntervalSince1970]/60;
    NSString *previewUrl = [NSString stringWithFormat:@"%@?time=%ld", _channelBean.previewImageUrl, timestamp];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:previewUrl] placeholderImage:[UIImage imageNamed:@"neu_placeholder_16_9_gray"] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image||error) {
            return;
        }
        if (cacheType==SDImageCacheTypeNone || !weakSelf.channelBean.mainColor) {
            weakSelf.channelBean.mainColor = [image mainColor].compressRangeColor;
        }
    }];
    
    self.titleLabel.text = _channelBean.channelName;
    self.viewerCountLabel.text = [NSString stringWithFormat:@"%ld 人正在观看", _channelBean.viewerCount];
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 4;
        _imageView.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
        _imageView.layer.borderColor = [UIColor.blackColor colorWithAlphaComponent:0.3].CGColor;
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        _titleLabel.dk_textColorPicker = DKColorPickerWithKey(title);
        
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)viewerCountLabel {
    if (!_viewerCountLabel) {
        _viewerCountLabel = [[UILabel alloc] init];
        _viewerCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _viewerCountLabel.numberOfLines = 1;
        _viewerCountLabel.dk_textColorPicker = DKColorPickerWithKey(subtitle);
        
        [self.contentView addSubview:_viewerCountLabel];
    }
    return _viewerCountLabel;
}

@end

@implementation TelevisionWallChannelHeaderFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(16);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }
    return self;
}

- (UILabel *)headerLabel {
    if (!_headerLabel) {
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        _headerLabel.dk_textColorPicker = DKColorPickerWithKey(title);
        [self addSubview:_headerLabel];
    }
    return _headerLabel;
}

@end
