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

#import "SearchLibraryBorrowingModel.h"

@interface SearchLibraryViewController () <UISearchControllerDelegate, SearchListComponentDelegate,SearchLibraryBorrowingDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) SearchLibraryDoorViewController *searchDoorViewController;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIVisualEffectView *maskView;
@property (nonatomic, strong) UIBarButtonItem *collectionBarButtonItem;
@property (nonatomic, strong) SearchListComponent *mostSearchComponent;
@property (nonatomic, strong) SearchListComponent *recentSearchComponent;
@property (nonatomic, strong) SearchLibraryBorrowingModel *borrowingModel;
@property (nonatomic, strong) NSArray *typeArray;
@property (nonatomic, strong) NSArray *typeParameterArray;
@property (nonatomic, strong) NSArray *timeArray;
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
    
    [self.borrowingModel search];
    [self initConstraints];
    self.recentSearchComponent.strings = @[@"iOS", @"The Great Gatsby", @"Oliver Twist", @"The Phantom Of the Opera", @"Khaled Hosseini", @"莫言"];
//    [self reloadData];
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
    NSMutableArray *array = [NSMutableArray array];
    for (SearchLibraryBorrowingBean *bean in _borrowingModel.resultArray) {
        [array addObject:bean.title];
    }
    self.mostSearchComponent.strings = array;
//    self.recentSearchComponent.strings = @[@"iOS", @"The Great Gatsby", @"Oliver Twist", @"The Phantom Of the Opera", @"Khaled Hosseini", @"莫言"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Response Methods

- (void)showCollections {
    
}

- (void)selectType {
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.tag = 101;
    picker.delegate = self;
    picker.dataSource = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n请选择类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert.view addSubview:picker];
    
    [picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.and.left.equalTo(alert.view);
        make.height.mas_equalTo(180);
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger index = [picker selectedRowInComponent:0];
        _borrowingModel.sortType = self.typeParameterArray[index];
        [_borrowingModel search];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{}];
    
}

- (void)selectTime {
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.tag = 102;
    picker.delegate = self;
    picker.dataSource = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n请选择时间" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert.view addSubview:picker];
    
    [picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.and.left.equalTo(alert.view);
        make.height.mas_equalTo(180);
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger index = [picker selectedRowInComponent:0];
        if (index == 0) {
            _borrowingModel.date = @"y";
        } else if (index == 1) {
            _borrowingModel.date = @"s";
        } else if (index == 2) {
            _borrowingModel.date = @"m";
        } else {
            _borrowingModel.date = @"w";
        }
        [_borrowingModel search];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{}];
}

#pragma mark - SearchListComponentDelegate

- (void)component:(SearchListComponent *)component didSelectedString:(NSString *)string {
    self.searchDoorViewController.active = YES;
    [self.searchDoorViewController searchKeyword:string];
}

- (void)component:(SearchListComponent *)component willPerformAction:(NSString *)action {
    if ([action isEqualToString:@"更多"]) {
        [self selectTime];
    } else if ([action isEqualToString:@"类型"]) {
        [self selectType];
    } else {
        
    }
}

#pragma mark - SearchLibraryBorrowingDelegate
- (void)searchDidSuccess {
    [self reloadData];
}

- (void)searchDidFail:(NSString *)message {
    
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

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 101) {
        return self.typeArray.count;
    } else {
        return self.timeArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 101) {
        return [self.typeArray objectAtIndex:row];
    } else {
        return [self.timeArray objectAtIndex:row];
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
        _mostSearchComponent = [[SearchListComponent alloc] initWithTitle:NSLocalizedString(@"SearchLibrarySearchListMostSearchTitle", nil) action:@"更多"];
        _mostSearchComponent.delegate = self;
        [self.contentView addSubview:_mostSearchComponent.view];
        [_mostSearchComponent showSelectButton];
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

- (SearchLibraryBorrowingModel *)borrowingModel {
    if (!_borrowingModel) {
        _borrowingModel = [[SearchLibraryBorrowingModel alloc] init];
        _borrowingModel.delegate = self;
    }
   return _borrowingModel;
}

- (NSArray *)typeArray {
    if (!_typeArray) {
        _typeArray = @[@"全部",@"马列主义、毛泽东思想、邓小平理论",@"宗教、哲学",@"社会科学总论",@"政治、法律",@"军事",@"经济",@"文化、科学、教育、体育",@"语言、文字",@"文学",@"艺术",@"历史、地理",@"自然科学总论",@"数理科学与化学",@"数学",@"力学",@"物理学1",@"物理学2",@"化学",@"晶体学",@"天文学、地球科学",@"生物科学",@"医药、卫生",@"农业科学",@"工业技术",@"一般工业技术",@"矿业工程",@"石油、天然气工业",@"冶金工业",@"金属学与金属工艺",@"机械、仪表工业",@"武器工业",@"能源与动力工程",@"原子能技术",@"电子技术",@"无线电电子学、电信技术",@"自动化技术、计算机技术",@"化学工业",@"轻工业、手工业",@"建筑科学",@"水利工程",@"交通运输",@"航空、航天",@"环境科学、安全科学",@"综合性图书"];
    }
    return _typeArray;
}

- (NSArray *)typeParameterArray {
    if (!_typeParameterArray) {
        _typeParameterArray = @[@"ALL",@"A",@"",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"N",@"O",@"O2",@"O3",@"O4",@"O5",@"O6",@"O7",@"P",@"Q",@"R",@"S",@"T",@"TB",@"TD",@"TE",@"TF",@"TG",@"TH",@"TJ",@"TK",@"TL",@"TM",@"TN",@"TP",@"TQ",@"TS",@"TU",@"TV",@"U",@"V",@"X",@"Z"];
    }
   return _typeParameterArray;
}

- (NSArray *)timeArray {
    if (!_timeArray) {
        _timeArray = @[@"最近一年",@"最近三月",@"最近一月",@"最近一周"];
    }
   return _timeArray;
}


@end
