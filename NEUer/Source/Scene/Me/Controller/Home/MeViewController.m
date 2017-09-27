//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeViewController.h"

@interface MeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *sectionDataArray;
@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"HomeNavigationBarTitle", nil);
    self.title = @"我的";
    
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
//    SEL selector = NSSelectorFromString(((NSArray *)self.sectionDataArray[indexPath.section][@"selector"])[indexPath.row]);
//    IMP imp = [self methodForSelector:selector];
//    void (* func)(id, SEL) = (void *)imp;
//    func(self, selector);
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.sectionDataArray[indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    
    cell.textLabel.text = data[@"cells"][indexPath.row];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.sectionDataArray[section][@"cells"]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionDataArray[section][@"title"];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSArray<NSDictionary *> *)sectionDataArray {
    if (!_sectionDataArray) {
        _sectionDataArray = @[
                              @{
                                  @"cells":@[
                                          @"我的网关",
                                          @"我的校园卡",
                                          @"我的图书馆",
                                          ],
                                  @"selector":@[
                                          NSStringFromSelector(@selector(selectImageFromCamera)),
                                          NSStringFromSelector(@selector(selectImageFromAlbum)),
                                          ],
                                  @"title":@"我的"
                                  },
                              @{
                                  @"cells":@[
                                          @"主界面",
                                          @"扩展功能",
                                          @"应用设置",
                                          @"清理缓存",
                                          ],
                                  @"selector":@[
                                          NSStringFromSelector(@selector(live)),
                                          ],
                                  @"title":@"设置"
                                  },
                              @{
                                  @"cells":@[
                                          @"评分",
                                          @"分享",
                                          @"关于我们",
                                          ],
                                  @"selector":@[
                                          NSStringFromSelector(@selector(showDocument)),
                                          ],
                                  @"title":@"更多"
                                  },
                              ];
    }
    
    return _sectionDataArray;
}

@end
