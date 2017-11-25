//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeViewController.h"
#import <PgySDK/PgyManager.h>

#import "MeInfoViewController.h"
#import "MePasswordViewController.h"
#import "MeAccountViewController.h"
#import "MeHomepageViewController.h"
#import "MeThemeViewController.h"
#import "MeAboutViewController.h"

typedef void(^MeMenuOnSwitchBlock)(BOOL isOn);
typedef NS_ENUM(NSUInteger, MeMenuTableViewCellStyle) {
    MeMenuTableViewCellStyleDefault,
    MeMenuTableViewCellStyleSwitch,
};
@interface MeMenuTableViewCell : UITableViewCell
@property (nonatomic, strong) UISwitch *switcher;
@property (nonatomic, strong) MeMenuOnSwitchBlock switchBlock;
- (instancetype)initWithMenuCellStyle:(MeMenuTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end

@interface MeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) User *user;
@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MeNavigationBarTitle", nil);
    
    [self initConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.user = [UserCenter defaultCenter].currentUser;
}

- (void)initConstraints {
    self.tableView.frame = self.view.frame;
    
    UIView *headerView = self.tableView.tableHeaderView;
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.width.and.height.mas_equalTo(@90);
        make.left.equalTo(headerView.mas_left).with.offset(16);
    }];
    
    UIView *infoView = [[UIView alloc] init];
    [infoView addSubview:self.nameLabel];
    [infoView addSubview:self.infoLabel];
    [headerView addSubview:infoView];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(infoView);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.and.right.equalTo(infoView);
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(8);
    }];
    
    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.left.equalTo(self.avatarImageView.mas_right).with.offset(16);
        make.right.equalTo(headerView.mas_right).with.offset(-16);
    }];
    
    [self.view layoutIfNeeded];
    
    [self.avatarImageView roundCorners:UIRectCornerAllCorners radii:CGSizeMake(4, 4)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Respond Method

- (void)showAccountManagement {
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    MeInfoViewController *infoViewController = [[MeInfoViewController alloc] init];
                    [self.navigationController pushViewController:infoViewController animated:YES];
                }
                    break;
                case 1:
                {
                    MePasswordViewController *passwordViewController = [[MePasswordViewController alloc] init];
                    [self.navigationController pushViewController:passwordViewController animated:YES];
                }
                    break;
                case 2:
                {
                    MeAccountViewController *accountViewController = [[MeAccountViewController alloc] init];
                    [self.navigationController pushViewController:accountViewController animated:YES];
                }
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    MeHomepageViewController *homepageViewController = [[MeHomepageViewController alloc] init];
                    [self.navigationController pushViewController:homepageViewController animated:YES];
                }
                    break;
                case 1:
                {
                    MeThemeViewController *themeViewController = [[MeThemeViewController alloc] init];
                    [self.navigationController pushViewController:themeViewController animated:YES];
//                    cell.detailTextLabel.text = @{
//                                                  @"NORMAL":NSLocalizedString(@"MeMenuColorSubtitleNormal", nil),
//                                                  @"NIGHT":NSLocalizedString(@"MeMenuColorSubtitleNight", nil),
//                                                  @"":@"",
//                                                  }[[DKNightVersionManager sharedManager].themeVersion];
                }
                    break;
            }
        }
            break;
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    
                }
                    break;
                case 1:
                {
                    MeAboutViewController *aboutViewController = [[MeAboutViewController alloc] init];
                    [self.navigationController pushViewController:aboutViewController animated:YES];
                }
                    break;
                case 2:
                {
                    [self showRankOptionMenu];
                }
                    break;
            }
        }
            break;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeMenuTableViewCellStyle style = MeMenuTableViewCellStyleDefault;
    
    if (indexPath.section==2 && indexPath.row==0) {
        style = MeMenuTableViewCellStyleSwitch;
    }

    MeMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%ld", style]];
    if (!cell) {
        cell = [[MeMenuTableViewCell alloc] initWithMenuCellStyle:style reuseIdentifier:[NSString stringWithFormat:@"%ld", style]];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedString(@"MeMenuInfoTitle", nil);
                    cell.imageView.image = [UIImage imageNamed:@"me_info"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 1:
                {
                    cell.textLabel.text = NSLocalizedString(@"MeMenuKeyTitle", nil);
                    cell.imageView.image = [UIImage imageNamed:@"me_key"];
                    NSInteger number = [UserCenter defaultCenter].currentUser.keychain.allKeys.count;
                    cell.detailTextLabel.text = number>0 ? [NSLocalizedString(@"MeMenuSwitchKeySubtitle", nil) stringByReplacingOccurrencesOfString:@"{0}" withString:[NSString stringWithFormat:@"%ld", number]] : NSLocalizedString(@"MeMenuSwitchKeySubtitleNone", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 2:
                {
                    cell.textLabel.text = NSLocalizedString(@"MeMenuSwitchAccountTitle", nil);
                    cell.imageView.image = [UIImage imageNamed:@"me_switch"];
                    cell.detailTextLabel.text = [UserCenter defaultCenter].currentUser.number ? : NSLocalizedString(@"MeMenuSwitchAccountSubtitleNone", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedString(@"MeMenuCustomizeHomeTitle", nil);
                    cell.imageView.image = [UIImage imageNamed:@"me_home"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 1:
                {
                    cell.textLabel.text = NSLocalizedString(@"MeMenuColorTitle", nil);
                    cell.imageView.image = [UIImage imageNamed:@"me_color"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.detailTextLabel.text = @{
                                                  @"NORMAL":NSLocalizedString(@"MeMenuColorSubtitleNormal", nil),
                                                  @"NIGHT":NSLocalizedString(@"MeMenuColorSubtitleNight", nil),
                                                  @"":@"",
                                                  }[[DKNightVersionManager sharedManager].themeVersion];
                }
                    break;
            }
        }
            break;
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = NSLocalizedString(@"MeMenuShakeTitle", nil);
                    cell.imageView.image = [UIImage imageNamed:@"me_shake"];
                    cell.switcher.on = [PgyManager sharedPgyManager].enableFeedback;
                    [cell setSwitchBlock:^(BOOL isOn) {
                        [PgyManager sharedPgyManager].enableFeedback = isOn;
                    }];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                case 1:
                {
                    cell.textLabel.text = NSLocalizedString(@"MeMenuAboutTitle", nil);
                    cell.imageView.image = [UIImage imageNamed:@"me_about"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 2:
                {
                    cell.textLabel.text = NSLocalizedString(@"MeMenuRankTitle", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"MeMenuRankSubtitle", nil);
                    cell.imageView.image = [UIImage imageNamed:@"me_rank"];
                }
                    break;
            }
        }
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    switch (section) {
        case 0:
            number = 3;
            break;
        case 1:
            number = 2;
            break;
        case 2:
            number = 3;
            break;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - Private Methods

- (void)showRankOptionMenu {
    WS(ws);
    UIAlertController *rankAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MeMenuRankTitle", nil) message:NSLocalizedString(@"MeMenuRankDetail", nil) preferredStyle:UIAlertControllerStyleAlert];
    [rankAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MeMenuRankActionLike", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *thanksAlertController = [UIAlertController alertControllerWithTitle:@"hhh谢谢" message:@"我们还没上架呢～\n欢迎上架后再给我们刷好评" preferredStyle:UIAlertControllerStyleAlert];
        [thanksAlertController addAction:[UIAlertAction actionWithTitle:@"到时一定记得好评哦！" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:thanksAlertController animated:YES completion:nil];
    }]];
    [rankAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MeMenuRankActionUnLike", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws chatWithMe];
    }]];
    [rankAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MeMenuRankActionLater", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:rankAlertController animated:YES completion:nil];
}

- (void)chatWithMe {
    BOOL success = NO;
    NSString *urlStr = [NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", @"623556543"];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        success = YES;
    }
    
    if (!success) {
        UIAlertController *errorAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AboutJoinQQGroupFailTitle", nil) message:NSLocalizedString(@"AboutJoinQQGroupFailMessage", nil) preferredStyle:UIAlertControllerStyleAlert];
        [errorAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"AboutJoinQQGroupFailAction", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:errorAlertController animated:YES completion:nil];
    }
    
}

#pragma mark - Setter

- (void)setUser:(User *)user {
    if (user) {
        self.nameLabel.text = user.realName;
        self.infoLabel.text = [NSString stringWithFormat:@"%@ %@", user.major, user.number];
        
        [self.tableView reloadData];
    }
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dk_separatorColorPicker = DKColorPickerWithKey(seperator);
        _tableView.dk_backgroundColorPicker = DKColorPickerWithKey(background);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_ACTUAL, 160.0f)];
        _tableView.tableHeaderView = headerView;
        
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test_avatar"]];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.tableView.tableHeaderView addSubview:_avatarImageView];
    }
    
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        _nameLabel.dk_textColorPicker = DKColorPickerWithKey(title);
    }
    
    return _nameLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _infoLabel.dk_textColorPicker = DKColorPickerWithKey(accent);
    }
    
    return _infoLabel;
}

@end

@implementation MeMenuTableViewCell {
    MeMenuTableViewCellStyle _cellStyle;
}

#pragma mark - Init

- (instancetype)initWithMenuCellStyle:(MeMenuTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        _cellStyle = style;
        [self initConstraints];
        [self configView];
    }
    
    return self;
}

- (void)configView {
    self.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    
    self.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textLabel.dk_textColorPicker = DKColorPickerWithKey(title);
    
    self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
    self.detailTextLabel.dk_textColorPicker = DKColorPickerWithKey(subtitle);
    
    self.imageView.layer.cornerRadius = 4;
    self.imageView.layer.masksToBounds = YES;
    if (_cellStyle == MeMenuTableViewCellStyleSwitch) {
        
    } else {
        self.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        self.detailTextLabel.textAlignment = NSTextAlignmentRight;
        self.detailTextLabel.dk_textColorPicker = DKColorPickerWithKey(subtitle);
    }
}

- (void)initConstraints {
    if (_cellStyle==MeMenuTableViewCellStyleSwitch) {
        [self.switcher mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(-16);
            make.centerY.equalTo(self.contentView);
        }];
    }
}

#pragma mark - Response Methods

- (void)onSwitchValueChanged:(id)sender {
    if (_switchBlock) {
        _switchBlock(_switcher.isOn);
    }
}

#pragma mark - Getter

- (UISwitch *)switcher {
    if (!_switcher) {
        _switcher = [[UISwitch alloc] init];
        [_switcher addTarget:self action:@selector(onSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
        _switcher.dk_tintColorPicker = DKColorPickerWithKey(accent);
        _switcher.dk_onTintColorPicker = DKColorPickerWithKey(accent);
        [self.contentView addSubview:_switcher];
    }
    
    return _switcher;
}

@end
