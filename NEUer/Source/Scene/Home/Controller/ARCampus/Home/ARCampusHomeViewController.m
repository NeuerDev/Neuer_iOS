//
//  ARCampusHomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/3.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "ARCampusHomeViewController.h"
#import "CustomSectionHeaderFooterView.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

static NSString * const kARCampusCollectionViewCellId = @"kCellId";
static NSString * const kARCampusCollectionViewSectionHeaderId = @"kHeaderId";

@interface ARCampusHomeViewController () <ARSCNViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) ARSession *arSession;
@property (nonatomic, strong) ARConfiguration *arConfiguration;
@property (nonatomic, strong) SCNNode *planeNode;

@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UIVisualEffectView *panelBackgroundView;
@property (nonatomic, strong) UISegmentedControl *panelSegmentedControl;
@property (nonatomic, strong) UICollectionView *panelCollectionView;
@property (nonatomic, strong) UIView *panelDragLine;
@property (nonatomic, strong) UILabel *panelTitleLabel;
@property (nonatomic, strong) UILabel *panelDetailLabel;

@property (nonatomic, strong) NSArray<NSDictionary *> *cellDataArray;

@end

@implementation ARCampusHomeViewController {
    CGFloat _originY;
    CGFloat _viewBeginY;
    CGFloat _touchBeginY;
    CGFloat _contentHeight;
    CGFloat _halfContentHeight;
    BOOL _beginTouchInCollectionView;
    BOOL _complete;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"AR 校园";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    [self initConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    //    [self.sceneView.session runWithConfiguration:self.arConfiguration options:0];
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.sceneView.session pause];
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
}

- (void)initData {
    CGFloat cellWidth = (SCREEN_WIDTH_ACTUAL - 32 - 16)/3;
    _contentHeight = CGRectGetHeight(self.view.frame) - [[UIApplication sharedApplication] statusBarFrame].size.height - 44 - 16;
    NSInteger rows = (_contentHeight+8-64-54)/(cellWidth+8);
    _contentHeight = rows*(cellWidth + 8) + 64 + 54;
    _halfContentHeight = cellWidth + 64 + 54;
    _originY = SCREEN_HEIGHT_ACTUAL - _contentHeight;
}

- (void)initConstraints {
    MASAttachKeys(self.panelView, self.panelBackgroundView, self.panelCollectionView, self.panelDragLine);
    [self.sceneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.panelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        make.height.mas_equalTo(@(_contentHeight+44));
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-64);
    }];
    
    [self.panelBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.panelView);
    }];
    
    [self.panelSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.panelCollectionView);
        make.centerY.equalTo(self.panelView.mas_top).with.offset(64+44/2);
    }];
    
    [self.panelCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.panelView).with.insets(UIEdgeInsetsMake(64+44, 16, 0, 16));
    }];
    
    [self.panelDragLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.panelView);
        make.centerY.equalTo(self.panelView.mas_top).with.offset(8);
        make.height.mas_equalTo(@5);
        make.width.mas_equalTo(@38);
    }];
    
    [self.view layoutIfNeeded];
    [self.panelBackgroundView roundCorners:UIRectCornerTopLeft|UIRectCornerTopRight radii:CGSizeMake(8, 8)];
    [self.panelDragLine roundCorners:UIRectCornerAllCorners radii:CGSizeMake(5.0f/2, 5.0f/2)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - ARSCNViewDelegate

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
    if ([anchor isMemberOfClass:[ARPlaneAnchor class]]) {
        NSLog(@"捕捉到平地");
        //添加一个3D平面模型，ARKit只有捕捉能力，锚点只是一个空间位置，要想更加清楚看到这个空间，我们需要给空间添加一个平地的3D模型来渲染他
        //1.获取捕捉到的平地锚点
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
        //2.创建一个3D物体模型    （系统捕捉到的平地是一个不规则大小的长方形，这里笔者将其变成一个长方形，并且是否对平地做了一个缩放效果）
        //参数分别是长宽高和圆角
        SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x height:0 length:planeAnchor.extent.x chamferRadius:0];
        //3.使用Material渲染3D模型（默认模型是白色的，这里笔者改成红色）
        plane.firstMaterial.diffuse.contents = [UIColor redColor];
        //4.创建一个基于3D物体模型的节点
        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
        //5.设置节点的位置为捕捉到的平地的锚点的中心位置  SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
        //self.planeNode = planeNode;
        [node addChildNode:planeNode];
        
        //2.当捕捉到平地时，2s之后开始在平地上添加一个3D模型
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //1.创建一个花瓶场景
            SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/nanhu/main_building/nanhu_main_building.scn"];
            //2.获取花瓶节点（一个场景会有多个节点，此处我们只写，花瓶节点则默认是场景子节点的第一个）
            //所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
            SCNNode *vaseNode = scene.rootNode.childNodes[0];
            //4.设置花瓶节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置，也就是相机位置
            vaseNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
            //5.将花瓶节点添加到当前屏幕中
            //!!!此处一定要注意：花瓶节点是添加到代理捕捉到的节点中，而不是AR试图的根节点。因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
            [node addChildNode:vaseNode];
        });
    }
}

//刷新时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    NSLog(@"刷新中");
}

//更新节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    NSLog(@"节点更新");
}

//移除节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    NSLog(@"节点移除");
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = [NSURL URLWithString:self.cellDataArray[indexPath.item][@"url"]];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kARCampusCollectionViewCellId forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithHexStr:self.cellDataArray[indexPath.item][@"color"]];
    //    cell.layer.shadowColor = [UIColor colorWithHexStr:self.cellDataArray[indexPath.item][@"color"]].CGColor;
//    cell.titleLabel.text = self.cellDataArray[indexPath.item][@"title"];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellDataArray.count;
}

#pragma mark - Response Methods


#pragma mark - Private Methods

- (void)showBuilding {
    SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/nanhu/main_building/nanhu_main_building.scn"];
    SCNNode *mainBuidingNode = scene.rootNode.childNodes[0];
    mainBuidingNode.position = SCNVector3Make(0, -0.1, -0.1);
    [self.sceneView.scene.rootNode addChildNode:mainBuidingNode];
}

- (void)showPanelAll {
    NSLog(@"showPanelAll");
    // 显示标题、简介和列表
    [self.panelView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-_contentHeight);
    }];
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)showPanelHalf {
    NSLog(@"showPanelHalf");
    // 显示标题、简介
    [self.panelView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-_halfContentHeight);
    }];
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)hidePanel {
    NSLog(@"hidePanel");
    // 只显示标题
    [self.panelView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-64);
    }];
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Touches Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([self isTouchInsideCollectionView:[touches anyObject]]) {
        _beginTouchInCollectionView = YES;
        return;
    } else {
        _beginTouchInCollectionView = NO;
    }
    _touchBeginY = [[touches anyObject] locationInView:self.view].y;
    _viewBeginY = CGRectGetMinY(self.panelView.frame);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (_beginTouchInCollectionView) {
        return;
    }
    CGFloat currentY = [[touches anyObject] locationInView:self.view].y;
    CGFloat offset = _touchBeginY - currentY;
    self.panelView.frame = ({
        CGRect frame = self.panelView.frame;
        CGPoint origin = self.panelView.frame.origin;
        if (_viewBeginY - offset <= CGRectGetHeight(self.view.frame) - 64) {
            if (_viewBeginY - offset >= _originY) {
                origin.y = _viewBeginY - offset;
            }
        }
        frame.origin = origin;
        frame;
    });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_beginTouchInCollectionView) {
        return;
    }
    CGFloat currentY = CGRectGetMinY(self.panelView.frame);
    if (currentY>CGRectGetHeight(self.view.frame) - _halfContentHeight) {
        // 处于隐藏和显示一部分之间
        if (currentY > CGRectGetHeight(self.view.frame) - _halfContentHeight/2) {
            [self hidePanel];
        } else {
            [self showPanelHalf];
        }
    } else {
        // 处于显示全部和显示一部分之间
        if (currentY > CGRectGetHeight(self.view.frame) - _halfContentHeight - (_contentHeight-_halfContentHeight)/2) {
            [self showPanelHalf];
        } else {
            [self showPanelAll];
        }
    }
}

- (BOOL)isTouchInsideCollectionView:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.view];
    point = [self.panelCollectionView.layer convertPoint:point fromLayer:self.view.layer];
    return [self.panelCollectionView.layer containsPoint:point];
}

#pragma mark - Getter

- (ARConfiguration *)arConfiguration {
    if (!_arConfiguration) {
        ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
        configuration.planeDetection = ARPlaneDetectionHorizontal;
        _arConfiguration = configuration;
        _arConfiguration.lightEstimationEnabled = YES;
    }
    
    return _arConfiguration;
}

- (ARSession *)arSession {
    if(!_arSession) {
        _arSession = [[ARSession alloc] init];
        self.sceneView.session = _arSession;
    }
    
    return _arSession;
}


- (ARSCNView *)sceneView {
    if (!_sceneView) {
        _sceneView = [[ARSCNView alloc] init];
        _sceneView.delegate = self;
        _sceneView.automaticallyUpdatesLighting = YES;
        _sceneView.autoenablesDefaultLighting = YES;
        _sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
        [self.view addSubview:_sceneView];
    }
    
    return _sceneView;
}

- (UIView *)panelView {
    if (!_panelView) {
        _panelView = [[UIView alloc] init];
        _panelView.layer.shadowColor = [UIColor blackColor].CGColor;
        _panelView.layer.shadowRadius = 2;
        _panelView.layer.shadowOffset = CGSizeMake(0, 0);
        _panelView.layer.shadowOpacity = 0.2;
        [self.view addSubview:_panelView];
    }
    
    return _panelView;
}

- (UISegmentedControl *)panelSegmentedControl {
    if (!_panelSegmentedControl) {
        _panelSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[
                                                                             @"校内导航",
                                                                             @"建筑模型",
                                                                             @"传送门",
                                                                             ]];
        _panelSegmentedControl.selectedSegmentIndex = 0;
        [self.panelView addSubview:_panelSegmentedControl];
    }
    
    return _panelSegmentedControl;
}

- (UIView *)panelDragLine {
    if (!_panelDragLine) {
        _panelDragLine = [[UIView alloc] init];
        _panelDragLine.backgroundColor = [UIColor lightGrayColor];
        [self.panelView addSubview:_panelDragLine];
    }
    
    return _panelDragLine;
}

- (UIVisualEffectView *)panelBackgroundView {
    if (!_panelBackgroundView) {
        _panelBackgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        [self.panelView addSubview:_panelBackgroundView];
    }
    
    return _panelBackgroundView;
}

- (UICollectionView *)panelCollectionView {
    if (!_panelCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = (SCREEN_WIDTH_ACTUAL - 32 - 16)/3;
        CGFloat cellHeight = cellWidth;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
        flowLayout.minimumLineSpacing = 8.0f;
        flowLayout.minimumInteritemSpacing = 8.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _panelCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _panelCollectionView.backgroundColor = [UIColor clearColor];
        _panelCollectionView.layer.masksToBounds = NO;
        [_panelCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kARCampusCollectionViewCellId];
//        [_panelCollectionView registerClass:[CustomSectionHeaderFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kARCampusCollectionViewSectionHeaderId];
        _panelCollectionView.delegate = self;
        _panelCollectionView.dataSource = self;
        _panelCollectionView.showsVerticalScrollIndicator = NO;
        _panelCollectionView.alwaysBounceVertical = YES;
        _panelCollectionView.alwaysBounceHorizontal = YES;
        _panelCollectionView.bounces = YES;
        _panelCollectionView.backgroundColor = [UIColor blueColor];
        [self.panelView addSubview:_panelCollectionView];
    }
    
    return _panelCollectionView;
}

- (NSArray<NSDictionary *> *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = @[
                           @{
                               @"title":@"AR 校园",
                               @"url":@"neu://go/ar",
                               @"color":@"#DFC3BB",
                               },
                           @{
                               @"title":@"一键联网",
                               @"url":@"neu://handle/ipgw",
                               @"color":@"#E7D1B4",
                               },
                           @{
                               @"title":@"电视直播",
                               @"url":@"neu://go/tv",
                               @"color":@"#A2C9B4",
                               },
                           @{
                               @"title":@"书刊查询",
                               @"url":@"neu://go/lib",
                               @"color":@"#A2C9B4",
                               },
                           @{
                               @"title":@"校卡中心",
                               @"url":@"neu://go/ecard",
                               @"color":@"#92AFC0",
                               },
                           @{
                               @"title":@"教务系统",
                               @"url":@"neu://go/aao",
                               @"color":@"#E7D1B4",
                               },
                           ];
    }
    
    return _cellDataArray;
}

@end
