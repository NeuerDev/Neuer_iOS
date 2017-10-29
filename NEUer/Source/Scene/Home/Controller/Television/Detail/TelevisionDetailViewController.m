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

@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) TelevisionWallChannelBean *channelBean;

- (instancetype)init;

@end

@implementation TelevisionPlayerView

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = 8;
        self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 4;
        [self initConstaints];
    }
    
    return self;
}

- (void)initConstaints {
    [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.previewImageView);
    }];
    
    [self.previewImageView bringSubviewToFront:self.maskImageView];
}

#pragma mark - Setter

- (void)setChannelBean:(TelevisionWallChannelBean *)channelBean {
    _channelBean = channelBean;
    WS(ws);
    NSInteger timestamp = [[[NSDate alloc] init] timeIntervalSince1970]/60;
    NSString *previewUrl = [NSString stringWithFormat:@"%@?time=%ld", channelBean.previewImageUrl, timestamp];
    [self.previewImageView sd_setImageWithURL:[NSURL URLWithString:previewUrl] placeholderImage:[UIImage imageNamed:@"neu_placeholder_16_9_gray"] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image||error) {
            return;
        }
        
        ws.backgroundColor = [UIColor clearColor];
        
        if (cacheType==SDImageCacheTypeNone || !ws.channelBean.mainColor) {
            ws.channelBean.mainColor = [image mainColor].compressRangeColor;
            ws.layer.shadowColor = ws.channelBean.mainColor.CGColor;
        } else {
            ws.layer.shadowColor = ws.channelBean.mainColor.CGColor;
        }
    }];
}

#pragma mark - Getter

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.backgroundColor = [UIColor blackColor];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        _previewImageView.layer.cornerRadius = 8;
        _previewImageView.layer.masksToBounds = YES;
        [self addSubview:_previewImageView];
    }
    
    return _previewImageView;
}

- (UIImageView *)maskImageView {
    if (!_maskImageView) {
        _maskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play"]];
        _maskImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _maskImageView.userInteractionEnabled = YES;
        _maskImageView.contentMode = UIViewContentModeCenter;
        [self.previewImageView addSubview:_maskImageView];
    }
    
    return _maskImageView;
}

@end


@class TelevisionPlayerListCell;

const CGFloat kTelevisionDetailListHeaderHeight = 44.0f;
const CGFloat kTelevisionDetailListCellHeight = 64.0f;

NSString * const kTelevisionDetailListCellId = @"kTelevisionDetailListCellId";
NSString * const kTelevisionDetailListHeaderViewId = @"kTelevisionDetailListHeaderViewId";
NSString * const kTelevisionPlayingCellId = @"kTelevisionPlayingCellId";

@protocol TelevisionPlayerListCellDelegate

@required

- (void)prensentLookBackViewControllerFromTelevisionPlayerListCell:(TelevisionPlayerListCell *)cell;

@end

@interface TelevisionPlayerListCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *backToViewBtn;
@property (nonatomic, strong) UIView *centerView;
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
    [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.backToViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.centerView);
        make.centerY.equalTo(self.nameLabel);
        make.height.mas_equalTo(@(28.0f));
        make.width.mas_equalTo(@(72.0f));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.equalTo(self.centerView);
        make.right.equalTo(self.backToViewBtn.mas_left).with.offset(-8);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.equalTo(self.centerView);
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(4);
    }];
}

- (void)setUpWithTelevisionChannelScheduleBean:(TelevisionChannelScheduleBean *)scheduleBean {
    _scheduleBean = scheduleBean;
    self.nameLabel.text = self.scheduleBean.name;
    self.timeLabel.text = self.scheduleBean.time;
}

- (void)didSelectBackToViewBtnWithTVShow {
    if (_delegate) {
        [_delegate prensentLookBackViewControllerFromTelevisionPlayerListCell:self];
    }
}

#pragma mark - GETTER

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.numberOfLines = 0;
        [self.centerView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.centerView addSubview:_timeLabel];
    }
    return _timeLabel;
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
        _backToViewBtn.layer.cornerRadius = 30.0f/2;
        _backToViewBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _backToViewBtn.alpha = 0.8;
        [self.centerView addSubview:_backToViewBtn];
    }
    
    return _backToViewBtn;
}

- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc] init];
        [self.contentView addSubview:_centerView];
    }
    
    return _centerView;
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
@property (nonatomic, strong) NSArray *sourceArray; // 视频源字符串
@property (nonatomic, strong) NSString *videoUrlStr; // 正在使用的视频源字符串
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
    return kTelevisionDetailListCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTelevisionDetailListHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomSectionHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTelevisionDetailListHeaderViewId];
    if (!headerView) {
        headerView = [[CustomSectionHeaderFooterView alloc] initWithReuseIdentifier:kTelevisionDetailListHeaderViewId];
    }
    
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    headerView.section = section;
    
    __weak typeof(self) weakSelf = self;
    
    switch (section) {
        case 0:
        {
            [headerView.actionButton setTitle:sourceBtnTitle forState:UIControlStateNormal];
            headerView.titleLabel.text = @"正在播放";
        }
            break;
        case 1:
        {
            [headerView.actionButton setTitle:dateBtnTitle forState:UIControlStateNormal];
            headerView.titleLabel.text = @"节目单";
        }
            break;
            
        default:
            break;
    }

    __weak CustomSectionHeaderFooterView *weakHeaderView = headerView;
    [headerView setPerformActionBlock:^(NSInteger section) {
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
                    
                    [weakHeaderView.actionButton setTitle:dateStr forState:UIControlStateNormal];

                    [alertVC addAction:[UIAlertAction actionWithTitle:dateStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        weakSelf.beanArray = (NSMutableArray *)[weakSelf.channelDetailModel TelevisionChannelSelectionDayArrayWithType:dateType];
                        dispatch_async(dispatch_get_main_queue(), ^{
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
                for (int i = 0; i < self.sourceArray.count; ++i) {
                    //                    获取节目源类型的key，展示在sheet上
                    NSArray *allkey = [weakSelf.sourceArray[i] allKeys];
                    NSString *sourceType = allkey[0];
                    //                    根据节目源key获取节目源字符串
                    NSString *sourceStr = [weakSelf.sourceArray[i] valueForKey:sourceType];
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

    return headerView;
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
            cell.nameLabel.text = [self.playingArray lastObject].name;
            cell.timeLabel.text = [self.playingArray lastObject].time;
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
            [cell.backToViewBtn setTitle:@"直播中" forState:UIControlStateNormal];
            cell.scheduleBean.videoUrl = self.videoUrlStr;
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

#pragma mark - Response Method

- (void)didClickedPlayButton:(UITapGestureRecognizer *)gestureRecognizer {
    NSURL *url = [NSURL URLWithString:self.videoUrlStr];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.updatesNowPlayingInfoCenter = NO;;
    playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [playerViewController.player play];
    playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self presentViewController:playerViewController animated:YES completion:nil];
}

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

#pragma mark - Getter

- (TelevisionPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[TelevisionPlayerView alloc] init];
        _playerView.channelBean = _channelBean;
        [_playerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedPlayButton:)]];
    }

    return _playerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
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

- (NSArray *)sourceArray {
    if (!_sourceArray) {
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
        
        _sourceArray = sourceMutableArr;
    }
    
    return _sourceArray;
}

- (NSString *)videoUrlStr {
    NSString *videoSourceTempStr = [@"http://media2.neu6.edu.cn/hls/" stringByAppendingString:self.channelDetailModel.sourceStr];
    NSString *videoSourceStr = [videoSourceTempStr stringByAppendingString:@".m3u8"];
    return videoSourceStr;
}

@end
