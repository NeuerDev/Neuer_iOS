//
//  HomeComponentAccessView.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeComponentAccessView.h"

@interface HomeComponentAccessView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation HomeComponentAccessView

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        self.titleLabel.text = @"快速链接";
        [self.actionButton setTitle:@"更多" forState:UIControlStateNormal];
        
        [self initConstraints];
    }
    
    return self;
}

- (void)initConstraints {
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDataSource



#pragma mark - Getter

- (UIView *)bodyView {
    return self.contentView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 355, 375)];
        
        UIView *view1 = [[UIView alloc] init];
        view1.backgroundColor = [UIColor beautyRed];
        UIView *view2 = [[UIView alloc] init];
        view2.backgroundColor = [UIColor beautyBlue];
        UIView *view3 = [[UIView alloc] init];
        view3.backgroundColor = [UIColor beautyGreen];
        UIView *view4 = [[UIView alloc] init];
        view4.backgroundColor = [UIColor beautyPurple];
        [_contentView addSubview:view1];
        [_contentView addSubview:view2];
        [_contentView addSubview:view3];
        [_contentView addSubview:view4];
        [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(_contentView);
            make.width.mas_equalTo(@(150));
            make.height.mas_equalTo(@(90));
            make.bottom.equalTo(view3.mas_top).with.offset(-16);
        }];
        [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.right.equalTo(_contentView);
            make.width.mas_equalTo(@(150));
            make.height.mas_equalTo(@(90));
        }];
        [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.left.equalTo(_contentView);
            make.width.mas_equalTo(@(150));
            make.height.mas_equalTo(@(90));
        }];
        [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.right.equalTo(_contentView);
            make.width.mas_equalTo(@(150));
            make.height.mas_equalTo(@(90));
        }];
        [self addSubview:_contentView];
    }
    
    return _contentView;
}

@end
