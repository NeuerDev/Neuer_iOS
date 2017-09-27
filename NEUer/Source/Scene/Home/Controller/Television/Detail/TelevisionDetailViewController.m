//
//  TelevisionDetailViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/23.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TelevisionDetailViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "TelevisionChannelModel.h"

@interface TelevisionPlayerView : UIView
- (instancetype)initWithUrl:(NSURL *)url;
@end

@implementation TelevisionPlayerView
- (instancetype)initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
    }
    
    return self;
}
@end

@interface TelevisionPlayerListView : UIView
- (instancetype)initWithTitle:(NSString *)title schedules:(NSArray<TelevisionChannelScheduleBean *> *)schedules;
@end

@implementation TelevisionPlayerListView

- (instancetype)initWithTitle:(NSString *)title schedules:(NSArray<TelevisionChannelScheduleBean *> *)schedules{
    if (self = [super init]) {
        self.backgroundColor = [UIColor greenColor];
    }
    
    return self;
}
@end

@interface TelevisionDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TelevisionPlayerView *playerView;

@end

@implementation TelevisionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = _channelBean.channelName;
//    AVAsset *liveAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:@"http://media2.neu6.edu.cn/hls/1506264876-5395a3caa1f0f02d2e7c274134f26836/cctv5hd.m3u8"] options:nil];
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
//    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
//    playerLayer.frame = self.view.layer.bounds;
//    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    [self.view.layer addSublayer:playerLayer];
//    [player play];
    
    [self initConstraints];
}

- (void)initConstraints {
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView.mas_top);
        make.width.mas_equalTo(SCREEN_WIDTH_ACTUAL);
        make.height.mas_equalTo(self.playerView.mas_width).multipliedBy(9.0f/16.0f);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.and.bottom.and.right.equalTo(self.view);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Override Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Getter

- (TelevisionPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[TelevisionPlayerView alloc] initWithUrl:[NSURL URLWithString:_channelBean.videoUrlArray[0]]];
        [self.view addSubview:_playerView];
    }
    
    return _playerView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_scrollView];
    }
    
    return _scrollView;
}

@end
