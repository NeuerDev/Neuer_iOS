//
//  LibrarySearchDoorViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchLibraryViewController.h"
#import "SearchLibraryDoorViewController.h"

#import "SearchListComponent.h"

@interface SearchLibraryViewController () <UISearchControllerDelegate, SearchListComponentDelegate>

@property (nonatomic, strong) SearchLibraryDoorViewController *searchDoorViewController;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIVisualEffectView *maskView;
@property (nonatomic, strong) UIBarButtonItem *collectionBarButtonItem;
@property (nonatomic, strong) SearchListComponent *mostSearchComponent;
@property (nonatomic, strong) SearchListComponent *recentSearchComponent;
@end

@implementation SearchLibraryViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SearchLibraryNavigationBarTitle", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.collectionBarButtonItem;
    if (@available(iOS 11.0, *)) {
#ifdef __IPHONE_11_0
        self.navigationItem.searchController = self.searchDoorViewController;
        [self.navigationItem setHidesSearchBarWhenScrolling:NO];
#endif
    } else {
        
    }
    
    [self initConstraints];
    [self reloadData];
}

- (void)initConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.recentSearchComponent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(self.contentView);
    }];
    
    [self.mostSearchComponent.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.recentSearchComponent.view.mas_bottom);
        make.left.and.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
}

- (void)reloadData {
    self.mostSearchComponent.strings = @[@"马克思原理", @"软件工程", @"公共事业管理基础", @"人工智能与神经网络", @"机械与自动化", @"工程原理"];
    self.recentSearchComponent.strings = @[@"iOS", @"The Great Gatsby", @"Oliver Twist", @"The Phantom Of the Opera", @"Khaled Hosseini", @"莫言"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Response Methods

- (void)showCollections {
    
}

#pragma mark - SearchListComponentDelegate

- (void)component:(SearchListComponent *)component didSelectedString:(NSString *)string {
    self.searchDoorViewController.active = YES;
    [self.searchDoorViewController searchKeyword:string];
}

- (void)component:(SearchListComponent *)component willPerformAction:(NSString *)action {
    
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    if ([searchController isKindOfClass:[SearchLibraryDoorViewController class]]) {
        UIView *suggestView = ((SearchLibraryDoorViewController *)searchController).resultView;
        [self.view addSubview:suggestView];
        [suggestView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
        }];
        [self.view layoutIfNeeded];
        _maskView.effect = nil;
        _maskView.alpha = 1;
        _maskView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _maskView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        }];
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if ([searchController isKindOfClass:[SearchLibraryDoorViewController class]]) {
        UIView *suggestView = ((SearchLibraryDoorViewController *)searchController).resultView;
        [self.view layoutIfNeeded];
        
        [suggestView removeFromSuperview];
        [UIView animateWithDuration:0.3 animations:^{
            _maskView.alpha = 0;
        } completion:^(BOOL finished) {
            _maskView.hidden = YES;
        }];

    }
}

#pragma mark - Getter

- (SearchLibraryDoorViewController *)searchDoorViewController {
    if (!_searchDoorViewController) {
        _searchDoorViewController = [[SearchLibraryDoorViewController alloc] init];
        _searchDoorViewController.delegate = self;
    }
    
    return _searchDoorViewController;
}

- (UIBarButtonItem *)collectionBarButtonItem {
    if (!_collectionBarButtonItem) {
        _collectionBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(showCollections)];
    }
    
    return _collectionBarButtonItem;
}

- (SearchListComponent *)mostSearchComponent {
    if (!_mostSearchComponent) {
        _mostSearchComponent = [[SearchListComponent alloc] initWithTitle:NSLocalizedString(@"SearchLibrarySearchListMostSearchTitle", nil) action:@""];
        _mostSearchComponent.delegate = self;
        [self.contentView addSubview:_mostSearchComponent.view];
    }
    
    return _mostSearchComponent;
}

- (SearchListComponent *)recentSearchComponent {
    if (!_recentSearchComponent) {
        _recentSearchComponent = [[SearchListComponent alloc] initWithTitle:NSLocalizedString(@"SearchLibrarySearchListRecentSearchTitle", nil) action:NSLocalizedString(@"SearchLibrarySearchListClear", nil)];
        _recentSearchComponent.delegate = self;
        [self.contentView addSubview:_recentSearchComponent.view];
    }
    
    return _recentSearchComponent;
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

- (UIVisualEffectView *)maskView {
    if (!_maskView) {
        _maskView = [[UIVisualEffectView alloc] init];
        _maskView.hidden = YES;
        [self.view addSubview:_maskView];
    }
    
    return _maskView;
}

@end
