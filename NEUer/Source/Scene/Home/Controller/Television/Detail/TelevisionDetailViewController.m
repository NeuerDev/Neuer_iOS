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
#import <UserNotifications/UserNotifications.h>

#import "CustomSectionHeaderFooterView.h"

#import "LYTool.h"
#import "TelevisionChannelModel.h"
#import "AppDelegate.h"
#import "BadgeCenter.h"

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
        _maskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tv_play"]];
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

NSString * const kOrderShowId = @"kOrderShowId";

@protocol TelevisionPlayerListCellDelegate

@required

- (void)prensentLookBackViewControllerFromBean:(TelevisionChannelScheduleBean *)bean;
- (void)makeAnAppointmentToTVShow:(TelevisionChannelScheduleBean *)bean;

@end

@interface TelevisionPlayerListCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *backToViewBtn;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) TelevisionChannelScheduleBean *scheduleBean;
@property (nonatomic, weak) id<TelevisionPlayerListCellDelegate> delegate;

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
        make.centerY.equalTo(self.contentView);
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

- (void)didSelectBackToViewBtnWithTVShow {
    NSComparisonResult result = [self.scheduleBean.time compare:[LYTool timeOfNow]];
    if (result == NSOrderedDescending && [self.scheduleBean.date isEqualToString:[LYTool dateOfTimeIntervalFromToday:0]]) {
        if (_delegate) {
            [_delegate makeAnAppointmentToTVShow:self.scheduleBean];
        }
    } else {
        if (_delegate) {
            [_delegate prensentLookBackViewControllerFromBean:self.scheduleBean];
        }
    }
}

#pragma mark - Setter
- (void)setScheduleBean:(TelevisionChannelScheduleBean *)scheduleBean {
    _scheduleBean = scheduleBean;
    _nameLabel.text = _scheduleBean.name;
    _timeLabel.text = _scheduleBean.time;

    [_backToViewBtn setTitle:_scheduleBean.status forState:UIControlStateNormal];
    NSComparisonResult result = [scheduleBean.time compare:[LYTool timeOfNow]];
    if (result == NSOrderedDescending && [_scheduleBean.date isEqualToString: [LYTool dateOfTimeIntervalFromToday:0]]) {
        _backToViewBtn.backgroundColor = [UIColor beautyBlue];
        [_backToViewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [_backToViewBtn setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
        _backToViewBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
}

#pragma mark - Getter

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
        _backToViewBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _backToViewBtn.layer.cornerRadius = 30.0f/2;
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


static NSString *dateButtonTitle = @"今天";
static NSString *sourceButtonsTitle = @"清华大学";
static TelevisionChannelModelSelectionType selectionType = TelevisionChannelModelSelectionTypeToday;

@interface TelevisionDetailViewController () <UITableViewDelegate, UITableViewDataSource, TelevisionChannelModelDelegate, TelevisionPlayerListCellDelegate>

@property (nonatomic, strong) TelevisionPlayerView *playerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CustomSectionHeaderFooterView *headerView;
@property (nonatomic, strong) UIBarButtonItem *collectBarButtonItem;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) TelevisionChannelModel *channelDetailModel;

@end

@implementation TelevisionDetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Init

- (void)initData {
    dateButtonTitle = @"今天";
    sourceButtonsTitle = @"清华大学";
    selectionType = TelevisionChannelModelSelectionTypeToday;
    
    self.view.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    self.title = _channelBean.channelName;
    [self.channelDetailModel fecthTelevisionChannelDataWithVideoUrl:self.channelBean.choosenSource.allValues[0]];
    self.navigationItem.rightBarButtonItem = self.collectBarButtonItem;
}

- (void)initConstraints {
    self.tableView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - TelevisionPlayerListCellDelegate

- (void)prensentLookBackViewControllerFromBean:(TelevisionChannelScheduleBean *)bean {
    NSURL *url = [NSURL URLWithString:bean.videoUrl];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.updatesNowPlayingInfoCenter = NO;
    playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    [playerViewController.player play];
    
    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (void)makeAnAppointmentToTVShow:(TelevisionChannelScheduleBean *)bean {
    
    [((AppDelegate *)[UIApplication sharedApplication].delegate).center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        if (!granted) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"“东大方圆”想给您发送推送通知" message:@"“通知”主要包括活动、节目预约等信息，请在“设置”中打开。" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                    [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
                }
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.userInfo = @{
                         @"contentType" : @"tvshow",
                         @"showname" : bean.name,
                         @"channelname" : (self.channelBean.channelName).copy,
                         @"showsource" : bean.sourceUrl,
                         @"showtime" : bean.time
                         };
    content.title = @"您预约的节目即将开始啦！";
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = @"tvshowid";
    content.body = [NSString stringWithFormat:@"您预约于 %@ 的节目%@即将开始播放啦！点击跳转观看", bean.time, bean.name];
    
    [[BadgeCenter defaultCenter] updateBadges];
    content.badge = [[BadgeCenter defaultCenter] badges];
    
    NSString *nowTime = [[LYTool timeOfNow] stringByAppendingString:@":00"];
    NSString *showTime = [bean.time stringByAppendingString:@":00"];
    
//    提前五分钟提醒
    NSTimeInterval interval = [LYTool timeIntervalWithStartTime:nowTime endTime:showTime] - (5*60);

    UNTimeIntervalNotificationTrigger *trigger;
    if (interval > 0) {
        trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:interval repeats:NO];
    } else {
        trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:[LYTool timeIntervalWithStartTime:nowTime endTime:showTime] repeats:NO];
    }
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"requestId_%@_%@", bean.sourceUrl, bean.time] content:content trigger:trigger];

    WS(ws);
    [((AppDelegate *)[UIApplication sharedApplication].delegate).center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            
            TelevisionWallOrderBean *orderBean = [[TelevisionWallOrderBean alloc] init];
            orderBean.showName = bean.name;
            orderBean.showTime = bean.time;
            orderBean.channelName = ws.channelBean.channelName;
            orderBean.sourceString = bean.sourceUrl;
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您已预约成功。" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ws.wallModel addOrderedTVShow:orderBean];
            }]];
            [ws presentViewController:alertController animated:YES completion:nil];
            
        }
    }];
}

#pragma mark - TelevisionChannelModelDelegate

- (void)fetchTelevisionChannelModelFailureWithMsg:(NSString *)msg {
    NSLog(@"加载失败");
}

- (void)fetchTelevisionChannelModelSuccess {
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
            [headerView.actionButton setTitle:sourceButtonsTitle forState:UIControlStateNormal];
            headerView.titleLabel.text = NSLocalizedString(@"TelevisionChannelPlaying", nil);
        }
            break;
        case 1:
        {
            [headerView.actionButton setTitle:dateButtonTitle forState:UIControlStateNormal];
            headerView.titleLabel.text = NSLocalizedString(@"TelevisionChannelPlayList", nil);
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
                [weakSelf showAlertControllerWithDate];
                [weakHeaderView.actionButton setTitle:dateButtonTitle forState:UIControlStateNormal];
            }
                break;
            case 0:
            {
                
                [weakSelf showAlertControllerWithSelectionType];
                [weakHeaderView.actionButton setTitle:sourceButtonsTitle forState:UIControlStateNormal];
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
        cell.scheduleBean = [self.channelDetailModel.playingArray lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        TelevisionPlayerListCell *cell = [tableView dequeueReusableCellWithIdentifier:kTelevisionDetailListCellId];
        
        if (!cell) {
            cell = [[TelevisionPlayerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTelevisionDetailListCellId];
        }
        cell.scheduleBean = self.channelDetailModel.beanArray[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        
        return cell;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.channelDetailModel.beanArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.channelDetailModel.beanArray.count != 0) {
        return 2;
    } else {
        return 0;
    }
}

#pragma mark - Response Method

- (void)didClickedPlayButton:(UITapGestureRecognizer *)gestureRecognizer {
    NSURL *url = [NSURL URLWithString:[self.channelDetailModel.playingArray lastObject].videoUrl];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.updatesNowPlayingInfoCenter = NO;;
    playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [playerViewController.player play];
    playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (void)didClickedCollectedButton {
    WS(ws);
    if (self.wallModel.collectionArray.count > 0) {
        for (TelevisionWallChannelBean *bean in self.wallModel.collectionArray) {
            if ([self.channelBean.channelDetailUrl isEqualToString:bean.channelDetailUrl]) {
                [self.wallModel deleteColletionTVItemWithSourceUrl:self.channelBean.channelDetailUrl withBlock:^(BOOL success) {
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [ws.collectBarButtonItem setImage:[UIImage imageNamed:@"tv_uncollection"]];
                        });
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"取消收藏成功！" preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                        [ws presentViewController:alertController animated:YES completion:nil];
                    }
                }];
                return;
            }
        }
    }
    
    [self.wallModel addCollectionTVWithSourceUrl:self.channelBean.channelDetailUrl withBlock:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.collectBarButtonItem setImage:[UIImage imageNamed:@"tv_collectioned"]];
            });
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"收藏成功！" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [ws presentViewController:alertController animated:YES completion:nil];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"收藏失败，请先登录" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [ws presentViewController:alertController animated:YES completion:nil];
        }
    }];
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

#pragma mark - Private Method

- (void)showAlertControllerWithDate {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择节目日期" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  
    for (int i = 0; i < self.channelDetailModel.televisionChannelModelSelectionTypeArray.count; ++i) {
        //                    获取节目日期类型
        NSArray *allkey = [[self.channelDetailModel.televisionChannelModelSelectionTypeArray objectAtIndex:i] allKeys];
        int dateType = [[allkey objectAtIndex:0] intValue];
        
        //                    根据节目类型获取实际节目日期字符串
        NSString *dateStr = [[self.channelDetailModel.televisionChannelModelSelectionTypeArray objectAtIndex:i] valueForKey:[NSString stringWithFormat:@"%d", i]];
        NSString *date = [LYTool dateOfTimeIntervalFromToday:0];
        if ([dateStr isEqualToString:date]) {
            dateStr = @"今天";
        }
        date = [LYTool dateOfTimeIntervalFromToday:1];
        if ([dateStr isEqualToString:date]) {
            dateStr = @"昨天";
        }
        
        [alertVC addAction:[UIAlertAction actionWithTitle:dateStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.channelDetailModel setSelectedType:dateType];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.channelBean.choosenDate = dateStr;
                selectionType = dateType;
                dateButtonTitle = dateStr;
                [self.tableView reloadData];
            });
        }]];
    }
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
    
}

- (void)showAlertControllerWithSelectionType {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择视频源类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0; i < self.channelBean.sourceArray.count; ++i) {
        //                    获取节目源类型的key，展示在sheet上
        NSArray *allkey = [self.channelBean.sourceArray[i] allKeys];
        NSString *sourceType = allkey[0];
        //                    根据节目源key获取节目源字符串
        NSString *sourceStr = [self.channelBean.sourceArray[i] valueForKey:sourceType];
        [alertVC addAction:[UIAlertAction actionWithTitle:sourceType style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.channelDetailModel fecthTelevisionChannelDataWithVideoUrl:sourceStr];
            [self.channelBean setChoosenSource:@{
                                                 sourceType : sourceStr
                                                 }];
            sourceButtonsTitle = sourceType;
            [self.tableView reloadData];
        }]];
    }
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
    
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
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setShowsVerticalScrollIndicator:NO];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.refreshControl = self.refreshControl;
        
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
        BOOL _flag = NO;
        for (TelevisionWallChannelBean *bean in self.wallModel.collectionArray) {
            if ([self.channelBean.channelDetailUrl isEqualToString:bean.channelDetailUrl]) {
                _flag = YES;
            }
        }
        if (_flag == NO) {
            _collectBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tv_uncollection"] style:UIBarButtonItemStylePlain target:self action:@selector(didClickedCollectedButton)];
        } else {
            _collectBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tv_collectioned"] style:UIBarButtonItemStylePlain target:self action:@selector(didClickedCollectedButton)];
        }
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

@end
