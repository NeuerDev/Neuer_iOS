//
//  MeThemeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeThemeViewController.h"

@interface MeThemeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *themeTableView;
@end

@implementation MeThemeViewController {
    NSArray *_themeArray;
    NSDictionary *_themeDictionary;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

- (void)initData {
    self.title = NSLocalizedString(@"MeMenuColorTitle", nil);
    self.view.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    _themeArray = @[
                            NSLocalizedString(@"ThemeNORMAL", nil),
                            NSLocalizedString(@"ThemeNIGHT", nil),
                            ];
    _themeDictionary = @{
                                      NSLocalizedString(@"ThemeNORMAL", nil):@"NORMAL",
                                      NSLocalizedString(@"ThemeNIGHT", nil):@"NIGHT",
                                      };

}

- (void)initConstraints {
    self.themeTableView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [DKNightVersionManager sharedManager].themeVersion = _themeDictionary[_themeArray[indexPath.row]];
    [self.themeTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"MePasswordCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.dk_textColorPicker = DKColorPickerWithKey(title);
        
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.detailTextLabel.dk_textColorPicker = DKColorPickerWithKey(subtitle);
        
        cell.dk_tintColorPicker = DKColorPickerWithKey(accent);
        cell.dk_backgroundColorPicker = DKColorPickerWithKey(background);
        
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.layer.cornerRadius = 10;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.borderWidth = 1.0f/[UIScreen mainScreen].scale;
        cell.imageView.layer.dk_borderColorPicker = DKColorPickerWithKey(subtitle);
    }
    
    NSString *theme = [DKNightVersionManager sharedManager].themeVersion;
    cell.textLabel.text = _themeArray[indexPath.row];
    cell.imageView.image = [DKColorPickerWithKey(accent)(_themeDictionary[_themeArray[indexPath.row]]) imageWithSize:CGSizeMake(20, 20)];
    if ([_themeDictionary[_themeArray[indexPath.row]] isEqualToString:theme]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _themeArray.count;
}

#pragma mark - Getter

- (UITableView *)themeTableView {
    if (!_themeTableView) {
        _themeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _themeTableView.dk_backgroundColorPicker = DKColorPickerWithKey(background);
        _themeTableView.dk_separatorColorPicker = DKColorPickerWithKey(seperator);
        _themeTableView.delegate = self;
        _themeTableView.dataSource = self;
        [self.view addSubview:_themeTableView];
    }
    
    return _themeTableView;
}

@end
