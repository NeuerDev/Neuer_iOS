//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeViewController.h"
#import <PgySDK/PgyManager.h>

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

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MeNavigationBarTitle", nil);
    
    [self initConstraints];
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.and.right.and.bottom.equalTo(self.view);
    }];
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

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dk_separatorColorPicker = DKColorPickerWithKey(seperator);
        _tableView.dk_backgroundColorPicker = DKColorPickerWithKey(background);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
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
