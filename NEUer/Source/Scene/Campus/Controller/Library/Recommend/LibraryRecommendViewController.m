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
//@property (nonatomic, strong) LoginInputView *titleTF;
//@property (nonatomic, strong) LoginInputView *authorTF;
//@property (nonatomic, strong) LoginInputView *pressTF;
//@property (nonatomic, strong) LoginInputView *yearOfPubTF;
//@property (nonatomic, strong) LoginInputView *ISBNTF;
//@property (nonatomic, strong) LoginInputView *priceTF;
//@property (nonatomic, strong) LoginInputView *numberTF;
//@property (nonatomic, strong) LoginInputView *reasonTF;

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

#pragma mark - Getter

@end
