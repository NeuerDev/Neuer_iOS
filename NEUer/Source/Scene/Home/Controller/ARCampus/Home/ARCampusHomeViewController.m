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
#import "ARPlane.h"

#import <AVFoundation/AVFoundation.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

typedef NS_ENUM(NSUInteger, ARCampusViewState) {
    ARCampusViewStateNone,                              // 初始状态
    ARCampusViewStateNotSupportARKit,                   // 不支持ARKit
    ARCampusViewStateCameraDisable,                     // 相机访问受限
    ARCampusViewStateCameraRunning,                     // 相机开始运行
    ARCampusViewStateSessionInitializing,               // 初始化ARKit
    ARCampusViewStateSearchingPlane,                    // 正在搜索平面
    ARCampusViewStateSearchingPlaneNeedFeature,         // 正在搜索平面 特征点太少
    ARCampusViewStateSearchingPlaneExcessiveMovement,   // 正在搜索平面 需要移动
    ARCampusViewStateReadyToPlaceObject,                // 搜索完成 可以放置物体
    ARCampusViewStateObjectPlaced,                      // 已放置物体
};

@interface ARCampusHomeViewController () <ARSCNViewDelegate, ARSessionDelegate, ARSessionObserver, ARCampusMenuViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) ARCampusViewState viewState;

@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) ARSession *arSession;
@property (nonatomic, strong) ARConfiguration *arConfiguration;
@property (nonatomic, strong) NSMutableDictionary<NSUUID *, ARPlane *> *planes;
@property (nonatomic, strong) NSMutableArray<SCNNode *> *nodes;

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
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"ARCampusTitle", nil);
    self.view.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    self.baseContentView.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    self.navigationBarBackgroundView.hidden = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self initConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self checkARKitAbility]) {
        if ([self checkCameraAccess]) {
            self.viewState = ARCampusViewStateCameraRunning;
        } else {
            self.viewState = ARCampusViewStateCameraDisable;
        }
    } else {
        self.viewState = ARCampusViewStateNotSupportARKit;
    }
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

#pragma mark - ARSessionDelegate

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    switch (error.code) {
        case ARErrorCodeCameraUnauthorized:
            self.viewState = ARCampusViewStateCameraDisable;
            break;
            
        default:
            break;
    }
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera {
    NSLog(@"%ld", camera.trackingStateReason);
    if (self.viewState >= ARCampusViewStateReadyToPlaceObject) {
        return;
    }
    switch (camera.trackingStateReason) {
        case ARTrackingStateReasonNone:
        {
            self.viewState = ARCampusViewStateSearchingPlane;
        }
            break;
        case ARTrackingStateReasonInitializing:
        {
            self.viewState = ARCampusViewStateSessionInitializing;
        }
            break;
        case ARTrackingStateReasonExcessiveMotion:
        {
            self.viewState = ARCampusViewStateSearchingPlaneExcessiveMovement;
        }
            break;
        case ARTrackingStateReasonInsufficientFeatures:
        {
            self.viewState = ARCampusViewStateSearchingPlaneNeedFeature;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - ARSCNViewDelegate

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    
    self.viewState = ARCampusViewStateReadyToPlaceObject;
    SCNMaterial *material = [[SCNMaterial alloc] init];
    material.lightingModelName = SCNLightingModelPhysicallyBased;
    material.diffuse.contents = [UIColor.beautyYellow colorWithAlphaComponent:0.3f];
    ARPlane *plane = [[ARPlane alloc] initWithAnchor: (ARPlaneAnchor *)anchor isHidden: NO withMaterial:material];
    [self.planes setObject:plane forKey:anchor.identifier];
    [node addChildNode:plane];
}

//刷新时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    //    NSLog(@"刷新中");
}

//更新节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    ARPlane *plane = [self.planes objectForKey:anchor.identifier];
    if (plane == nil) {
        return;
    }
    
    // 更新平面信息
    [plane update:(ARPlaneAnchor *)anchor];
}

//移除节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    [self.planes removeObjectForKey:anchor.identifier];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    // 首次渲染的时候才显示场景
    if (!_didSceneAppeared && self.viewState>=ARCampusViewStateCameraRunning) {
        _didSceneAppeared = YES;
        [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.sceneView.alpha = 1;
        } completion:nil];
    }
    
    ARLightEstimate *estimate = self.sceneView.session.currentFrame.lightEstimate;
    if (!estimate) {
        return;
    }
    
    CGFloat intensity = estimate.ambientIntensity / 1000.0;
    self.sceneView.scene.lightingEnvironment.intensity = intensity;
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Private Methods

- (void)refresh {
    
}

- (BOOL)checkCameraAccess {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return (authStatus == AVAuthorizationStatusNotDetermined || authStatus == AVAuthorizationStatusAuthorized);
}

- (BOOL)checkARKitAbility {
    JHDeviceType deviceType = [UIDevice currentDevice].deviceType;
    return deviceType>=iPhone_6S;
}

- (void)placeBuildingAtTapPoint:(CGPoint)tapPoint {
    NSArray<ARHitTestResult *> *result = [self.sceneView hitTest:tapPoint types:ARHitTestResultTypeExistingPlaneUsingExtent];
    
    if (result.count == 0) {
        return;
    }
    
    ARHitTestResult *hitResult = [result firstObject];
    [self placeBuildingWithHitResult:hitResult];
}

- (void)placeBuildingWithHitResult:(ARHitTestResult *)hitResult {
    SCNVector3 position = SCNVector3Make(
                                         hitResult.worldTransform.columns[3].x,
                                         hitResult.worldTransform.columns[3].y,
                                         hitResult.worldTransform.columns[3].z
                                         );
    SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/nanhu/main_building/nanhu_main_building.scn"];
    SCNNode *building = scene.rootNode.childNodes[0];
    building.position = position;
    [self.sceneView.scene.rootNode addChildNode:building];
    self.viewState = ARCampusViewStateObjectPlaced;
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

- (void)onSceneViewLongPressed:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self placeBuildingAtTapPoint:[longPress locationInView:self.sceneView]];
    }
}

- (void)onPanelViewSwipped:(UISwipeGestureRecognizer *)swipped {
    [self showMenu];
}

- (void)onPanelViewTapped:(UITapGestureRecognizer *)tap {
    [self showMenu];
}

#pragma mark - Override

- (void)onBaseRetryButtonClicked:(UIButton *)sender {
    switch (self.viewState) {
        case ARCampusViewStateCameraDisable:
        {
            NSString *urlString = UIApplicationOpenSettingsURLString;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        }
            break;
        case ARCampusViewStateNotSupportARKit:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Setter

- (void)setViewState:(ARCampusViewState)viewState {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (viewState) {
            case ARCampusViewStateNotSupportARKit:
            {
                self.baseViewState = JHBaseViewStateError;
                self.baseStateTitleLabel.text = @"无法运行 AR";
                self.baseStateDetailLabel.text = @"请换一台 iPhone6s 及以上机型并升级到 iOS11 以上版本再来试试吧";
            }
                break;
            case ARCampusViewStateCameraDisable:
            {
                self.baseViewState = JHBaseViewStateRequireCameraAccess;
            }
                break;
            case ARCampusViewStateCameraRunning:
            {
                self.baseViewState = JHBaseViewStateNormal;
                [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.navigationController.navigationBar.alpha = 0;
                } completion:^(BOOL finished) {
                    _didNavigationBarHidden = YES;
                }];
                [self.sceneView.session runWithConfiguration:self.arConfiguration options:0];
                [UIApplication.sharedApplication setIdleTimerDisabled:YES];
                if (!_didSceneAppeared) {
                    _didSceneAppeared = YES;
                    [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.sceneView.alpha = 1;
                    } completion:nil];
                }
            }
                break;
            case ARCampusViewStateSessionInitializing:
            {
                self.hintLabel.text = @"正在初始化虚拟现实引擎";
            }
                break;
            case ARCampusViewStateSearchingPlane:
            {
                self.hintLabel.text = @"正在了解你的环境 稍微移动一下手机";
            }
                break;
            case ARCampusViewStateSearchingPlaneNeedFeature:
            {
                self.hintLabel.text = @"请到光线充足并且平面反射少的地方再试试";
            }
                break;
            case ARCampusViewStateSearchingPlaneExcessiveMovement:
            {
                self.hintLabel.text = @"你的手机移动太快了 慢一点";
            }
                break;
            case ARCampusViewStateReadyToPlaceObject:
            {
                if (_viewState>ARCampusViewStateReadyToPlaceObject) {
                    return;
                }
                self.sceneView.debugOptions = SCNDebugOptionNone;
                self.hintLabel.text = @"长按屏幕在平面上放置一个模型吧";
            }
                break;
            case ARCampusViewStateObjectPlaced:
            {
                self.hintLabel.text = @"";
            }
                break;
                
            default:
                break;
        }
    });
    _viewState = viewState;
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

- (NSMutableDictionary<NSUUID *, ARPlane *> *)planes {
    if (!_planes) {
        _planes = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return _planes;
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
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onSceneViewLongPressed:)];
        longPress.delegate = self;
        longPress.numberOfTouchesRequired = 1;
        longPress.minimumPressDuration = 1;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSceneViewTapped:)];
        tap.delegate = self;
        [tap requireGestureRecognizerToFail:longPress];
        [_sceneView addGestureRecognizer:tap];
        [_sceneView addGestureRecognizer:longPress];
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
        [self.sceneView addSubview:_panelView];
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
        [self.sceneView addSubview:_hintLabel];
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
