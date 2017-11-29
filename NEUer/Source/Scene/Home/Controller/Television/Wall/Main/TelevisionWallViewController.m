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

#import "SpringCollectionViewLayout.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "TelevisionWallModel.h"

#import "TouchableCollectionViewCell.h"

#define SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)

typedef void(^TelevisionWallChannelChangeStateViewSetActionBlock)(NSInteger tag);

static NSString * const kChannelNormalCellId = @"kChannelNormalCellId";
static NSString * const kChannelDetailCellId = @"kChannelDetailCellId";
//static NSString * const kChannelHeaderFooterView = @"kChannelHeaderFooterView";
static NSString * const kChannelWordHeaderFooterView = @"kChannelWordHeaderFooterView";

@interface TelevisionWallChannelChangeStateView : UIView
@property (nonatomic, strong) UIButton *normalButton;
@property (nonatomic, strong) UIButton *detailButton;
@property (nonatomic, strong) UIView *contentView;

- (void)setActionBlock:(TelevisionWallChannelChangeStateViewSetActionBlock)block;

@end
@implementation TelevisionWallChannelChangeStateView
{
    TelevisionWallChannelChangeStateViewSetActionBlock _block;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initConstaints];
    }
    return self;
}

- (void)initConstaints {
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(28 * 2 + 16));
        make.top.equalTo(self).with.offset(8);
        make.bottom.equalTo(self).with.offset(-8);
    }];
    [self.normalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.bottom.equalTo(self.contentView);
        make.width.equalTo(@(28));
    }];
    [self.detailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.and.bottom.equalTo(self.contentView);
        make.width.equalTo(@(28));
    }];
}

- (void)setActionBlock:(TelevisionWallChannelChangeStateViewSetActionBlock)block {
    _block = block;
}

- (void)didClickedChangeViewButtonWithTag:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (_block) {
        _block(tag);
    }
}

#pragma mark - Getter

- (UIButton *)normalButton {
    if (!_normalButton) {
        _normalButton =[[UIButton alloc] init];
        UIImage *image = [UIImage imageNamed:@"TV_normal"];
        [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_normalButton setImage:image forState:UIControlStateNormal];
        _normalButton.tintColor = [JHTool colorWithHexStr:@"#fcbf50"];
        _normalButton.tag = 001;
        [_normalButton addTarget:self action:@selector(didClickedChangeViewButtonWithTag:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_normalButton];
    }
    return _normalButton;
}

- (UIButton *)detailButton {
    if (!_detailButton) {
        _detailButton = [[UIButton alloc] init];
        [_detailButton setImage:[UIImage imageNamed:@"TV_detail"] forState:UIControlStateNormal];
        _detailButton.tag = 002;
        [_detailButton addTarget:self action:@selector(didClickedChangeViewButtonWithTag:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_detailButton];
    }
    return _detailButton;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
    }
    return _contentView;
}

@end

@interface TelevisionWallChannelWordHeaderFooterView : UICollectionReusableView
@property (nonatomic, strong) UILabel *headerLabel;

@end
@implementation TelevisionWallChannelWordHeaderFooterView

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
        
        [self addSubview:_headerLabel];
    }
    return _headerLabel;
}

@end

@interface TelevisionWallChannelNormalCell : TouchableCollectionViewCell
@property (nonatomic, strong) TelevisionWallChannelBean *channelBean;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *viewerCountLabel;

@end

@implementation TelevisionWallChannelNormalCell

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

@interface TelevisionWallChannelDetailCell : UICollectionViewCell
@property (nonatomic, strong) TelevisionWallChannelBean *channelBean;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *viewerCountLabel;

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
        make.width.equalTo(@((self.contentView.frame.size.height) * 16.0f/9.0f));
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
}

- (void)setChannelBean:(TelevisionWallChannelBean *)channelBean {
    _channelBean = channelBean;
    
    __weak typeof(self)weakSelf=self;
    
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
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 1.0;
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
        _imageView.layer.cornerRadius = 8;
        _imageView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        _imageView.layer.shadowOffset = CGSizeMake(0, 4);
        _imageView.layer.shadowOpacity = 0.5;
        _imageView.layer.shadowRadius = 4;
        _imageView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_imageView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        _titleLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)viewerCountLabel {
    if (!_viewerCountLabel) {
        _viewerCountLabel = [[UILabel alloc] init];
        _viewerCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _viewerCountLabel.numberOfLines = 1;
        _viewerCountLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_viewerCountLabel];
    }
    return _viewerCountLabel;
}

@end

@interface TelevisionWallViewController () <TelevisionWallDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchViewController;

@property (nonatomic, strong) TelevisionWallModel *wallModel;
@property (nonatomic, strong) GatewayCenter *center;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TelevisionWallChannelChangeStateView *changeStateView;
@property (nonatomic, strong) UIBarButtonItem *sortBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *orderedBarButtonItem;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation TelevisionWallViewController
{
    NSString *_sourceName;
    BOOL _isOneLargeImageDisplay;
    BOOL _reachStatusFlag;
    BOOL _isFirstTimeShowView;
    BOOL _isShowCollectionItems;
    NSInteger _collectionItemCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initConstraints];

}

- (void)viewWillAppear:(BOOL)animated {
    if (!_isFirstTimeShowView) {
        [UIView animateWithDuration:0.7 animations:^{
            [self.collectionView reloadData];
        }];
    }
    _isFirstTimeShowView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (void)initData {
    
    self.title = NSLocalizedString(@"TelevisionWallTitle", nil);
    self.navigationItem.rightBarButtonItems = @[self.sortBarButtonItem, self.orderedBarButtonItem];
    if (@available(iOS 11.0, *)) {
#ifdef __IPHONE_11_0
        self.navigationItem.searchController = self.searchViewController;
        [self.navigationItem setHidesSearchBarWhenScrolling:YES];
#endif
    } else {
        
    }
    
    _isOneLargeImageDisplay = YES;
    _isShowCollectionItems = NO;
    _isFirstTimeShowView = YES;
    _collectionItemCount = 0;
    
    [self p_checkNetworkStatusBox];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedNetworkStatusChangeNotification:) name:kGatewayNetworkStatusChangeNotification object:nil];
    
    WS(ws);
    [self.changeStateView setActionBlock:^(NSInteger tag) {
        switch (tag) {
            case 001:
            {
                _isOneLargeImageDisplay = YES;
                ws.flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH-32.0f, (SCREEN_WIDTH-32.0f)*9.0f/16.0f);
                [ws.collectionView reloadData];
            }
                break;
            case 002:
            {
                _isOneLargeImageDisplay = NO;
                ws.flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH - 32.0f, 120);
                [ws.collectionView reloadData];
            }
            default:
                break;
        }
    }];
    
    [self.wallModel fetchWallData];

}

- (instancetype)initWithUrl:(NSURL *)url params:(NSDictionary *)params {
    if (self = [super init]) {
        if ([params objectForKey:@"sourcename"]) {
            _sourceName = [params objectForKey:@"sourcename"];
        }
        self.title = NSLocalizedString(@"TelevisionWallTitle", nil);
        if (@available(iOS 11.0, *)) {
#ifdef __IPHONE_11_0
            self.navigationItem.searchController = self.searchViewController;
            [self.navigationItem setHidesSearchBarWhenScrolling:YES];
#endif
        } else {
            
        }
    }
    return self;
}

- (void)initConstraints {

    self.collectionView.frame = self.view.frame;
}

#pragma mark - Response Method

- (void)didReceivedNetworkStatusChangeNotification:(NSNotification *)notification {
    
    [self.center testCampusEnvironment:^(BOOL isCampus) {
        if (isCampus) {
            // 处于校园网环境
            dispatch_async(dispatch_get_main_queue(), ^{
                _reachStatusFlag = YES;
                [self setBaseViewState:JHBaseViewStateNormal];
                [self.collectionView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                _reachStatusFlag = NO;
                [self setBaseViewState:JHBaseViewStateConnectionLost];
                [self.collectionView reloadData];
            });
        }
    }];
}


- (void)changeChannelType {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择频道类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof(self) weakSelf = self;
    for (NSString *channelType in self.wallModel.channelTypeArray) {
        [alertVC addAction:[UIAlertAction actionWithTitle:channelType style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.wallModel setCurrentTypeWithName:channelType];
            weakSelf.sortBarButtonItem.title = channelType;
            if (weakSelf.wallModel.currentType != TelevisionChannelTypeAll) {
                _isShowCollectionItems = NO;
            } else {
                _isShowCollectionItems = YES;
            }
            [weakSelf.collectionView reloadData];
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
    
    [self.collectionView reloadData];
    
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


#pragma mark - Override
- (void)onBaseRetryButtonClicked:(UIButton *)sender {
    [self p_checkNetworkStatusBox];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    if (!self.searchViewController.active) {
        self.changeStateView.hidden = NO;
    } else {
        self.changeStateView.hidden = YES;
        _isShowCollectionItems = NO;
    }
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
    detailVC.wallModel = self.wallModel;
    
    if (_isShowCollectionItems && indexPath.section == 0) {
        detailVC.channelBean = self.wallModel.collectionArray[indexPath.item];
    } else {
        if (self.searchViewController.active) {
            detailVC.channelBean = self.wallModel.resultArray[indexPath.item];
        } else {
            detailVC.channelBean = self.wallModel.channelArray[indexPath.item];
        }
    }
    
    self.searchViewController.active = NO;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_isShowCollectionItems && section == 0) {
        return CGSizeMake(SCREEN_WIDTH_ACTUAL, 64);
    } else {
        return CGSizeMake(SCREEN_WIDTH_ACTUAL, 44);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    TelevisionWallChannelWordHeaderFooterView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kChannelWordHeaderFooterView forIndexPath:indexPath];
    if (kind == UICollectionElementKindSectionHeader && _isShowCollectionItems) {
        if (indexPath.section == 0) {
            headerView.headerLabel.text = @"收藏频道";
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
    
    if (_isShowCollectionItems) {
        if (indexPath.section == 0) {
            if (_isOneLargeImageDisplay) {
                TelevisionWallChannelNormalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelNormalCellId forIndexPath:indexPath];
                cell.channelBean = self.wallModel.collectionArray[indexPath.item];
                return cell;
            
            } else {
                TelevisionWallChannelDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelDetailCellId forIndexPath:indexPath];
                cell.channelBean = self.wallModel.collectionArray[indexPath.item];
                return cell;
            }
        } else {
            if (_isOneLargeImageDisplay) {
                TelevisionWallChannelNormalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelNormalCellId forIndexPath:indexPath];
                cell.channelBean = self.wallModel.channelArray[indexPath.item];
                return cell;
                
            } else {
                TelevisionWallChannelDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelDetailCellId forIndexPath:indexPath];
                cell.channelBean = self.wallModel.channelArray[indexPath.item];
                return cell;
            }
        }
    } else {
        if (_isOneLargeImageDisplay) {
            TelevisionWallChannelNormalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelNormalCellId forIndexPath:indexPath];
            if (self.searchViewController.active) {
                if (self.wallModel.resultArray.count != 0) {
                    cell.channelBean = self.wallModel.resultArray[indexPath.item];
                }
            } else{
                cell.channelBean = self.wallModel.channelArray[indexPath.item];
            }
            
            return cell;
        } else {
            TelevisionWallChannelDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChannelDetailCellId forIndexPath:indexPath];
            if (self.searchViewController.active) {
                if (self.wallModel.resultArray.count != 0) {
                    cell.channelBean = self.wallModel.resultArray[indexPath.item];
                }
            }else{
                cell.channelBean = self.wallModel.channelArray[indexPath.item];
            }
            
            return cell;
        }
    }
    return nil;
}

- (void)extracted {
    [self setBaseViewState:JHBaseViewStateConnectionLost];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!_reachStatusFlag) {
        [self setBaseViewState:JHBaseViewStateConnectionLost];
        return 0;
    } else {
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

#pragma mark - Private Method

- (void)p_checkNetworkStatusBox {
    _center = [GatewayCenter defaultCenter];
    if (self.center.networkEnable && self.center.campusStatus == GatewayStatusYES) {
        _reachStatusFlag = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    } else {
        _reachStatusFlag = NO;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请检查是否在校园网环境内" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

#pragma mark - Getter

- (UISearchController *)searchViewController {
    if (!_searchViewController) {
        _searchViewController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchViewController.delegate = self;
        _searchViewController.dimsBackgroundDuringPresentation = YES;
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
        _flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH-32.0f, (SCREEN_WIDTH-32.0f)*9.0f/16.0f);
        
        [_collectionView registerClass:[TelevisionWallChannelNormalCell class] forCellWithReuseIdentifier:kChannelNormalCellId];
        [_collectionView registerClass:[TelevisionWallChannelDetailCell class] forCellWithReuseIdentifier:kChannelDetailCellId];
        [_collectionView registerClass:[TelevisionWallChannelWordHeaderFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kChannelWordHeaderFooterView];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 44)];
        [headerView addSubview:self.changeStateView];
        [self.changeStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(headerView);
        }];
        [_collectionView addSubview:headerView];
        [headerView layoutIfNeeded];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollsToTop = YES;
        [self.view addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16);
        _flowLayout.minimumLineSpacing = 24.0f;
        _flowLayout.minimumInteritemSpacing = 8.0f;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}


- (UIBarButtonItem *)sortBarButtonItem {
    if (!_sortBarButtonItem) {
        _sortBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.wallModel.channelTypeArray[0] style:UIBarButtonItemStylePlain target:self action:@selector(changeChannelType)];
    }
    
    return _sortBarButtonItem;
}

- (UIBarButtonItem *)orderedBarButtonItem {
    if (!_orderedBarButtonItem) {
        _orderedBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TV_order"]  style:UIBarButtonItemStylePlain target:self action:@selector(manageTheOrderedShows)];
    }
    return _orderedBarButtonItem;
}

- (TelevisionWallChannelChangeStateView *)changeStateView {
    if (!_changeStateView) {
        _changeStateView = [[TelevisionWallChannelChangeStateView alloc] init];
    }
    return _changeStateView;
}

@end
