//
//  HomeViewController.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/9/17.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "TelevisionWallViewController.h"

@interface HomeViewController ()

@property (strong, nonatomic) LoginViewController *loginVC;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"HomeNavigationBarTitle", nil);
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"校内电视" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor blueColor];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.frame = CGRectMake(100, 300, 200, 100);
    
    UIButton *button1 = [[UIButton alloc] init];
    [button1 setTitle:@"有验证码未登录" forState:UIControlStateNormal];
    button1.titleLabel.textColor = [UIColor blueColor];
    button1.backgroundColor = [UIColor redColor];
    [button1 addTarget:self action:@selector(pushLoginVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    button1.frame = CGRectMake(100, 500, 200, 100);
    
//    NSString *searchText = @"<a href=\"http://202.118.8.7:8991/F/LEY3T5AGIRF63BPS1PLKUX1EPLYF8UDEQAH88FA3J15YAL86YR-83545?func=item-global&amp;doc_library=NEU01&amp;doc_number=000576232\" onmouseover=\"clearTimeout(tm);hint('<tr><td class=libnname><A HREF=http://202.118.8.7:8991/F/LEY3T5AGIRF63BPS1PLKUX1EPLYF8UDEQAH88FA3J15YAL86YR-83546?func=item-global&amp;doc_library=NEU01&amp;doc_number=000576232&amp;year=&amp;volume=&amp;sub_library=NHPTW >南湖普通外借</A></td><td class=bookid>TN929.53/665<td class=holding>     4/     0</td>',this)\" onmouseout=\"tm=setTimeout(function(){g('bubble2').style.display='none';},400)\">馆藏复本:     4，已出借复本:     0</a>";
//    NSError *error = NULL;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?:[^,])*\\." options:NSRegularExpressionCaseInsensitive error:&error];
//    NSTextCheckingResult *result = [regex firstMatchInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
//    if (result) {
//        NSLog(@"%@\n", [searchText substringWithRange:result.range]);
//    }
}

- (void)push {
    [self.navigationController pushViewController:[[TelevisionWallViewController alloc] init] animated:YES];
}

- (void)pushLoginVC {
    [self presentViewController:self.loginVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (LoginViewController *)loginVC {
    if (!_loginVC) {
        _loginVC = [[LoginViewController alloc] initWithLoginState:LoginStateNeverLoginWithVerificationCode];
        [_loginVC setUpWithLoginVerificationcodeImg:[UIImage imageNamed:@"verificationcode"]];
        [_loginVC setDidLoginWithSuccessMsg:^(NSArray *msgArr) {
            NSLog(@"%@", msgArr);
        } FailureMsg:^(NSString *msg) {
            NSLog(@"%@", msg);
        }];
    }
    return _loginVC;
}
@end
