//
//  SearchLibraryResultViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/21.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchLibraryResultViewController.h"

#import "SearchLibraryResultModel.h"

#import "TouchableCollectionViewCell.h"

static NSString * const kCellId = @"kCellId";
static NSString * const kHeaderId = @"kHeaderId";
static NSString * const kFooterId = @"kFooterId";

const CGFloat kCellHeight = 128.0f;
const CGFloat kHeaderHeight = 44.0f;
const CGFloat kFooterHeight = 44.0f;
const CGFloat kButtonWidth = 72.0f;
const CGFloat kButtonHeight = 28.0f;
const NSInteger kPreloadThreshold = 3;

@interface SearchLibraryResultReuseView : UICollectionReusableView
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *textLabel;

- (void)animate:(BOOL)animate;

@end

@implementation SearchLibraryResultReuseView

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    [self.indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

#pragma mark - Public Methods

- (void)animate:(BOOL)animate {
    if (animate) {
        [self.indicator startAnimating];
    } else {
        [self.indicator stopAnimating];
    }
}

#pragma mark - Getter

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_indicator];
    }
    
    return _indicator;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor grayColor];
        _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        [self addSubview:_textLabel];
    }
    
    return _textLabel;
}

@end

@interface LibraryResultCell : TouchableCollectionViewCell
@property (nonatomic, strong) SearchLibraryResultBean *resultBean;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *callNumberLabel;

@property (nonatomic, strong) UIView *detailView;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) UIButton *collectionButton;
@property (nonatomic, strong) UILabel *locationLabel;

@end

@implementation LibraryResultCell

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.layer.cornerRadius = 16;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowRadius = 4;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.frame byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(16, 16)].CGPath;
        
        [self.contentView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(16, 16)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.infoLabel];
        [self.contentView addSubview:self.visualEffectView];
        [self.contentView addSubview:self.detailView];
        [self.contentView addSubview:self.titleLabel];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    
    // 图片
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(self.contentView).with.offset(8);
        make.height.and.width.mas_equalTo(@(kCellHeight-16));
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(kCellHeight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-8);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(8);
    }];
    
    // 模糊层
    [self.visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    // 详细 view
    [self.callNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom);
    }];
    
    [self.collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.equalTo(self.detailView);
        make.bottom.equalTo(self.detailView).with.offset(-14);
        make.width.mas_equalTo(@(kButtonWidth));
        make.height.mas_equalTo(@(kButtonHeight));
    }];
    
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.detailView).with.offset(-14);
        make.left.equalTo(self.titleLabel.mas_left);
    }];
    
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(24);
        make.right.equalTo(self.contentView).with.offset(-24);
        make.bottom.equalTo(self.contentView);
    }];
    
    // 普通状态下的 view
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(kCellHeight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-8);
        make.top.equalTo(self.contentView.mas_top).with.offset(24);
    }];
}

#pragma mark - Overide Methods

- (void)touchedUpInside {
    [super touchedUpInside];
    self.resultBean.showDetail = !self.resultBean.showDetail;
    [self applyDisplayModeAnimated:YES];
}

#pragma mark - Animation

- (void)applyDisplayModeAnimated:(BOOL)animated {
    NSTimeInterval interval = 1.0f/3.0f;
    
    //  高斯模糊动画
    if (_resultBean.showDetail) {
        _visualEffectView.hidden = NO;
        _visualEffectView.alpha = 1;
        _visualEffectView.effect = nil;
        _detailView.hidden = NO;
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).with.offset(24);
            make.right.equalTo(self.contentView.mas_right).with.offset(-24);
            make.top.equalTo(self.contentView.mas_top).with.offset(14);
        }];
        
        if (animated) {
            [UIView animateWithDuration:interval animations:^{
                _visualEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
                _detailView.alpha = 1;
                [self.contentView layoutIfNeeded];
            } completion:nil];
        } else {
            _visualEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            _detailView.alpha = 1;
        }
    } else {
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).with.offset(kCellHeight);
            make.right.equalTo(self.contentView.mas_right).with.offset(-8);
            make.top.equalTo(self.contentView.mas_top).with.offset(24);
        }];
        
        if (animated) {
            [UIView animateWithDuration:interval animations:^{
                _visualEffectView.alpha = 0;
                _detailView.alpha = 0;
                [self.contentView layoutIfNeeded];
            } completion:^(BOOL finished) {
                _visualEffectView.hidden = YES;
                _detailView.hidden = YES;
                _visualEffectView.effect = nil;
            }];
        } else {
            _visualEffectView.alpha = 0;
            _detailView.alpha = 0;
            _visualEffectView.hidden = YES;
            _detailView.hidden = YES;
            _visualEffectView.effect = nil;
        }
    }
}

#pragma mark - Setter

- (void)setResultBean:(SearchLibraryResultBean *)result {
    _resultBean = result;
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_resultBean.imageUrl] placeholderImage:[UIImage imageNamed:@"neu_placeholder_1_1_white"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    _titleLabel.text = _resultBean.title;
    NSMutableString *info = _resultBean.author ? [NSMutableString stringWithFormat:@"%@\n", _resultBean.author] : @"".mutableCopy;
    if (_resultBean.press.length>0 && _resultBean.year.length>0) {
        [info appendString:[NSString stringWithFormat:@"%@/%@", _resultBean.press, _resultBean.year]];
    } else {
        [info appendString:[NSString stringWithFormat:@"%@%@", _resultBean.press, _resultBean.year]];
    }
    _infoLabel.text = info.copy;
    
    _callNumberLabel.text = [NSString stringWithFormat:@"索书号: %@", _resultBean.callNumber];
    if (_resultBean.collected) {
        [_collectionButton setTitle:@"已收藏" forState:UIControlStateNormal];
        [_collectionButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    } else {
        [_collectionButton setTitle:@"收藏" forState:UIControlStateNormal];
        [_collectionButton setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
    }
    
    _locationLabel.text = _resultBean.stockLocation;
    [self applyDisplayModeAnimated:NO];
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.hidden = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _titleLabel.numberOfLines = 2;
    }
    
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [UIColor grayColor];
        _infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _infoLabel.numberOfLines = 0;
    }
    
    return _infoLabel;
}

- (UILabel *)callNumberLabel {
    if (!_callNumberLabel) {
        _callNumberLabel = [[UILabel alloc] init];
        _callNumberLabel.textColor = [UIColor grayColor];
        _callNumberLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _callNumberLabel.numberOfLines = 1;
        [self.detailView addSubview:_callNumberLabel];
    }
    
    return _callNumberLabel;
}

- (UIView *)detailView {
    if (!_detailView) {
        _detailView = [[UIView alloc] init];
        _detailView.hidden = YES;
    }
    
    return _detailView;
}

- (UIVisualEffectView *)visualEffectView {
    if (!_visualEffectView) {
        _visualEffectView = [[UIVisualEffectView alloc] init];
        _visualEffectView.alpha = 0;
        _visualEffectView.hidden = YES;
    }
    
    return _visualEffectView;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.textColor = [UIColor grayColor];
        _locationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _locationLabel.numberOfLines = 0;
        _locationLabel.textAlignment = NSTextAlignmentLeft;
        [self.detailView addSubview:_locationLabel];
    }
    
    return _locationLabel;
}

- (UIButton *)collectionButton {
    if (!_collectionButton) {
        _collectionButton = [[UIButton alloc] init];
        _collectionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _collectionButton.layer.cornerRadius = kButtonHeight/2;
        _collectionButton.layer.borderColor = [UIColor beautyBlue].CGColor;
        _collectionButton.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.detailView addSubview:_collectionButton];
    }
    
    return _collectionButton;
}

@end

@interface SearchLibraryResultViewController () <SearchLibraryResultDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
@property (nonatomic, strong) SearchLibraryResultModel *resultModel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) SearchLibraryResultReuseView *footerView;
@end

@implementation SearchLibraryResultViewController {
    NSInteger _currentCellsCount;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"SearchLibraryResultNavigationBarTitle", nil);
    self.view.backgroundColor = [UIColor clearColor];
    
    [self initConstraints];
}

- (void)initConstraints {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Public Methods

- (void)searchWithKeyword:(NSString *)keyword scope:(NSInteger)scope {
    [self.resultModel searchWithKeyword:keyword scope:scope];
    [self setHeaderTitle:NSLocalizedString(@"SearchLibraryResultSearching", nil) animating:NO];
    [self setFooterTitle:@"" animating:YES];
    [self clear];
}

- (void)loadMore {
    if (self.resultModel.hasMore) {
        [self.resultModel loadMore];
    }
}

- (void)clear {
    [self.collectionView reloadData];
}

#pragma mark - Private Methods

- (void)setHeaderTitle:(NSString *)headerTitle animating:(BOOL)animated {
    SearchLibraryResultReuseView *reuseHeaderView = (SearchLibraryResultReuseView *)[self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [reuseHeaderView animate:animated];
    reuseHeaderView.textLabel.text = headerTitle;
}

- (void)setFooterTitle:(NSString *)footerTitle animating:(BOOL)animated {
    SearchLibraryResultReuseView *reuseFooterView = (SearchLibraryResultReuseView *)[self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [reuseFooterView animate:animated];
    reuseFooterView.textLabel.text = footerTitle;
}

#pragma mark - SearchLibraryResultDelegate

- (void)searchWillComplete {
    _currentCellsCount = self.resultModel.resultsArray.count;
}

- (void)searchDidSuccess {
    [self setHeaderTitle:self.resultModel.hint animating:NO];
    if (self.resultModel.hasMore) {
        [self setFooterTitle:@"" animating:YES];
    } else if (self.resultModel.resultsArray.count>0) {
        [self setFooterTitle:NSLocalizedString(@"SearchLibraryResultReachedEnd", nil) animating:NO];
    } else {
        [self setFooterTitle:@"" animating:NO];
    }
    
    if (_currentCellsCount!=self.resultModel.resultsArray.count) {
        NSMutableArray<NSIndexPath *> *array = @[].mutableCopy;
        for (NSInteger item=_currentCellsCount; item<self.resultModel.resultsArray.count; item++) {
            [array addObject:[NSIndexPath indexPathForItem:item inSection:0]];
        }
        [self.collectionView insertItemsAtIndexPaths:array];
    }
}

- (void)searchDidFail:(NSString *)message {
    [self setHeaderTitle:message animating:NO];
    [self setFooterTitle:@"" animating:NO];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LibraryResultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.resultBean = self.resultModel.resultsArray[indexPath.item];
    if ((self.resultModel.resultsArray.count-indexPath.item-1)<kPreloadThreshold) {
        [self loadMore];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId forIndexPath:indexPath];
        [((SearchLibraryResultReuseView *)reusableView) animate:NO];
        ((SearchLibraryResultReuseView *)reusableView).textLabel.text = self.resultModel.hint;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterId forIndexPath:indexPath];
        if (self.resultModel.hasMore) {
            [((SearchLibraryResultReuseView *)reusableView) animate:YES];
            ((SearchLibraryResultReuseView *)reusableView).textLabel.text = @"";
        } else if (self.resultModel.resultsArray.count>0) {
            [((SearchLibraryResultReuseView *)reusableView) animate:NO];
            ((SearchLibraryResultReuseView *)reusableView).textLabel.text = NSLocalizedString(@"SearchLibraryResultReachedEnd", nil);
        } else {
            [((SearchLibraryResultReuseView *)reusableView) animate:NO];
            ((SearchLibraryResultReuseView *)reusableView).textLabel.text = @"";
        }
    }
    return reusableView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultModel.resultsArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH_ACTUAL-32, kCellHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 16, 8, 16);
        flowLayout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), kHeaderHeight);
        flowLayout.footerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), kFooterHeight);
        flowLayout.minimumLineSpacing = 16.0f;
        flowLayout.minimumInteritemSpacing = 8.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.contentInset = ({
            CGFloat topMargin = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 99;
            UIEdgeInsetsMake(topMargin, 0, 0, 0);
        });
        [_collectionView registerClass:[LibraryResultCell class] forCellWithReuseIdentifier:kCellId];
        [_collectionView registerClass:[SearchLibraryResultReuseView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId];
        [_collectionView registerClass:[SearchLibraryResultReuseView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterId];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollsToTop = YES;
        [self.view addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (SearchLibraryResultModel *)resultModel {
    if (!_resultModel) {
        _resultModel = [[SearchLibraryResultModel alloc] init];
        _resultModel.delegate = self;
    }
    
    return _resultModel;
}

@end
