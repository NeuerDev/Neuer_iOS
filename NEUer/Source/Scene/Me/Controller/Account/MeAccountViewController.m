//
//  MeAccountViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeAccountViewController.h"

@interface MeAccountViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIBarButtonItem *editBarButtonItem;
@property (nonatomic, strong) UITableView *themeTableView;
@property (nonatomic, weak) User *user;
@end

@implementation MeAccountViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.user = [UserCenter defaultCenter].currentUser;
}

- (void)initData {
    self.title = NSLocalizedString(@"MeMenuSwitchAccountTitle", nil);
    self.view.dk_backgroundColorPicker = DKColorPickerWithKey(background);
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"MeAccountCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.dk_textColorPicker = DKColorPickerWithKey(title);
        
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        cell.detailTextLabel.dk_textColorPicker = DKColorPickerWithKey(subtitle);
        
        cell.dk_tintColorPicker = DKColorPickerWithKey(accent);
        cell.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    }
    
    NSArray<User *> *array = [UserCenter defaultCenter].allUsers;
    cell.textLabel.text = array[indexPath.row].realName;
    cell.detailTextLabel.text = array[indexPath.row].number;
    
    if ([array[indexPath.row].number isEqualToString:self.user.number]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [UserCenter defaultCenter].allUsers.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
    }
}

#pragma mark - Response Methods

- (void)onEditButtonClicked:(id)sender {
    [self.themeTableView setEditing:!self.themeTableView.editing animated:YES];
    if (self.themeTableView.editing) {
        [self.editButtonItem setTitle:@"完成"];
    } else {
        [self.editButtonItem setTitle:@"编辑"];
    }
}

#pragma mark - Setter

- (void)setUser:(User *)user {
    _user = user;
    [self.themeTableView reloadData];
}

#pragma mark - Getter

- (UITableView *)themeTableView {
    if (!_themeTableView) {
        _themeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _themeTableView.delegate = self;
        _themeTableView.dataSource = self;
        _themeTableView.dk_backgroundColorPicker = DKColorPickerWithKey(background);
        _themeTableView.dk_separatorColorPicker = DKColorPickerWithKey(seperator);
        [self.view addSubview:_themeTableView];
    }
    
    return _themeTableView;
}

- (UIBarButtonItem *)editButtonItem {
    if (!_editBarButtonItem) {
        _editBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(onEditButtonClicked:)];
    }
    
    return _editBarButtonItem;
}

@end
