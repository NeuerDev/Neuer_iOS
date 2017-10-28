//
//  LibraryBookListComponent.m
//  NEUer
//
//  Created by kl h on 2017/10/26.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryBookListComponent.h"
#import "SearchLibraryNewBookModel.h"
#import "SearchLibraryBorrowingModel.h"

NSString * const kDefalutCellId = @"kDefalutCellId";

@interface LibraryBookListComponent () <UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIButton *languageBtn;
@property (nonatomic, strong) UIButton *typeBtn;
@property (nonatomic, strong) UIButton *dateBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *languageArr;
@property (nonatomic, strong) NSArray<NSString *> *languageParaArr;
@property (nonatomic, strong) NSArray<NSString *> *typeArr;
@property (nonatomic, strong) NSArray<NSString *> *typeParaArr;
@property (nonatomic, strong) NSArray<NSString *> *dateArr;
@property (nonatomic, strong) NSArray<NSString *> *dateParaArr;
@property (nonatomic, strong) NSArray<NSString *> *strings;

@end

@implementation LibraryBookListComponent
#pragma mark - Init Methods
- (instancetype)initWithModelType:(ComponentModelType)type {
    if (self = [super init]) {
        switch (type) {
            case ComponentModelTypeNewBook: {
                _modelType = ComponentModelTypeNewBook;
                _dateArr = [[NSArray alloc] initWithObjects:@"最近半年",@"最近三月",@"最近一月",@"最近一周", nil];
                _dateParaArr = [[NSArray alloc] initWithObjects:@"180",@"90",@"15",@"7", nil];
            }
                break;
                
            case ComponentModelTypeMost: {
                _modelType = ComponentModelTypeMost;
                _dateArr = [[NSArray alloc] initWithObjects:@"最近一年",@"最近三月",@"最近一月",@"最近一周", nil];
                _dateParaArr = [[NSArray alloc] initWithObjects:@"y",@"s",@"m",@"w", nil];
            }
                break;
                
            default:
                break;
        }
    }
    return self;
}

#pragma mark - Cilck Methods
- (void)selectLanguage {
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.tag = 101;
    picker.delegate = self;
    picker.dataSource = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n请选择语种" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert.view addSubview:picker];
    
    [picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.right.and.left.equalTo(alert.view);
        make.height.mas_equalTo(180);
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger index = [picker selectedRowInComponent:0];
        if (_modelType == ComponentModelTypeNewBook) {
            _newbookModel.languageType = self.languageParaArr[index];
            [_newbookModel search];
        } else {
            _mostModel.languageType = self.languageParaArr[index];
            [_mostModel search];
        }
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self.viewController presentViewController:alert animated:YES completion:^{}];
}

- (void)selectType {
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.tag = 102;
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
        if (_modelType == ComponentModelTypeNewBook) {
            _newbookModel.sortType = self.typeParaArr[index];
            [_newbookModel search];
        } else {
            _mostModel.sortType = self.typeParaArr[index];
            [_mostModel search];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self.viewController presentViewController:alert animated:YES completion:^{}];
}

- (void)selectDate {
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.tag = 103;
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
        if (_modelType == ComponentModelTypeNewBook) {
            _newbookModel.date = _dateParaArr[index];
            [_newbookModel search];
        } else {
            _mostModel.date = _dateParaArr[index];
            [_mostModel search];
        }
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self.viewController presentViewController:alert animated:YES completion:^{}];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(component:didSelectedString:)]) {
        [self.delegate component:self didSelectedString:_strings[indexPath.row]];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.strings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefalutCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefalutCellId];
    }
    cell.textLabel.text = self.strings[indexPath.row];
    cell.textLabel.textColor = [UIColor beautyBlue];
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    return cell;
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
        return self.languageArr.count;
    } else if (pickerView.tag == 102) {
        return self.typeArr.count;
    } else {
        return _dateArr.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 101) {
        return [self.languageArr objectAtIndex:row];
    } else if (pickerView.tag == 102) {
        return [self.typeArr objectAtIndex:row];
    } else {
        return [_dateArr objectAtIndex:row];
    }
}

#pragma mark - Getter
- (UIView *)view {
    if (!_view) {
        _view = [[UIView alloc] init];
        
        [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(self.view);
            make.height.mas_equalTo(44);
        }];
        
        float width = SCREEN_WIDTH_ACTUAL / 3;
        [self.languageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.and.left.equalTo(self.selectView);
            make.width.mas_equalTo(width);
        }];
        
        [self.typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self.selectView);
            make.left.equalTo(self.languageBtn.mas_right);
            make.width.mas_equalTo(width);
        }];
        
        [self.dateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.and.right.equalTo(self.selectView);
            make.left.equalTo(self.typeBtn.mas_right);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.selectView.mas_bottom);
            make.left.and.right.and.bottom.equalTo(self.view);
            make.height.mas_equalTo(self.strings.count * 44 == 0 ?: self.strings.count * 44);
        }];
    }
   return _view;
}

- (UIView *)selectView {
    if (!_selectView) {
        _selectView = [[UIView alloc] init];
        [self.view addSubview:_selectView];
    }
   return _selectView;
}

- (UIButton *)languageBtn {
    if (!_languageBtn) {
        _languageBtn = [[UIButton alloc] init];
        [_languageBtn setTitle:@"语种" forState:UIControlStateNormal];
        [_languageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_languageBtn addTarget:self action:@selector(selectLanguage) forControlEvents:UIControlEventTouchUpInside];
        [self.selectView addSubview:_languageBtn];
    }
   return _languageBtn;
}

- (UIButton *)typeBtn {
    if (!_typeBtn) {
        _typeBtn = [[UIButton alloc] init];
        [_typeBtn setTitle:@"分类" forState:UIControlStateNormal];
        [_typeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_typeBtn addTarget:self action:@selector(selectType) forControlEvents:UIControlEventTouchUpInside];
        [self.selectView addSubview:_typeBtn];
    }
   return _typeBtn;
}

- (UIButton *)dateBtn {
    if (!_dateBtn) {
        _dateBtn = [[UIButton alloc] init];
        [_dateBtn setTitle:@"日期" forState:UIControlStateNormal];
        [_dateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_dateBtn addTarget:self action:@selector(selectDate) forControlEvents:UIControlEventTouchUpInside];
        [self.selectView addSubview:_dateBtn];
    }
   return _dateBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollEnabled = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 16.0, 0, 16.0);
        [self.view addSubview:_tableView];
    }
   return _tableView;
}

- (NSArray<NSString *> *)languageArr
{
   if (!_languageArr) {
       _languageArr = @[@"全部",@"中文文献库",@"外文文献库"];
    }
   return _languageArr;
}

- (NSArray<NSString *> *)languageParaArr
{
    if (!_languageParaArr) {
        _languageParaArr = @[@"ALL",@"01",@"02"];
    }
    return _languageParaArr;
}

- (NSArray<NSString *> *)typeArr {
    if (!_typeArr) {
        _typeArr = @[@"全部",@"马列主义、毛泽东思想、邓小平理论",@"宗教、哲学",@"社会科学总论",@"政治、法律",@"军事",@"经济",@"文化、科学、教育、体育",@"语言、文字",@"文学",@"艺术",@"历史、地理",@"自然科学总论",@"数理科学与化学",@"数学",@"力学",@"物理学1",@"物理学2",@"化学",@"晶体学",@"天文学、地球科学",@"生物科学",@"医药、卫生",@"农业科学",@"工业技术",@"一般工业技术",@"矿业工程",@"石油、天然气工业",@"冶金工业",@"金属学与金属工艺",@"机械、仪表工业",@"武器工业",@"能源与动力工程",@"原子能技术",@"电子技术",@"无线电电子学、电信技术",@"自动化技术、计算机技术",@"化学工业",@"轻工业、手工业",@"建筑科学",@"水利工程",@"交通运输",@"航空、航天",@"环境科学、安全科学",@"综合性图书"];
    }
    return _typeArr;
}

- (NSArray<NSString *> *)typeParaArr {
    if (!_typeParaArr) {
        _typeParaArr = @[@"ALL",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"N",@"O",@"O2",@"O3",@"O4",@"O5",@"O6",@"O7",@"P",@"Q",@"R",@"S",@"T",@"TB",@"TD",@"TE",@"TF",@"TG",@"TH",@"TJ",@"TK",@"TL",@"TM",@"TN",@"TP",@"TQ",@"TS",@"TU",@"TV",@"U",@"V",@"X",@"Z"];
    }
    return _typeParaArr;
}

#pragma mark - Setter
- (void)setStrings:(NSArray<NSString *> *)strings {
    _strings = strings;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.strings.count * 44 == 0 ?: self.strings.count * 44);
    }];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
}


@end
