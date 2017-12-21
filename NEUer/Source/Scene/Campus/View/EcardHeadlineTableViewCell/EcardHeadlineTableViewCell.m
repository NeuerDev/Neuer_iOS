//
//  EcardHeadlineTableViewCell.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/12/20.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardHeadlineTableViewCell.h"

@implementation EcardHeadlineTableViewCell

#pragma mark - Init Methods

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initConstraints];
        
        self.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        self.dk_backgroundColorPicker = DKColorPickerWithKey(background);
        
        self.contentView.userInteractionEnabled = YES;
        [self.contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onContentViewTapped:)]];
    }
    
    return self;
}

- (void)initConstraints {
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.mas_equalTo(@(24));
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).with.offset(16);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.arrowImageView.mas_right).with.offset(8);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.costLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-16);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Response Methods

- (void)onContentViewTapped:(UITapGestureRecognizer *)tap {
    _isExpand = !_isExpand;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15];
    
    if (_isExpand) {
        [_delegate willExpandHeadlineForIndexPath:_indexPath];
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    } else {
        [_delegate willCollapseHeadlineForIndexPath:_indexPath];
        self.arrowImageView.transform = CGAffineTransformMakeRotation(0);
    }
    
    [UIView commitAnimations];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)costLabel {
    if (!_costLabel) {
        _costLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_costLabel];
    }
    
    return _costLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
        [self.contentView addSubview:_arrowImageView];
    }
    
    return _arrowImageView;
}

@end
