//
//  ARCampusHomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/3.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "ARCampusHomeViewController.h"
#import "ARCampusMenuViewController.h"
#import "ARCampusTask.h"

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

typedef NS_ENUM(NSUInteger, ARCampusViewState) {
    ARCampusViewStateNotSupportARKit,
    ARCampusViewStateCameraDisable,
    ARCampusViewStateInitializing,
    ARCampusViewStateSearchingPlane,
    ARCampusViewStateReadyToPlaceObject,
    ARCampusViewStateObjectPlaced,
};

@interface ARCampusHomeViewController () <ARSCNViewDelegate, ARSessionDelegate, ARSessionObserver, ARCampusMenuViewControllerDelegate>

@property (nonatomic, assign) ARCampusViewState viewState;

@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) ARSession *arSession;
@property (nonatomic, strong) ARConfiguration *arConfiguration;
@property (nonatomic, strong) SCNNode *planeNode;

@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UIVisualEffectView *panelMaskView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *hintLabel;

@property (nonatomic, strong) ARCampusTask *currentTask;
@end

@implementation ARCampusHomeViewController {
    BOOL _didSceneAppeared;
    BOOL _didNavigationBarHidden;
    BOOL _didFoundPlane;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"AR 校园";
    self.view.backgroundColor = [UIColor blackColor];
    self.baseViewState = JHBaseViewStateRequireCameraAccess;
    [self initConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self.sceneView.session runWithConfiguration:self.arConfiguration options:0];
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.navigationController.navigationBar.alpha = 0;
    } completion:^(BOOL finished) {
        _didNavigationBarHidden = YES;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBar.alpha = 1;
    } completion:^(BOOL finished) {
        _didNavigationBarHidden = NO;
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.sceneView.session pause];
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
}

- (void)initConstraints {
    self.sceneView.frame = self.view.frame;
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-64-8);
        make.centerX.equalTo(self.view);
    }];
    
    [self.panelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-64);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
    }];
    
    [self.panelMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.panelView);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.panelView.mas_left).with.offset(16);
        make.height.and.width.mas_equalTo(@44);
        make.centerY.equalTo(self.panelView.mas_top).with.offset(64/2);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.panelView.mas_left).with.offset(16+44+12);
        make.right.equalTo(self.panelView.mas_right).with.offset(-16);
        make.centerY.equalTo(self.panelView.mas_top).with.offset(64/2);
    }];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
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
        NSLog(@"x:%f---y:%f---z:%f", planeAnchor.extent.x, planeAnchor.extent.y, planeAnchor.extent.z);
        SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x height:0 length:planeAnchor.extent.z chamferRadius:0];
        //3.使用Material渲染3D模型（默认模型是白色的，这里笔者改成红色）
        plane.firstMaterial.diffuse.contents = [[UIColor redColor] colorWithAlphaComponent:0.2];
        //4.创建一个基于3D物体模型的节点
        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
        //5.设置节点的位置为捕捉到的平地的锚点的中心位置  SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
        //self.planeNode = planeNode;
        [node addChildNode:planeNode];
        
//        //2.当捕捉到平地时，2s之后开始在平地上添加一个3D模型
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            //1.创建一个花瓶场景
//            SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/nanhu/main_building/nanhu_main_building.scn"];
//            //2.获取花瓶节点（一个场景会有多个节点，此处我们只写，花瓶节点则默认是场景子节点的第一个）
//            //所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
//            SCNNode *vaseNode = scene.rootNode.childNodes[0];
//            //4.设置花瓶节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置，也就是相机位置
//            vaseNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
//            //5.将花瓶节点添加到当前屏幕中
//            //!!!此处一定要注意：花瓶节点是添加到代理捕捉到的节点中，而不是AR试图的根节点。因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
//            [node addChildNode:vaseNode];
//        });
    }
}

//刷新时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    NSLog(@"刷新中");
}

//更新节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    NSLog(@"节点更新");
}

//移除节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    NSLog(@"节点移除");
}

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    // 首次渲染的时候才显示场景
    if (!_didSceneAppeared) {
        _didSceneAppeared = YES;
        [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.sceneView.alpha = 1;
        } completion:nil];
    }
    
    // 更新光源亮度
    ARLightEstimate *estimate = self.sceneView.session.currentFrame.lightEstimate;
    if (!estimate) {
        return;
    } else {
//        estimate.ambientIntensity
//        NSLog(@"estimate %f", estimate.ambientIntensity);
    }
}

#pragma mark - ARSessionDelegate

#pragma mark - ARCampusMenuViewControllerDelegate

- (void)menuWillShow {
    self.panelView.hidden = YES;
}

- (void)menuDidHide {
    self.panelView.hidden = NO;
}

- (void)menuTaskChanged:(ARCampusTask *)task {
    self.currentTask = task;
}

#pragma mark - Private Methods

- (void)showAllowCameraUsageGuide {
    
}

- (void)showARKitUnsupportView {
    
}

- (void)showBuilding {
    SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/nanhu/main_building/nanhu_main_building.scn"];
    SCNNode *mainBuidingNode = scene.rootNode.childNodes[0];
    mainBuidingNode.position = SCNVector3Make(0, -0.1, -0.1);
    [self.sceneView.scene.rootNode addChildNode:mainBuidingNode];
}

- (void)showMenu {
    ARCampusMenuViewController *menuViewController = [[ARCampusMenuViewController alloc] init];
    menuViewController.modalPresentationStyle = UIModalPresentationCustom;
    menuViewController.delegate = self;
    menuViewController.task = self.currentTask;
    [self presentViewController:menuViewController animated:NO completion:nil];
}

#pragma mark - Response Methods

- (void)onSceneViewTapped:(UITapGestureRecognizer *)tap {
    [self.navigationController.navigationBar.layer removeAllAnimations];
    CGFloat alpha = _didNavigationBarHidden ? 1 : 0;
    _didNavigationBarHidden = !_didNavigationBarHidden;
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBar.alpha = alpha;
    }];
}

- (void)onPanelViewSwipped:(UISwipeGestureRecognizer *)swipped {
    [self showMenu];
}

- (void)onPanelViewTapped:(UITapGestureRecognizer *)tap {
    [self showMenu];
}

#pragma mark - Setter

- (void)setViewState:(ARCampusViewState)viewState {
    _viewState = viewState;
    switch (viewState) {
        case ARCampusViewStateNotSupportARKit:
        {
            
        }
            break;
        case ARCampusViewStateCameraDisable:
        {
            
        }
            break;
        case ARCampusViewStateInitializing:
        {
            
        }
            break;
        case ARCampusViewStateSearchingPlane:
        {
            
        }
            break;
        case ARCampusViewStateReadyToPlaceObject:
        {
            
        }
            break;
        case ARCampusViewStateObjectPlaced:
        {
            
        }
            break;
            
        default:
            break;
    }
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
        _arSession.delegate = self;
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
        _sceneView.alpha = 0;
        _sceneView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
        _sceneView.userInteractionEnabled = YES;
        [_sceneView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSceneViewTapped:)]];
        [self.view addSubview:_sceneView];
    }
    
    return _sceneView;
}

- (UIView *)panelView {
    if (!_panelView) {
        _panelView = [[UIView alloc] init];
        _panelView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPanelViewTapped:)];
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onPanelViewSwipped:)];
        swipe.direction = UISwipeGestureRecognizerDirectionUp;
        
        [_panelView addGestureRecognizer:tap];
        [_panelView addGestureRecognizer:swipe];
        [self.view addSubview:_panelView];
    }
    
    return _panelView;
}

- (UIVisualEffectView *)panelMaskView {
    if (!_panelMaskView) {
        _panelMaskView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
        [self.panelView addSubview:_panelMaskView];
    }
    
    return _panelMaskView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor redColor];
        [self.panelView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = self.currentTask.title;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.panelView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.text = @"正在探索你的环境";
        _hintLabel.numberOfLines = 0;
        _hintLabel.textColor = [UIColor whiteColor];
        _hintLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _hintLabel.layer.shadowOpacity = 0.5;
        _hintLabel.layer.shadowRadius = 1;
        _hintLabel.layer.shadowOffset = CGSizeMake(0, 0);
        _hintLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        [self.view addSubview:_hintLabel];
    }
    
    return _hintLabel;
}

- (ARCampusTask *)currentTask {
    if (!_currentTask) {
        _currentTask = [[ARCampusTask alloc] init];
        _currentTask.type = ARCampusTaskTypeBuilding;
        _currentTask.title = @"东北大学信息楼（主楼）";
    }
    
    return _currentTask;
}

@end
