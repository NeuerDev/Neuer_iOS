//
//  SearchListComponent.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "SearchListComponent.h"

#import <Masonry/Masonry.h>

#import "UIColor+JHCategory.h"

const CGFloat kSearchListHeaderHeight = 34.0f;
const CGFloat kSearchListCellHeight = 44.0f;
const CGFloat kSearchListContentOffset = 16.0f;
NSString * const kSearchListCellId = @"kSearchListCellId";

@interface SearchListComponent() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *view;
@end

@implementation SearchListComponent

#pragma mark - Init Methods

- (instancetype)initWithTitle:(NSString *)title action:(NSString *)action {
    if (self = [super init]) {
        self.titleLabel.text = title;
        [self.actionButton setTitle:action forState:UIControlStateNormal];
    }
    
    return self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate component:self didSelectedString:_strings[indexPath.row]];
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSearchListCellId];
    
    cell.textLabel.text = _strings[indexPath.row];
    cell.textLabel.textColor = [UIColor beautyBlue];
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSearchListCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _strings.count;
}

#pragma mark - Getter

- (UIView *)view {
    if (!_view) {
        _view = [[UIView alloc] init];
        
        [_view addSubview:self.titleLabel];
        [_view addSubview:self.actionButton];
        [_view addSubview:self.tableView];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_view).with.offset(kSearchListContentOffset);
            make.left.equalTo(_view.mas_left).with.offset(kSearchListContentOffset);
            make.height.mas_equalTo(kSearchListHeaderHeight);
        }];

        [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_view).with.offset(kSearchListContentOffset);
            make.right.equalTo(_view.mas_right).with.offset(-kSearchListContentOffset);
            make.height.mas_equalTo(kSearchListHeaderHeight);
        }];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(_view);
            make.top.equalTo(_view.mas_top).with.offset(kSearchListHeaderHeight+kSearchListContentOffset);
            make.height.mas_equalTo(@(_strings.count*kSearchListCellHeight==0?:_strings.count*kSearchListCellHeight-1))
            .priorityHigh();
            make.bottom.equalTo(_view.mas_bottom);
        }];
    }
    
    return _view;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorInset = UIEdgeInsetsMake(0, kSearchListContentOffset, 0, kSearchListContentOffset);
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSearchListCellId];
    }
    
    return _tableView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }
    
    return _titleLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        [_actionButton setTitleColor:[UIColor beautyBlue] forState:UIControlStateNormal];
        _actionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
    }
    
    return _actionButton;
}

#pragma mark - Setter

- (void)setStrings:(NSArray<NSString *> *)strings {
    [self setStrings:strings animated:NO];
}

- (void)setStrings:(NSArray<NSString *> *)strings animated:(BOOL)animated {
    if (!strings) {
        return;
    }
    _strings = strings;
    
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(_strings.count*kSearchListCellHeight==0?:_strings.count*kSearchListCellHeight-1))
        .priorityHigh();
    }];
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [_tableView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [_tableView reloadData];
        }];
    }
}

@end
