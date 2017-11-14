//
//  ARCampusMenuViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/13.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "ARCampusMenuViewController.h"

static NSString * const kARCampusCollectionViewCellId = @"kCellId";
static NSString * const kARCampusCollectionViewSectionHeaderId = @"kHeaderId";

@interface ARCampusMenuViewController ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;

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
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    _contentHeight = SCREEN_HEIGHT_ACTUAL*0.9;
    _maxAlpha = 0.5;
//    self.maskView.frame = CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL);
//    _originY = SCREEN_HEIGHT_ACTUAL - _contentHeight;
//    self.contentView.frame = CGRectMake(8, SCREEN_HEIGHT_ACTUAL, SCREEN_WIDTH_ACTUAL-16, SCREEN_HEIGHT_ACTUAL);
    
    [self initConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [self showContentView];
}

- (void)initConstraints {
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-64);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
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
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        self.maskView.alpha = 0.5;
        self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT_ACTUAL-_contentHeight, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL);
    } completion:nil];
}

- (void)hideContentView {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.maskView.alpha = 0;
        self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT_ACTUAL, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 16;
        [self.view addSubview:_contentView];
    }
    
    return _contentView;
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
