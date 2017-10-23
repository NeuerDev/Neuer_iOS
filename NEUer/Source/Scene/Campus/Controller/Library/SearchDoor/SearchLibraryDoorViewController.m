//
//  LibrarySearchViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchLibraryDoorViewController.h"
#import "SearchLibraryResultViewController.h"

#import "SearchLibrarySuggestModel.h"

const CGFloat kSearchSuggestListHeaderHeight = 34.0f;
const CGFloat kSearchSuggestListCellHeight = 44.0f;
const CGFloat kSearchSuggestListContentOffset = 16.0f;
NSString * const kSearchSuggestListCellId = @"kSearchSuggestListCellId";

@interface SearchLibraryDoorViewController () <UISearchResultsUpdating, UISearchBarDelegate, SearchLibrarySuggestDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) SearchLibraryResultViewController *searchResultViewController;

@property (nonatomic, strong) SearchLibrarySuggestModel *suggestModel;
@property (nonatomic, strong) UIView *resultView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITableView *suggestTableView;
@end

@implementation SearchLibraryDoorViewController

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super initWithSearchResultsController:nil]) {
        self.dimsBackgroundDuringPresentation = NO;
        self.searchResultsUpdater = self;
        self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.searchBar.delegate = self;
        self.searchBar.placeholder = NSLocalizedString(@"SearchLibrarySearchBarPlaceholder", nil);
        self.searchBar.scopeButtonTitles = @[
                                             NSLocalizedString(@"SearchLibrarySearchFilterTypeAll", nil),
                                             NSLocalizedString(@"SearchLibrarySearchFilterTypeTitles", nil),
                                             NSLocalizedString(@"SearchLibrarySearchFilterTypeAuthors", nil),
                                             NSLocalizedString(@"SearchLibrarySearchFilterTypePresses", nil)
                                             ];
    }
    
    return self;
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Public Methods

- (void)searchKeyword:(NSString *)keyword {
    [self.searchBar resignFirstResponder];
    [self hideSuggestTableView:YES];
    [self hideSearchResultView:NO];
    self.searchBar.text = keyword;
    [self.searchResultViewController searchWithKeyword:keyword scope:self.searchBar.selectedScopeButtonIndex];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self searchKeyword:_suggestModel.suggestions[indexPath.row][kSearchSuggestBookName]];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchSuggestListCellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kSearchSuggestListCellId];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSString *bookName = _suggestModel.suggestions[indexPath.row][kSearchSuggestBookName];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:bookName];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] range:[bookName rangeOfString:_suggestModel.keyword options:NSCaseInsensitiveSearch]];
    cell.textLabel.attributedText = attributeString;
    cell.detailTextLabel.text = _suggestModel.suggestions[indexPath.row][kSearchSuggestBookQuryTime];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSearchSuggestListCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = _suggestModel.suggestions.count;
    if (number>0) {
        _suggestTableView.hidden = NO;
    } else {
        _suggestTableView.hidden = YES;
    }
    return _suggestModel.suggestions.count;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.suggestModel querySuggestionsForKeyword:searchController.searchBar.text];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self hideSuggestTableView:NO];
    [self hideSearchResultView:YES];
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self searchKeyword:searchBar.text];
        return NO;
    } else {
        return YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // write into history
    // reload data
    // push new view controller
    // start search
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self cancelSearch];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self searchKeyword:searchBar.text];
}

#pragma mark - SearchLibrarySuggestDelegate

- (void)suggestUpdated {
    [self.suggestTableView reloadData];
}

#pragma mark - Private Methods

- (void)cancelSearch {
    [self setActive:NO];
}

- (void)hideSuggestTableView:(BOOL)hidden {
    [UIView animateWithDuration:1.0f/3.0f animations:^{
        self.suggestTableView.alpha = hidden ? 0 : 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideSearchResultView:(BOOL)hidden {
    [UIView animateWithDuration:1.0f/3.0f animations:^{
        self.searchResultViewController.view.alpha = hidden ? 0 : 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)clear {
    
}

#pragma mark - Getter

- (SearchLibraryResultViewController *)searchResultViewController {
    if (!_searchResultViewController) {
        _searchResultViewController = [[SearchLibraryResultViewController alloc] init];
        _searchResultViewController.view.alpha = 0;
    }
    
    return _searchResultViewController;
}

- (SearchLibrarySuggestModel *)suggestModel {
    if (!_suggestModel) {
        _suggestModel = [[SearchLibrarySuggestModel alloc] init];
        _suggestModel.delegate = self;
    }
    
    return _suggestModel;
}

- (UIView *)resultView {
    if (!_resultView) {
        _resultView = [[UIView alloc] init];
        
        [_resultView addSubview:self.maskView];
        [_resultView insertSubview:self.searchResultViewController.view aboveSubview:self.maskView];
        [_resultView insertSubview:self.suggestTableView aboveSubview:self.searchResultViewController.view];
        
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_resultView);
        }];
        [self.suggestTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_resultView);
        }];
        [self.searchResultViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_resultView);
        }];
    }
    
    return _resultView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)]];
    }
    
    return _maskView;
}

- (UITableView *)suggestTableView {
    if (!_suggestTableView) {
        _suggestTableView = [[UITableView alloc] init];
        _suggestTableView.backgroundColor = [UIColor clearColor];
        _suggestTableView.tableFooterView = [[UIView alloc] init];
        _suggestTableView.delegate = self;
        _suggestTableView.dataSource = self;
        _suggestTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    
    return _suggestTableView;
}

@end
