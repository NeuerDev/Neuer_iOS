//
//  ARCampusMenuViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/13.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "ARCampusMenuViewController.h"
#import "ARCampusTask.h"

static NSString * const kARCampusCollectionViewCellId = @"kCellId";
static NSString * const kARCampusCollectionViewSectionHeaderId = @"kHeaderId";

@interface ARCampusMenuViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

// 主视图
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIVisualEffectView *blurView;

// 用于动画的视图
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *previousTitleLabel;
@property (nonatomic, strong) UILabel *currentTitleLabel;

// 内容视图
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSDictionary *> *cellDataArray;

@end

@implementation ARCampusMenuViewController {
    CGFloat _viewBeginY;
    CGFloat _touchBeginY;
    CGFloat _contentHeight;
    CGFloat _maxAlpha;
    CGFloat _bottomMargin;
    CGFloat _topMargin;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.delegate menuWillShow];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showContentView];
}

- (void)initData {
    if ([UIDevice currentDevice].deviceType == Global_iPhone_X || [UIDevice currentDevice].deviceType == Chinese_iPhone_X) {
        _bottomMargin = 34.0f;
    } else {
        _bottomMargin = 0.0f;
    }
    _topMargin = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 32;
    _contentHeight = SCREEN_HEIGHT_ACTUAL - _topMargin;
    _maxAlpha = 0.5;
    self.navigationBarBackgroundView.hidden = YES;
}

- (void)initConstraints {
    self.maskView.frame = self.view.frame;
    self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT_ACTUAL-_bottomMargin-64, SCREEN_WIDTH_ACTUAL, _contentHeight);
    
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.height.and.width.mas_equalTo(@44);
        make.centerY.equalTo(self.contentView.mas_top).with.offset(64/2);
    }];
    
    [self.previousTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(16+44+12);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.centerY.equalTo(self.contentView.mas_top).with.offset(64/2);
    }];
    
    CGFloat initialOffset = 64.0f;
    
    [self.currentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView.mas_top).with.offset(32.0f + SCREEN_WIDTH_ACTUAL/2 + 16.0f + initialOffset);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.currentTitleLabel.mas_bottom).with.offset(16);
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
}

#pragma mark - Touches Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _touchBeginY = [[touches anyObject] locationInView:self.view].y;
    _viewBeginY = CGRectGetMinY(self.contentView.frame);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    CGFloat currentY = [[touches anyObject] locationInView:self.view].y;
    CGFloat offset = _touchBeginY - currentY;
    self.contentView.frame = ({
        CGRect frame = self.contentView.frame;
        CGPoint origin = self.contentView.frame.origin;
        if (origin.y > _topMargin) {
            origin.y = _viewBeginY - offset;
            if (origin.y < _topMargin) {
                origin.y = _topMargin;
            }
        } else if (origin.y == _topMargin && offset <= 0) {
            origin.y = _viewBeginY - offset;
        }
        frame.origin = origin;
        frame;
    });
    CGFloat percent = (SCREEN_HEIGHT_ACTUAL - CGRectGetMinY(self.contentView.frame))/_contentHeight;
    self.maskView.alpha = percent*_maxAlpha;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    CGFloat currentY = CGRectGetMinY(self.contentView.frame);
    if (currentY > _topMargin+_contentHeight/5) {
        [self.contentView.layer removeAllAnimations];
        [self hideContentView];
    } else {
        [self showContentView];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kARCampusCollectionViewCellId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSArray *)self.cellDataArray[section][@"data"]).count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.cellDataArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView* reusableView;
    if (kind == UICollectionElementKindSectionHeader) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kARCampusCollectionViewSectionHeaderId forIndexPath:indexPath];
        NSInteger labelTag = 1923;
        UILabel *label = [reusableView viewWithTag:labelTag];
        if (!label) {
            UILabel *titleLabel = [[UILabel alloc] init];
            [reusableView addSubview:titleLabel];
        }
    }
    
    reusableView.backgroundColor = [UIColor orangeColor];
    
    return reusableView;
}

#pragma mark - Private Methods

- (void)showContentView {
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.width.and.height.mas_equalTo(SCREEN_WIDTH_ACTUAL/2);
        make.top.equalTo(self.contentView.mas_top).with.offset(32);
    }];
    
    [self.currentTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView.mas_top).with.offset(32.0f + SCREEN_WIDTH_ACTUAL/2 + 16.0f);
    }];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.75 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        self.maskView.alpha = 0.5;
        self.previousTitleLabel.alpha = 0;
        self.currentTitleLabel.alpha = 1;
        self.contentView.frame = CGRectMake(0, _topMargin, SCREEN_WIDTH_ACTUAL, _contentHeight);
        [self.contentView layoutIfNeeded];
    } completion:nil];
}

- (void)hideContentView {
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.height.and.width.mas_equalTo(@44);
        make.centerY.equalTo(self.contentView.mas_top).with.offset(64/2);
    }];
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.75 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.maskView.alpha = 0;
        self.previousTitleLabel.alpha = 1;
        self.currentTitleLabel.alpha = 0;
        self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT_ACTUAL-_bottomMargin-64, SCREEN_WIDTH_ACTUAL, _contentHeight);
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate menuDidHide];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter

- (void)setTask:(ARCampusTask *)task {
    _task = task;
    
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self.view addSubview:_contentView];
    }
    
    return _contentView;
}

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
        [self.contentView addSubview:_blurView];
    }
    
    return _blurView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0;
        [self.view addSubview:_maskView];
    }
    
    return _maskView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:_task.image];
        _imageView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UILabel *)previousTitleLabel {
    if (!_previousTitleLabel) {
        _previousTitleLabel = [[UILabel alloc] init];
        _previousTitleLabel.text = _task.title;
        _previousTitleLabel.numberOfLines = 0;
        _previousTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.contentView addSubview:_previousTitleLabel];
    }
    
    return _previousTitleLabel;
}


- (UILabel *)currentTitleLabel {
    if (!_currentTitleLabel) {
        _currentTitleLabel = [[UILabel alloc] init];
        _currentTitleLabel.text = _task.title;
        _currentTitleLabel.numberOfLines = 0;
        _currentTitleLabel.alpha = 0;
        _currentTitleLabel.textAlignment = NSTextAlignmentCenter;
        _currentTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        [self.contentView addSubview:_currentTitleLabel];
    }
    
    return _currentTitleLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = (SCREEN_WIDTH_ACTUAL - 32 - 16)/3;
        CGFloat cellHeight = cellWidth;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
        flowLayout.minimumLineSpacing = 8.0f;
        flowLayout.minimumInteritemSpacing = 8.0f;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 8, 0);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.headerReferenceSize = CGSizeMake(CGFLOAT_MAX, 44);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kARCampusCollectionViewCellId];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kARCampusCollectionViewSectionHeaderId];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:_collectionView];
    }
    
    return _collectionView;
}

- (NSArray<NSDictionary *> *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = @[
                           @{
                               @"type":@(ARCampusTaskTypeBuilding),
                               @"data":@[
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       ],
                               },
                           @{
                               @"type":@(ARCampusTaskTypeTunnel),
                               @"data":@[
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       ],
                               },
                           @{
                               @"type":@(ARCampusTaskTypeGuide),
                               @"data":@[
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       @{
                                           @"title":@"",
                                           @"image":@"",
                                           @"description":@"",
                                           },
                                       ],
                               },
                           ];
    }
    
    return _cellDataArray;
}

@end
