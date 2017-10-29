//
//  TelevisionDetailViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/23.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "TelevisionDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "LYTool.h"

#import "TelevisionChannelModel.h"
#import "CustomSectionHeaderFooterView.h"

@interface TelevisionPlayerView : UIView

@property (nonatomic, strong) UIView *containerView;
//@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AVPlayer *player;

- (instancetype)initWithUrl:(NSURL *)url;

@end

@implementation TelevisionPlayerView
{
    AVPlayerLayer *_playerLayer;
    BOOL _isPlaying;
}
#pragma mark - Init
- (instancetype)initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        self.url = url;
        self.backgroundColor = [UIColor clearColor];
        _isPlaying = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _playerLayer.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
//    _playBtn.frame = CGRectMake(0, 0, 80, 80);
//    [self.containerView bringSubviewToFront:self.playBtn];
}

#pragma mark - Response

- (void)didClickedPlayButton {
    if (_isPlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

#pragma mark - GETTER

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.userInteractionEnabled = YES;
        [self addSubview:_containerView];
    }
    return _containerView;
}

- (AVPlayer *)player {
    if (!_player) {
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:self.url];
        _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.containerView.layer addSublayer:_playerLayer];
    }
    return _player;
}

//- (UIButton *)playBtn {
//    if (!_playBtn) {
//        _playBtn = [[UIButton alloc] init];
//        [_playBtn addTarget:self action:@selector(didClickedPlayButton) forControlEvents:UIControlEventTouchUpInside];
//        _playBtn.backgroundColor = [UIColor greenColor];
//        [self.containerView addSubview:_playBtn];
//    }
//    return _playBtn;
//}

@end


@class TelevisionPlayerListCell;
const CGFloat kTelevisionDetailListHeaderHeight = 64.0f;
const CGFloat kTelevisionDetailListCellHeight = 80.0f;
NSString * const kTelevisionDetailListCellId = @"kTelevisionDetailListCellId";
NSString * const kTelevisionPlayingCellId = @"kTelevisionPlayingCellId";

@protocol TelevisionPlayerListCellDelegate

@required

- (void)prensentLookBackViewControllerFromTelevisionPlayerListCell:(TelevisionPlayerListCell *)cell;

@end

@interface TelevisionPlayerListCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLb;
@property (nonatomic, strong) UILabel *timeLb;
@property (nonatomic, strong) UIButton *backToViewBtn;
@property (nonatomic, strong) TelevisionChannelScheduleBean *scheduleBean;
@property (nonatomic, weak) id<TelevisionPlayerListCellDelegate> delegate;

- (void)setUpWithTelevisionChannelScheduleBean:(TelevisionChannelScheduleBean *)scheduleBean;

@end

@implementation TelevisionPlayerListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _scheduleBean = [[TelevisionChannelScheduleBean alloc] init];
        [self initConstaints];
    }
    return self;
}

- (void)initConstaints {
    [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(self.contentView).with.offset(10);
    }];
    [self.nameLb setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLb);
        make.top.equalTo(self.nameLb.mas_bottom).with.offset(10);
        make.bottom.equalTo(self.contentView).with.offset(-8);
    }];
    [self.backToViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.left.equalTo(self.nameLb.mas_right).with.offset(20);
        make.top.equalTo(self.nameLb);
    }];
    [self.backToViewBtn setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

}

- (void)setUpWithTelevisionChannelScheduleBean:(TelevisionChannelScheduleBean *)scheduleBean {
    _scheduleBean = scheduleBean;
    self.nameLb.text = self.scheduleBean.name;
    self.timeLb.text = self.scheduleBean.time;
}

- (void)didSelectBackToViewBtnWithTVShow {
    if (_delegate) {
        [_delegate prensentLookBackViewControllerFromTelevisionPlayerListCell:self];
    }
}

#pragma mark - GETTER

- (UILabel *)nameLb {
    if (!_nameLb) {
        _nameLb = [[UILabel alloc] init];
        _nameLb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _nameLb.textAlignment = NSTextAlignmentLeft;
        _nameLb.numberOfLines = 0;
        [self.contentView addSubview:_nameLb];
    }
    return _nameLb;
}

- (UILabel *)timeLb {
    if (!_timeLb) {
        _timeLb = [[UILabel alloc] init];
        _timeLb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _timeLb.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_timeLb];
    }
    return _timeLb;
}

- (UIButton *)backToViewBtn {
    if (!_backToViewBtn) {
        _backToViewBtn = [[UIButton alloc] init];
        _backToViewBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        _backToViewBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _backToViewBtn.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
        [_backToViewBtn addTarget:self action:@selector(didSelectBackToViewBtnWithTVShow) forControlEvents:UIControlEventTouchUpInside];
        [_backToViewBtn setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
        [_backToViewBtn setTitle:@"回看" forState:UIControlStateNormal];
        _backToViewBtn.layer.cornerRadius = 8;
        _backToViewBtn.alpha = 0.8;
        [self.contentView addSubview:_backToViewBtn];
    }
    return _backToViewBtn;
}

@end



@interface TelevisionDetailViewController () <UITableViewDelegate, UITableViewDataSource, TelevisionChannelModelDelegate, TelevisionPlayerListCellDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TelevisionPlayerView *playerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CustomSectionHeaderFooterView *headerView;
@property (nonatomic, strong) UIBarButtonItem *collectBarButtonItem;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) TelevisionChannelModel *channelDetailModel;
@property (nonatomic, strong) NSMutableArray <TelevisionChannelScheduleBean *> *beanArray; // 所有视频信息
@property (nonatomic, strong) NSArray *sourceArr; // 视频源字符串
@property (nonatomic, strong) NSString *sourceStr; // 正在使用的视频源字符串
@property (nonatomic, copy) NSArray <TelevisionChannelScheduleBean *> *playingArray; // 正在播放的视频

@end

@implementation TelevisionDetailViewController
{
    BOOL _isPlaying;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
    [self initConstraints];
    [self.tableView reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.indicatorView startAnimating];
    [self.playerView.player play];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.playerView.player pause];
}

#pragma mark - Init

- (void)initData {
    self.view.backgroundColor = [UIColor whiteColor];
    _isPlaying = YES;
    self.title = _channelBean.channelName;
    [self.channelDetailModel fecthTelevisionChannelDataWithVideoUrl:self.channelBean.sourceArray[0]];
    _beanArray = [NSMutableArray arrayWithCapacity:0];
    self.navigationItem.rightBarButtonItem = self.collectBarButtonItem;

}


- (void)initConstraints {
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.and.bottom.and.right.equalTo(self.view);
    }];
    
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.width.mas_equalTo(SCREEN_WIDTH_ACTUAL);
        make.height.mas_equalTo(self.playerView.mas_width).multipliedBy(9.0f/16.0f);
    }];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playerView);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playerView.mas_bottom);
        make.left.and.bottom.and.right.equalTo(self.scrollView);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - TelevisionPlayerListCellDelegate

- (void)prensentLookBackViewControllerFromTelevisionPlayerListCell:(TelevisionPlayerListCell *)cell {
    NSURL *url = [NSURL URLWithString:cell.scheduleBean.videoUrl];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.updatesNowPlayingInfoCenter = NO;;
    playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    [playerViewController.player play];
    
    [self presentViewController:playerViewController animated:YES completion:nil];
}

#pragma mark - TelevisionChannelModelDelegate
- (void)fetchTelevisionChannelModelFailureWithMsg:(NSString *)msg {
    NSLog(@"加载失败");
}

- (void)fetchTelevisionChannelModelSuccess {
    _beanArray = [self.channelDetailModel TelevisionChannelSelectionDayArrayWithType:TelevisionChannelModelSelectionTypeToday].copy;
    self.playingArray = _beanArray;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTelevisionDetailListHeaderHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.font = [UIFont systemFontOfSize:25 weight:5];
    header.textLabel.textColor = [UIColor blackColor];
    
    header.tintColor = [UIColor whiteColor];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    _headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTelevisionDetailListCellId];
    if (!_headerView) {
        _headerView = [[CustomSectionHeaderFooterView alloc] initWithReuseIdentifier:kTelevisionDetailListCellId];
    }

    _headerView.contentView.backgroundColor = [UIColor whiteColor];
    _headerView.section = section;
    
    __weak typeof(self) weakSelf = self;
    static NSString *dateBtnTitle = @"今天";
    static NSString *sourceBtnTitle = @"清华大学";
    
    if (section == 1) {
        [_headerView.actionButton setTitle:dateBtnTitle forState:UIControlStateNormal];
    } else {
        [_headerView.actionButton setTitle:sourceBtnTitle forState:UIControlStateNormal];
    }

    [self.headerView setPerformActionBlock:^(NSInteger section) {
        switch (section) {
            case 1:
            {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择节目日期" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                for (int i = 0; i < self.channelDetailModel.TelevisionChannelModelSelectionTypeArray.count; ++i) {
//                    获取节目日期类型
                    NSArray *allkey = [[weakSelf.channelDetailModel.TelevisionChannelModelSelectionTypeArray objectAtIndex:i] allKeys];
                    int dateType = [[allkey objectAtIndex:0] intValue];

//                    根据节目类型获取实际节目日期字符串
                    NSString *dateStr = [[weakSelf.channelDetailModel.TelevisionChannelModelSelectionTypeArray objectAtIndex:i] valueForKey:[NSString stringWithFormat:@"%d", i]];
                    NSString *date = [LYTool dateOfTimeIntervalFromToday:0];
                    if ([dateStr isEqualToString:date]) {
                        dateStr = @"今天";
                    }
                    date = [LYTool dateOfTimeIntervalFromToday:1];
                    if ([dateStr isEqualToString:date]) {
                        dateStr = @"昨天";
                    }
                    

                    [alertVC addAction:[UIAlertAction actionWithTitle:dateStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        _beanArray = (NSMutableArray *)[weakSelf.channelDetailModel TelevisionChannelSelectionDayArrayWithType:dateType];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.headerView.actionButton setTitle:dateStr forState:UIControlStateNormal];
                            dateBtnTitle = dateStr;
                            [weakSelf.tableView reloadData];
                        });
                    }]];
                }

                [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                [weakSelf presentViewController:alertVC animated:YES completion:^{
                }];
            }
                break;
            case 0:
            {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择视频源类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                for (int i = 0; i < self.sourceArr.count; ++i) {
                    //                    获取节目源类型的key，展示在sheet上
                    NSArray *allkey = [weakSelf.sourceArr[i] allKeys];
                    NSString *sourceType = allkey[0];
                    //                    根据节目源key获取节目源字符串
                    NSString *sourceStr = [weakSelf.sourceArr[i] valueForKey:sourceType];
                    [alertVC addAction:[UIAlertAction actionWithTitle:sourceType style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [weakSelf.channelDetailModel fecthTelevisionChannelDataWithVideoUrl:sourceStr];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            sourceBtnTitle = sourceType;
                            dateBtnTitle = @"今天";
                            [weakSelf.tableView reloadData];
                        });
                    }]];
                }
                [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                [weakSelf presentViewController:alertVC animated:YES completion:nil];
            }
            default:
                break;
        }
    }];
    
    if (section == 1) {
        [_headerView.actionButton setTitle:dateBtnTitle forState:UIControlStateNormal];
    } else {
        [_headerView.actionButton setTitle:sourceBtnTitle forState:UIControlStateNormal];
    }

    return _headerView;
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        TelevisionPlayerListCell *cell = [tableView dequeueReusableCellWithIdentifier:kTelevisionPlayingCellId];
        if (!cell) {
            cell = [[TelevisionPlayerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTelevisionPlayingCellId];
            cell.backToViewBtn.hidden = YES;
        }
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.nameLb.text = [self.playingArray lastObject].name;
            cell.timeLb.text = [self.playingArray lastObject].time;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        TelevisionPlayerListCell *cell = [tableView dequeueReusableCellWithIdentifier:kTelevisionDetailListCellId];
        
        if (!cell) {
            cell = [[TelevisionPlayerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTelevisionDetailListCellId];
        }
        [cell setUpWithTelevisionChannelScheduleBean:self.beanArray[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.beanArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"正在播放";
    } else {
        return @"节目单";
    }
}

#pragma mark - Response Method
- (void)didClickedCollectedButtonWithItem:(TelevisionChannelScheduleBean *)bean {
    
}

- (void)didSingleClickedPlayerView {
    if (_isPlaying) {
        [self.playerView.player pause];
        _isPlaying = NO;
    } else {
        [self.playerView.player play];
        _isPlaying = YES;
    }
}

- (void)didDoubleClickedPlayerView {
    
    if (_isPlaying) {
        _isPlaying = NO;
        [self.playerView.player pause];
    }
    
    NSURL *url = [NSURL URLWithString:self.sourceStr];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.updatesNowPlayingInfoCenter = NO;;
    playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [playerViewController.player play];
    playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self presentViewController:playerViewController animated:YES completion:nil];
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
        _playerView = [[TelevisionPlayerView alloc] initWithUrl:[NSURL URLWithString:self.sourceStr]];
//        点击暂停
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleClickedPlayerView)];
//        长按进入下一页播放
         UITapGestureRecognizer *doubleGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didDoubleClickedPlayerView)];
        doubleGestureRecognizer.numberOfTapsRequired = 2;
        [_playerView addGestureRecognizer:doubleGestureRecognizer];
        [_playerView addGestureRecognizer:gestureRecognizer];
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

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = kTelevisionDetailListCellHeight;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorColor = [UIColor clearColor];
        [_tableView setShowsVerticalScrollIndicator:NO];
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (TelevisionChannelModel *)channelDetailModel {
    if (!_channelDetailModel) {
        _channelDetailModel = [[TelevisionChannelModel alloc] init];
        _channelDetailModel.delegate = self;
    }
    return _channelDetailModel;
}

- (UIBarButtonItem *)collectBarButtonItem {
    if (!_collectBarButtonItem) {
        _collectBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(didClickedCollectedButtonWithItem:)];
    }
    return _collectBarButtonItem;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.playerView addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (NSArray *)sourceArr {
    if (!_sourceArr) {
        NSMutableArray *sourceMutableArr = [[NSMutableArray alloc] initWithCapacity:0];
        NSDictionary *tempDic = [[NSDictionary alloc] init];
        int i = 1;
        for (NSString *sourceType in _channelBean.sourceArray) {
            if ([sourceType rangeOfString:@"hls"].location != NSNotFound) {
                tempDic = @{
                            [NSString stringWithFormat:@"测试%d", i] : sourceType
                           };
                i++;
                
            } else if ([sourceType rangeOfString:@"jlu_"].location != NSNotFound) {
                tempDic = @{
                            @"吉林大学" : sourceType
                           };
            } else {
                tempDic = @{
                            @"清华大学" : sourceType
                            };
            }
            
            [sourceMutableArr addObject:tempDic];
        }
        
        _sourceArr = sourceMutableArr;
    }
    
    return _sourceArr;
}

- (NSString *)sourceStr {
    NSString *videoSourceTempStr = [@"http://media2.neu6.edu.cn/hls/" stringByAppendingString:self.channelDetailModel.sourceStr];
    NSString *videoSourceStr = [videoSourceTempStr stringByAppendingString:@".m3u8"];
    return videoSourceStr;
}

@end
