//
//  LibraryRecommendViewController.m
//  NEUer
//
//  Created by kl h on 2017/11/9.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryRecommendViewController.h"
#import "NEUInputView.h"
#import "LibraryRecommendModel.h"

@interface LibraryRecommendViewController () <UITextFieldDelegate,LibraryRecommedDelegate>
@property (nonatomic, strong) NEUInputView *titleView;
@property (nonatomic, strong) NEUInputView *authorView;
@property (nonatomic, strong) NEUInputView *pressView;
@property (nonatomic, strong) NEUInputView *yearOfPubView;
@property (nonatomic, strong) NEUInputView *ISBNView;
@property (nonatomic, strong) NEUInputView *priceView;
@property (nonatomic, strong) NEUInputView *numberView;
@property (nonatomic, strong) NEUInputView *reasonView;
@property (nonatomic, strong) NSMutableArray<NEUInputView *> *inputViewArr;
@property (nonatomic, strong) UIBarButtonItem *rightButtonItem;

@property (nonatomic, strong) LibraryRecommendModel *recommendModel;

@end

@implementation LibraryRecommendViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initConstraints];
}

#pragma mark - Init Methods

- (void)initData {
    [self setTitle:@"荐购新书"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:self.rightButtonItem];
}

- (void)initConstraints {
    UIView *firstView = self.inputViewArr.firstObject;
    [self.view addSubview:firstView];
    [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).with.offset(24);
        } else {
            make.top.equalTo(self.mas_topLayoutGuide).with.offset(24);
        }
        make.left.equalTo(self.view).with.offset(24);
        make.right.equalTo(self.view).with.offset(-24);
    }];

    for (NSInteger i = 1; i < self.inputViewArr.count; i++) {
        UIView *view = self.inputViewArr[i];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(firstView.mas_bottom).with.offset(24);
            make.left.right.equalTo(firstView);
        }];
        firstView = view;
    }
}

#pragma mark - Respond Methods
- (void)confirm {
//    if (self.titleView.textField.text.length == 0) {
//        return;
//    } else if (self.authorView.textField.text.length == 0) {
//        return;
//    } else if (self.pressView.textField.text.length == 0) {
//        return;
//    } else if (self.ISBNView.textField.text.length == 0) {
//        return;
//    } else if (self.reasonView.textField.text.length == 0) {
//        return;
//    } else {
        [self.recommendModel recommend];
//    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect frame = [textField convertRect:textField.frame toView:nil];
    NSInteger textFieldHeight = frame.origin.y;
    NSInteger viewHeight = SCREEN_HEIGHT_ACTUAL - 216 - 64;
    if (textFieldHeight > viewHeight) {
        [UIView animateWithDuration:0 animations:^{
            self.view.frame = CGRectMake(0, -216, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - LibraryRecommedDelegate
- (void)recommendDidSuccess {
    
}

- (void)recommendDidFail:(NSString *)errorMessage {
    
}

#pragma mark - Getter
- (NSMutableArray<NEUInputView *> *)inputViewArr {
    if (!_inputViewArr) {
        _inputViewArr = [NSMutableArray array];

        _titleView = [[NEUInputView alloc] initWithInputType:NEUInputTypeDefault];
        _titleView.titleLabel.text = @"题名";
        _titleView.textField.delegate = self;
        _titleView.textField.tag = 101;
        [_inputViewArr addObject:_titleView];
        [self.view addSubview:_titleView];

        _authorView = [[NEUInputView alloc] initWithInputType:NEUInputTypeDefault];
        _authorView.titleLabel.text = @"作者";
        _authorView.textField.delegate = self;
        [_inputViewArr addObject:_authorView];
        [self.view addSubview:_authorView];

        _pressView = [[NEUInputView alloc] initWithInputType:NEUInputTypeDefault];
        _pressView.titleLabel.text = @"出版社";
        _pressView.textField.delegate = self;
        [_inputViewArr addObject:_pressView];

        _ISBNView = [[NEUInputView alloc] initWithInputType:NEUInputTypeDefault];
        _ISBNView.titleLabel.text = @"ISBN/ISSN";
        _ISBNView.textField.delegate = self;
        [_inputViewArr addObject:_ISBNView];

        _reasonView = [[NEUInputView alloc] initWithInputType:NEUInputTypeDefault];
        _reasonView.titleLabel.text = @"荐购理由";
        _reasonView.textField.delegate = self;
        [_inputViewArr addObject:_reasonView];

    }
   return _inputViewArr;
}

- (UIBarButtonItem *)rightButtonItem {
    if (!_rightButtonItem) {
        _rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];
    }
   return _rightButtonItem;
}

- (LibraryRecommendModel *)recommendModel {
    if (!_recommendModel) {
        _recommendModel = [[LibraryRecommendModel alloc] init];
        _recommendModel.delegate = self;
    }
   return _recommendModel;
}




@end
