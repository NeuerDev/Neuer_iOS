//
//  MePasswordViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/11/24.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MePasswordViewController.h"

@interface MePasswordViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIBarButtonItem *editBarButtonItem;
@property (nonatomic, strong) UITableView *themeTableView;
@property (nonatomic, weak) User *user;
@end

@implementation MePasswordViewController

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
    self.title = NSLocalizedString(@"MeMenuKeyTitle", nil);
    self.view.dk_backgroundColorPicker = DKColorPickerWithKey(background);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    NSString *reuseIdentifier = @"MePasswordCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.dk_textColorPicker = DKColorPickerWithKey(title);
        
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        cell.detailTextLabel.dk_textColorPicker = DKColorPickerWithKey(subtitle);
        
        cell.dk_tintColorPicker = DKColorPickerWithKey(accent);
        cell.backgroundColor = UIColor.clearColor;
    }
    
    NSArray<UserKey *> *array = self.user.keychain.allKeys.copy;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", @[
                            NSLocalizedString(@"UserKeyTypeAAO", nil),
                            NSLocalizedString(@"UserKeyTypeIPGW", nil),
                            NSLocalizedString(@"UserKeyTypeEcard", nil),
                            NSLocalizedString(@"UserKeyTypeLib", nil),
                            ][array[indexPath.row].type], self.user.number];
    cell.detailTextLabel.text = array[indexPath.row].value;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.user.keychain.allKeys.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        NSArray<UserKey *> *array = self.user.keychain.allKeys.copy;
        [self.user.keychain deleteUserKeyForType:array[indexPath.row].type];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        _themeTableView.dk_backgroundColorPicker = DKColorPickerWithKey(background);
        _themeTableView.delegate = self;
        _themeTableView.dataSource = self;
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
