//
//  EcardModel.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/11.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "EcardModel.h"
#import "User.h"

@interface EcardModel () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSString *cookie;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) EcardLoginModel *loginModel;
@property (nonatomic, strong) EcardInfoModel *infoModel;
@property (nonatomic, strong) EcardServiceModel *serviceModel;
@property (nonatomic, strong) EcardHistoryModel *historyModel;

@end

@implementation EcardModel

- (void)loginWithUser:(NSString *)userName password:(NSString *)password complete:(EcardActionCompleteBlock)block {
    [self.loginModel loginWithUser:userName password:password complete:^(BOOL success, NSError *error) {
        if (success) {
            [[UserCenter defaultCenter] setAccount:userName password:password forKeyType:UserKeyTypeECard];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(success, error);
        });
    }];
}

- (void)fetchAvatarComplete:(EcardActionCompleteBlock)block {
    [self.infoModel fetchAvatarComplete:block];
}

- (void)queryInfoComplete:(EcardActionCompleteBlock)block {
    [self.infoModel queryInfoComplete:block];
}

- (void)queryTodayConsumeHistoryComplete:(EcardQueryConsumeCompleteBlock)block {
    [self.historyModel queryTodayConsumeHistoryComplete:block];
}

- (void)queryConsumeStatisicsComplete:(EcardActionCompleteBlock)block {
    
}

- (void)reportLostWithPassword:(NSString *)password
                identityNumber:(NSString *)identityNumber
                      complete:(EcardActionCompleteBlock)block {
    [self.serviceModel reportLostWithPassword:password
                               identityNumber:identityNumber
                                     complete:block];
}

- (void)changePasswordWithOldPassword:(NSString *)oldPassword
                          newPassword:(NSString *)newPassword
                        renewPassword:(NSString *)renewPassword
                             complete:(EcardActionCompleteBlock)block {
    [self.serviceModel changePasswordWithOldPassword:oldPassword
                                         newPassword:newPassword
                                       renewPassword:renewPassword
                                            complete:block];
}

#pragma mark - Getter

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{
                                                @"User-Agent":@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Safari/604.1.38",
                                                };
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    
    return _session;
}

- (EcardLoginModel *)loginModel {
    if (!_loginModel) {
        _loginModel = [[EcardLoginModel alloc] init];
    }
    
    return _loginModel;
}

- (EcardInfoModel *)infoModel {
    if (!_infoModel) {
        _infoModel = [[EcardInfoModel alloc] init];
    }
    
    return _infoModel;
}

- (EcardHistoryModel *)historyModel {
    if (!_historyModel) {
        _historyModel = [[EcardHistoryModel alloc] init];
    }
    
    return _historyModel;
}

- (EcardServiceModel *)serviceModel {
    if (!_serviceModel) {
        _serviceModel = [[EcardServiceModel alloc] init];
    }
    
    return _serviceModel;
}

- (EcardInfoBean *)info {
    return self.infoModel.info;
}

- (NSArray<EcardConsumeBean *> *)todayConsumeArray {
    return self.historyModel.todayConsumeArray;
}

- (NSArray<EcardConsumeBean *> *)consumeHistoryArray {
    return self.historyModel.consumeHistoryArray;
}

@end
