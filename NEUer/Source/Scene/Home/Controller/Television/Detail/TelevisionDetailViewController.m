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

typedef void(^DidAVPlayerControllerShowBlock)(void);
@interface TelevisionPlayerView : UIView

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy) DidAVPlayerControllerShowBlock didAVPlayerControllerShowBlock;

@property (nonatomic, strong) NSString *url;

- (void)setDidAVPlayerControllerShowBlock:(DidAVPlayerControllerShowBlock)didAVPlayerControllerShowBlock;
- (instancetype)initWithImgUrl:(NSString *)preImgUrl;

@end

@implementation TelevisionPlayerView

#pragma mark - Init
- (instancetype)initWithImgUrl:(NSString *)preImgUrl {
    if (self = [super init]) {
        NSInteger timestamp = [[[NSDate alloc] init] timeIntervalSince1970]/60;
        self.url = [NSString stringWithFormat:@"%@?time=%ld", preImgUrl, timestamp];
        [self initData];
        [self initConstaints];
    }
    
    return self;
}

- (void)initData {
    
    self.backgroundColor = [UIColor clearColor];

}

- (void)initConstaints {
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.imgView);
        make.height.and.width.equalTo(@60);
    }];
    [self.imgView bringSubviewToFront:self.playBtn];
    [self layoutIfNeeded];
    
}

#pragma mark - ResponseMethod
- (void)didClickedPlayButton {
    if (_didAVPlayerControllerShowBlock) {
        _didAVPlayerControllerShowBlock();
    }
}

#pragma mark - GETTER

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.backgroundColor = [UIColor clearColor];
        _imgView.userInteractionEnabled = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.hidden = NO;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *url = [NSURL URLWithString:self.url];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_imgView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(16, 16)];
                _imgView.image = img;
            });
        });

        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.contentMode = UIViewContentModeScaleAspectFit;
        _contentView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        _contentView.layer.shadowOffset = CGSizeMake(0, 4);
        _contentView.layer.shadowOpacity = 0.5;
        _contentView.backgroundColor = [UIColor blackColor];
        _contentView.layer.shadowRadius = 4;
        _contentView.layer.cornerRadius = 16;
        _contentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(16, 16)].CGPath;

        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn addTarget:self action:@selector(didClickedPlayButton) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.imgView addSubview:_playBtn];
    }
    return _playBtn;
}

#pragma mark - SETTER
- (void)setDidAVPlayerControllerShowBlock:(DidAVPlayerControllerShowBlock)didAVPlayerControllerShowBlock {
    _didAVPlayerControllerShowBlock = didAVPlayerControllerShowBlock;
}

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
        _nameLb.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
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
        _backToViewBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _backToViewBtn.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
        [_backToViewBtn addTarget:self action:@selector(didSelectBackToViewBtnWithTVShow) forControlEvents:UIControlEventTouchUpInside];
        [_backToViewBtn setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
        [_backToViewBtn setTitle:@"回看" forState:UIControlStateNormal];
        _backToViewBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _backToViewBtn.layer.cornerRadius = 16;
        _backToViewBtn.layer.borderColor = [UIColor beautyBlue].CGColor;
        _backToViewBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _backToViewBtn.layer.cornerRadius = 8;
        _backToViewBtn.alpha = 0.8;
        [self.contentView addSubview:_backToViewBtn];
    }
    return _backToViewBtn;
}

@end


static NSString *dateBtnTitle = @"今天";
static NSString *sourceBtnTitle = @"清华大学";
static TelevisionChannelModelSelectionType selectionType = TelevisionChannelModelSelectionTypeToday;

@interface TelevisionDetailViewController () <UITableViewDelegate, UITableViewDataSource, TelevisionChannelModelDelegate, TelevisionPlayerListCellDelegate>

@property (nonatomic, strong) TelevisionPlayerView *playerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CustomSectionHeaderFooterView *headerView;
@property (nonatomic, strong) UIBarButtonItem *collectBarButtonItem;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) TelevisionChannelModel *channelDetailModel;
@property (nonatomic, strong) NSMutableArray <TelevisionChannelScheduleBean *> *beanArray; // 所有视频信息
@property (nonatomic, strong) NSArray *sourceArr; // 视频源字符串
@property (nonatomic, strong) NSString *sourceStr; // 正在使用的视频源字符串
@property (nonatomic, copy) NSArray <TelevisionChannelScheduleBean *> *playingArray; // 正在播放的视频

@end

@implementation TelevisionDetailViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
    [self.tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    dateBtnTitle = @"今天";
    sourceBtnTitle = @"清华大学";
    selectionType = TelevisionChannelModelSelectionTypeToday;
}

#pragma mark - Init

- (void)initData {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = _channelBean.channelName;
    [self.channelDetailModel fecthTelevisionChannelDataWithVideoUrl:self.channelBean.sourceArray[0]];
    _beanArray = [NSMutableArray arrayWithCapacity:0];
    self.navigationItem.rightBarButtonItem = self.collectBarButtonItem;
    self.tableView.refreshControl = self.refreshControl;
    
    WS(ws);
    [self.playerView setDidAVPlayerControllerShowBlock:^{
        NSURL *url = [NSURL URLWithString:ws.sourceStr];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.updatesNowPlayingInfoCenter = NO;;
        playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        [playerViewController.player play];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        
        [ws presentViewController:playerViewController animated:YES completion:nil];
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
    dateBtnTitle = @"今天";
    selectionType = TelevisionChannelModelSelectionTypeToday;
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
                            selectionType = dateType;
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
        if (indexPath.row == self.beanArray.count - 1 && selectionType == TelevisionChannelModelSelectionTypeToday) {
            [cell.backToViewBtn setTitle:@"直播中..." forState:UIControlStateNormal];
            cell.scheduleBean.videoUrl = self.sourceStr;
        } else {
            [cell.backToViewBtn setTitle:@"回看" forState:UIControlStateNormal];
        }
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

- (void)beginRefreshing {
    [self.refreshControl beginRefreshing];
    [self.channelDetailModel fecthTelevisionChannelDataWithVideoUrl:self.channelDetailModel.sourceStr];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
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
        _playerView = [[TelevisionPlayerView alloc] initWithImgUrl:self.channelBean.previewImageUrl];
    }

    return _playerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_HEIGHT_ACTUAL)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = kTelevisionDetailListCellHeight;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView setShowsVerticalScrollIndicator:NO];
        _tableView.backgroundColor = [UIColor clearColor];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, SCREEN_WIDTH_ACTUAL * 0.6)];
        [headerView addSubview:self.playerView];
        [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(headerView);
            make.width.mas_equalTo(SCREEN_WIDTH_ACTUAL - 32);
            make.height.mas_equalTo(self.playerView.mas_width).multipliedBy(9.0f/16.0f);
        }];
        [headerView layoutIfNeeded];
        _tableView.tableHeaderView = headerView;
        _tableView.tableFooterView = [[UIView alloc] init];
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

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(beginRefreshing) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
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
