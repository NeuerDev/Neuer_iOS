//
//  EcardViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/10.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardViewController.h"

#import "EcardModel.h"

@interface EcardViewController ()
@property (nonatomic, strong) EcardModel *ecardLoginModel;

@property (nonatomic, strong) UITextField *textField;
@end

@implementation EcardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"校园卡中心";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    imageView.backgroundColor = [UIColor beautyBlue];
    [self.view addSubview:imageView];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 200, 200, 100)];
    _textField.backgroundColor = [UIColor beautyPurple];
    [self.view addSubview:_textField];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 200, 100)];
    button.backgroundColor = [UIColor beautyGreen];
    [button setTitle:@"login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self.ecardLoginModel getVerifyImage:^(UIImage *verifyImage, NSString *message) {
        imageView.image = verifyImage;
    }];
}

- (void)login {
    [self.ecardLoginModel authorUser:@"20144786" password:@"951202" verifyCode:_textField.text callBack:^(BOOL success, NSString *message) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter

- (EcardModel *)ecardLoginModel {
    if (!_ecardLoginModel) {
        _ecardLoginModel = [[EcardModel alloc] init];
    }
    
    return _ecardLoginModel;
}

@end
