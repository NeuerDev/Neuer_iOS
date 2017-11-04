//
//  GatewaySelfServiceMenuModel.h
//  NEUer
//
//  Created by lanya on 2017/11/1.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GatewaySelfServiceMenuGetVerifyImageBlock)(UIImage *verifyImage, NSString *msg);
typedef void(^GatewaySelfServiceMenuLoginBlock)(BOOL success, NSString *msg);
typedef void(^GatewaySelfServiceMenuQueryBlock)(BOOL success, NSString *data);

//基础信息
@interface GatewaySelfServiceMenuBasicInfoBean : NSObject

//用户信息
@property (nonatomic, strong) NSString *user_name; // 姓名
@property (nonatomic, strong) NSString *user_number; // 学号
@property (nonatomic, strong) NSString *user_E_walletBalance; // 电子钱包

//产品信息
@property (nonatomic, strong) NSString *product_ID; // 产品ID
@property (nonatomic, strong) NSString *product_name; // 产品名称
@property (nonatomic, strong) NSString *product_accountingStrategy; // 计费策略
@property (nonatomic, strong) NSString *product_usedFlow; // 已用流量
@property (nonatomic, strong) NSString *product_usedDuration; // 已用时长
@property (nonatomic, strong) NSString *product_usedTimes; // 已用次数
@property (nonatomic, strong) NSString *product_usedAmount; // 已用金额
@property (nonatomic, strong) NSString *product_balance; // 产品余额
@property (nonatomic, strong) NSString *product_carrierBundle; // 运营商绑定
@property (nonatomic, strong) NSString *product_closingDate; // 结算日期

@end

// 在线信息
@interface GatewaySelfServiceMenuOnlineInfoBean : NSObject

@property (nonatomic, strong) NSString *online_number; // 账号
@property (nonatomic, strong) NSString *online_ipAddress; // IP地址
@property (nonatomic, strong) NSString *online_productName; // 产品名称
@property (nonatomic, strong) NSString *online_lastactive; // 上线时间
@property (nonatomic, strong) NSString *online_operation; // 操作系统
@property (nonatomic, strong) NSString *online_AccountingStrategy; // 计费策略

@end

// 上网明细信息
@interface GatewaySelfServiceMenuInternetRecordsInfoBean : NSObject

@property (nonatomic, strong) NSString *internet_number; // 账号
@property (nonatomic, strong) NSString *internet_lastactive; // 上线时间
@property (nonatomic, strong) NSString *internet_logoutTime; // 下线时间
@property (nonatomic, strong) NSString *internet_ipAddress; // ip地址
@property (nonatomic, strong) NSString *internet_operation; // 操作系统
@property (nonatomic, strong) NSString *internet_usedFlow; // 流量
@property (nonatomic, strong) NSString *internet_usedDuration; // 时长
@property (nonatomic, strong) NSString *internet_usedFee; // 费用

@end

//  缴费清单
@interface GatewaySelfServiceMenuFinancialPayInfoBean : NSObject

@property (nonatomic, strong) NSString *financial_number; //账号
@property (nonatomic, strong) NSString *financial_payAmmount; //缴费金额(元)
@property (nonatomic, strong) NSString *financial_type; // 缴费类型
@property (nonatomic, strong) NSString *financial_payWay; // 支付方式
@property (nonatomic, strong) NSString *financial_product; // 产品
@property (nonatomic, strong) NSString *financial_creatTime; // 创建时间
@property (nonatomic, strong) NSString *financial_administrator; // 管理员

@end

//  结算清单
@interface GatewaySelfServiceMenuFinancialCheckOutInfoBean : NSObject

@property (nonatomic, strong) NSString *checkout_number; //账号
@property (nonatomic, strong) NSString *checkout_payAmmount; //缴费金额(元)
@property (nonatomic, strong) NSString *checkout_product; // 产品
@property (nonatomic, strong) NSString *checkout_combo; // 套餐
@property (nonatomic, strong) NSString *checkout_flow; // 流量
@property (nonatomic, strong) NSString *checkout_time; // 时长
@property (nonatomic, strong) NSString *checkout_creatTime; // 创建时间

@end

@interface GatewaySelfServiceMenuModel : NSObject

@property (nonatomic, strong) GatewaySelfServiceMenuBasicInfoBean *basicInfo;
@property (nonatomic, strong) GatewaySelfServiceMenuOnlineInfoBean *onlineInfo;

@property (nonatomic, copy) NSMutableArray <GatewaySelfServiceMenuInternetRecordsInfoBean *> *internetRecordInfoArray;
@property (nonatomic, copy) NSMutableArray <GatewaySelfServiceMenuFinancialPayInfoBean *> *financialPayInfoArray;
@property (nonatomic, copy) NSMutableArray <GatewaySelfServiceMenuFinancialCheckOutInfoBean *> *financialCheckoutInfoArray;

/**
 获取验证码
 */
- (void)getVerifyImage:(GatewaySelfServiceMenuGetVerifyImageBlock)block;

/**
 登录IP网关
 */
- (void)loginGatewaySelfServiceMenuWithUser:(NSString *)account password:(NSString *)password verifyCode:(NSString *)verifyCode loginState:(GatewaySelfServiceMenuLoginBlock)block;

/**
 查询用户套餐基本信息
 */
- (void)queryUserBasicInformationListComplete:(GatewaySelfServiceMenuQueryBlock)block;

/**
 查询上网信息
 */
- (void)queryUserOnlineInformationListComplete:(GatewaySelfServiceMenuQueryBlock)block;

/**
 修改用户密码
 */
- (void)modifyPasswordForIPGWwithOldPassword:(NSString *)oldpassword newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword Complete:(GatewaySelfServiceMenuQueryBlock)block;

/**
 获取用户上网明细
 */
- (void)queryUserOnlineLogDetailListComplete:(GatewaySelfServiceMenuQueryBlock)block;

/**
 获取用户缴费记录
*/
- (void)queryUserOnlineFinancialPayListComplete:(GatewaySelfServiceMenuQueryBlock)block;

/**
 用户结算清单
 */
- (void)queryUserFinancialCheckOutListComlete:(GatewaySelfServiceMenuQueryBlock)block;

/**
 刷新数据
 */
- (void)refreshData;

@end
