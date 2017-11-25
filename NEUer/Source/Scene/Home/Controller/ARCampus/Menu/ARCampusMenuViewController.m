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

@interface ARCampusMenuViewController ()

// 主视图
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIVisualEffectView *blurView;

// 用于动画的视图
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

// 内容视图
//@property (nonatomic, strong) UISegmentedControl *segmentedControl;
//@property (nonatomic, strong) UICollectionView *collectionView;
//@property (nonatomic, strong) NSArray<NSDictionary *> *cellDataArray;

@end

@implementation ARCampusMenuViewController {
    CGFloat _originY;
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
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(16+44+12);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.centerY.equalTo(self.contentView.mas_top).with.offset(64/2);
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
        if (origin.y > _originY) {
            origin.y = _viewBeginY - offset;
        } else {
            origin.y = _viewBeginY - offset*pow(0.3, (offset+_contentHeight)/_contentHeight);
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
    if (currentY > _originY+_contentHeight/5) {
        [self.contentView.layer removeAllAnimations];
        [self hideContentView];
    } else {
        [self showContentView];
    }
}

#pragma mark - Private Methods

- (void)showContentView {
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.width.and.height.equalTo(self.contentView.mas_width).multipliedBy(0.5);
        make.top.equalTo(self.contentView.mas_top).with.offset(32);
    }];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.75 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        self.maskView.alpha = 0.5;
        self.titleLabel.alpha = 0;
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
        self.titleLabel.alpha = 1;
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

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = _task.title;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

//- (UICollectionView *)collectionView {
//    if (!_collectionView) {
//        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//        CGFloat cellWidth = (SCREEN_WIDTH_ACTUAL - 32 - 16)/3;
//        CGFloat cellHeight = cellWidth;
//        flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
//        flowLayout.minimumLineSpacing = 8.0f;
//        flowLayout.minimumInteritemSpacing = 8.0f;
//        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
//        _collectionView.backgroundColor = [UIColor clearColor];
//        _collectionView.layer.masksToBounds = NO;
//        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kARCampusCollectionViewCellId];
//        //        [_panelCollectionView registerClass:[CustomSectionHeaderFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kARCampusCollectionViewSectionHeaderId];
//        _collectionView.delegate = self;
//        _collectionView.dataSource = self;
//        _collectionView.showsVerticalScrollIndicator = NO;
//        _collectionView.alwaysBounceVertical = YES;
//        _collectionView.alwaysBounceHorizontal = YES;
//        _collectionView.bounces = YES;
//        _collectionView.backgroundColor = [UIColor blueColor];
//        [self.contentView addSubview:_collectionView];
//    }
//
//    return _collectionView;
//}
//
//- (NSArray<NSDictionary *> *)cellDataArray {
//    if (!_cellDataArray) {
//        _cellDataArray = @[
//                           @{
//                               @"title":@"AR 校园",
//                               @"url":@"neu://go/ar",
//                               @"color":@"#DFC3BB",
//                               },
//                           @{
//                               @"title":@"一键联网",
//                               @"url":@"neu://handle/ipgw",
//                               @"color":@"#E7D1B4",
//                               },
//                           @{
//                               @"title":@"电视直播",
//                               @"url":@"neu://go/tv",
//                               @"color":@"#A2C9B4",
//                               },
//                           @{
//                               @"title":@"书刊查询",
//                               @"url":@"neu://go/lib",
//                               @"color":@"#A2C9B4",
//                               },
//                           @{
//                               @"title":@"校卡中心",
//                               @"url":@"neu://go/ecard",
//                               @"color":@"#92AFC0",
//                               },
//                           @{
//                               @"title":@"教务系统",
//                               @"url":@"neu://go/aao",
//                               @"color":@"#E7D1B4",
//                               },
//                           ];
//    }
//
//    return _cellDataArray;
//}

@end
