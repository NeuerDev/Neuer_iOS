//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "MeViewController.h"

@interface MeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UIImageView *cardAvatarImageView;

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
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_topLayoutGuide);
//        make.left.and.right.and.bottom.equalTo(self.view);
//    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.and.right.and.bottom.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(16);
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.height.equalTo(self.cardView.mas_width).multipliedBy(431.0f/686.0f);
        
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16);
    }];
    
    [self.cardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cardView);
    }];
    
    [self.cardAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.cardImageView).multipliedBy(0.565);
        make.width.equalTo(self.cardAvatarImageView.mas_height).multipliedBy(0.75);
        make.left.equalTo(self.cardImageView.mas_right).multipliedBy(0.06);
        make.top.equalTo(self.cardImageView.mas_bottom).multipliedBy(0.2);
    }];
    
    MASAttachKeys(_cardAvatarImageView, _cardImageView, _cardView, _scrollView, _contentView, self.view);
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
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_scrollView];
    }
    
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        
        [self.scrollView addSubview:_contentView];
    }
    
    return _contentView;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        
        [self.contentView addSubview:_cardView];
    }
    
    return _cardView;
}

- (UIImageView *)cardImageView {
    if (!_cardImageView) {
        _cardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_me_background"]];
        _cardImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.cardView addSubview:_cardImageView];
    }
    
    return _cardImageView;
}

- (UIImageView *)cardAvatarImageView {
    if (!_cardAvatarImageView) {
        _cardAvatarImageView = [[UIImageView alloc] init];
        _cardAvatarImageView.backgroundColor = [UIColor redColor];
        _cardAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.cardImageView addSubview:_cardAvatarImageView];
    }
    
    return _cardAvatarImageView;
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
