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
@property (nonatomic, strong) UITableView *passwordTableView;
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
    self.passwordTableView.frame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.user.keychain.allKeys.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self editPasswordForType:self.user.keychain.allKeys[indexPath.row].type]; 
        });
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = indexPath.row < self.user.keychain.allKeys.count ? @"MePasswordNormalCellId" : @"MePasswordInsertCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if ([reuseIdentifier isEqualToString:@"MePasswordNormalCellId"]) {
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
    } else {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            cell.textLabel.dk_textColorPicker = DKColorPickerWithKey(title);
            
            cell.dk_tintColorPicker = DKColorPickerWithKey(accent);
            cell.backgroundColor = UIColor.clearColor;
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        
        cell.textLabel.text = @"点击加号添加新密码";
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView.editing ? self.user.keychain.allKeys.count + 1 : self.user.keychain.allKeys.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;
    if (indexPath.row < self.user.keychain.allKeys.count) {
        editingStyle = UITableViewCellEditingStyleDelete;
    } else {
        editingStyle = UITableViewCellEditingStyleInsert;
    }
    
    return editingStyle;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        // 删除密码
        NSArray<UserKey *> *array = self.user.keychain.allKeys.copy;
        [self.user.keychain deleteUserKeyForType:array[indexPath.row].type];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (editingStyle==UITableViewCellEditingStyleInsert) {
        // 新增密码
        [self showPasswordTypeMenu];
    }
}

#pragma mark - Response Methods

- (void)onEditButtonClicked:(id)sender {
    [self.passwordTableView setEditing:!self.passwordTableView.editing animated:YES];
    if (self.passwordTableView.editing) {
        [self.editButtonItem setTitle:@"完成"];
        [self.passwordTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.user.keychain.allKeys.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.editButtonItem setTitle:@"编辑"];
        [self.passwordTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.user.keychain.allKeys.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Private Methods

- (void)showPasswordTypeMenu {
    WS(ws);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新增密码" message:@"选择密码类型" preferredStyle:UIAlertControllerStyleAlert];
    NSArray<NSDictionary<NSString *, NSString *> *> *passwordTypeArray = @[
                                                                           @{@"name":NSLocalizedString(@"UserKeyTypeAAO", nil), @"type":@(UserKeyTypeAAO),},
                                                                           @{@"name":NSLocalizedString(@"UserKeyTypeEcard", nil), @"type":@(UserKeyTypeECard),},
                                                                           @{@"name":NSLocalizedString(@"UserKeyTypeIPGW", nil), @"type":@(UserKeyTypeIPGW),},
                                                                           @{@"name":NSLocalizedString(@"UserKeyTypeLib", nil),@"type":@(UserKeyTypeLib),},
                                                                           ];
    for (NSDictionary<NSString *, NSString *> *dictionary in passwordTypeArray) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:dictionary[@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws addPasswordForType:dictionary[@"type"].integerValue];
        }];
        alertAction.enabled = [self.user.keychain passwordForKeyType:dictionary[@"type"].integerValue].length==0;
        [alertController addAction:alertAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addPasswordForType:(UserKeyType)keyType {
    WS(ws);
    NSDictionary<NSNumber *, NSString *> *keyTypeDictionary = @{
                                                                @(UserKeyTypeAAO):NSLocalizedString(@"UserKeyTypeAAO", nil),
                                                                @(UserKeyTypeECard):NSLocalizedString(@"UserKeyTypeEcard", nil),
                                                                @(UserKeyTypeIPGW):NSLocalizedString(@"UserKeyTypeIPGW", nil),
                                                                @(UserKeyTypeLib):NSLocalizedString(@"UserKeyTypeLib", nil),
                                                                };
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"添加 %@ 密码", keyTypeDictionary[@(keyType)]] message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        if (textField.text.length>0) {
            UserKeychain *keychain = self.user.keychain;
            [keychain setPassword:[textField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] forKeyType:keyType];
            [ws.passwordTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)editPasswordForType:(UserKeyType)keyType {
    WS(ws);
    NSDictionary<NSNumber *, NSString *> *keyTypeDictionary = @{
                                                                @(UserKeyTypeAAO):NSLocalizedString(@"UserKeyTypeAAO", nil),
                                                                @(UserKeyTypeECard):NSLocalizedString(@"UserKeyTypeEcard", nil),
                                                                @(UserKeyTypeIPGW):NSLocalizedString(@"UserKeyTypeIPGW", nil),
                                                                @(UserKeyTypeLib):NSLocalizedString(@"UserKeyTypeLib", nil),
                                                                };
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"修改 %@ 密码", keyTypeDictionary[@(keyType)]] message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        if (textField.text.length>0) {
            UserKeychain *keychain = self.user.keychain;
            [keychain setPassword:[textField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] forKeyType:keyType];
            [ws.passwordTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        textField.text = [ws.user.keychain passwordForKeyType:keyType];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Setter

- (void)setUser:(User *)user {
    _user = user;
    [self.passwordTableView reloadData];
}

#pragma mark - Getter

- (UITableView *)passwordTableView {
    if (!_passwordTableView) {
        _passwordTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _passwordTableView.dk_backgroundColorPicker = DKColorPickerWithKey(background);
        _passwordTableView.delegate = self;
        _passwordTableView.dataSource = self;
        [self.view addSubview:_passwordTableView];
    }
    
    return _passwordTableView;
}

- (UIBarButtonItem *)editButtonItem {
    if (!_editBarButtonItem) {
        _editBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(onEditButtonClicked:)];
    }
    
    return _editBarButtonItem;
}

@end
