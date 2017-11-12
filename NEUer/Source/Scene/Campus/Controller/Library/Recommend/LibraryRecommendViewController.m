//
//  LibraryRecommendViewController.m
//  NEUer
//
//  Created by kl h on 2017/11/9.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "LibraryRecommendViewController.h"
#import "LoginViewController.h"

@interface LibraryRecommendViewController ()
//@property (nonatomic, strong) LoginInputView *titleView;
//@property (nonatomic, strong) LoginInputView *authorView;
//@property (nonatomic, strong) LoginInputView *pressView;
//@property (nonatomic, strong) LoginInputView *yearOfPubView;
//@property (nonatomic, strong) LoginInputView *ISBNView;
//@property (nonatomic, strong) LoginInputView *priceView;
//@property (nonatomic, strong) LoginInputView *numberView;
//@property (nonatomic, strong) LoginInputView *reasonView;

@end

@implementation LibraryRecommendViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
}

- (void)initData {
    [self setTitle:@"荐购新书"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)initConstraints {
//    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
//
//    }];
}

#pragma mark - Getter
//- (LoginInputView *)titleView {
//    if (!_titleView) {
//        _titleView = [[LoginInputView alloc] initWithInputType:LoginInputTypeAccount];
//        [self.view addSubview:_titleView];
//    }
//   return _titleView;
//}

@end
