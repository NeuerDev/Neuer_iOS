//
//  GatewayComponentInfoView.m
//  NEUer
//
//  Created by lanya on 2017/10/16.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "GatewayComponentInfoView.h"
#import "GatewayComponentInfoLb.h"
#import "Masonry.h"
#import "LYTool.h"

@interface GatewayComponentInfoView ()

@property (nonatomic, strong) GatewayComponentInfoLb *userIdLb;
@property (nonatomic, strong) GatewayComponentInfoLb *balanceLb;
@property (nonatomic, strong) GatewayComponentInfoLb *flowLb;
@property (nonatomic, strong) GatewayComponentInfoLb *ipLb;
@property (nonatomic, strong) GatewayComponentInfoLb *timeLb;

//@property (nonatomic, assign) GatewayComponentInfoType infoType;
@property (nonatomic, strong) GatewayBean *bean;

@end

@implementation GatewayComponentInfoView

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setUpWithGatewayBean:(GatewayBean *)bean {
    
    _bean = bean;
    [self setUpData];
}

- (void)setUpData {
    
    self.userIdLb.text = [NSString stringWithFormat:@"当前用户名： %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"account"]];
    CGSize userLbSize = [LYTool sizeWithString:_balanceLb.text font:_userIdLb.font];
    self.balanceLb.bounds = CGRectMake(0, 0, userLbSize.width, userLbSize.height);
    
    CGFloat flowRoundValue = [self.bean.flow floatValue]  / 1000000000;
    self.flowLb.text = [NSString stringWithFormat:@"已用流量：%.2f G", flowRoundValue];
    CGSize flowLbSize = [LYTool sizeWithString:_flowLb.text font:_flowLb.font];
    self.flowLb.bounds = CGRectMake(0, 0, flowLbSize.width, flowLbSize.height);
    
    self.balanceLb.text = [NSString stringWithFormat:@"当前余额：¥ %@", self.bean.balance];
    CGSize balanceLbSize = [LYTool sizeWithString:_balanceLb.text font:_balanceLb.font];
    self.balanceLb.bounds = CGRectMake(0, 0, balanceLbSize.width, balanceLbSize.height);
    
    self.timeLb.text = [NSString stringWithFormat:@"已用时长：%@", [LYTool getMMSSFromSS:self.bean.time]];
    CGSize timeLbSize = [LYTool sizeWithString:_timeLb.text font:_timeLb.font];
    self.timeLb.bounds = CGRectMake(0, 0, timeLbSize.width, timeLbSize.height);
    
    self.ipLb.text = [NSString stringWithFormat:@"ip地址：%@", self.bean.ip];
    CGSize ipLbSize = [LYTool sizeWithString:_ipLb.text font:_ipLb.font];
    self.timeLb.bounds = CGRectMake(0, 0, ipLbSize.width, ipLbSize.height);
    
    [self initConstraints];
}

- (void)initConstraints {
    
    [self.userIdLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.equalTo(self.mas_top).with.offset(20);
    }];

    [self.timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.userIdLb);
        make.top.equalTo(self.userIdLb.mas_bottom).with.offset(20);
    }];
    [self.flowLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.userIdLb);
        make.top.equalTo(self.timeLb.mas_bottom).with.offset(20);
    }];
    [self.balanceLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.userIdLb);
        make.top.equalTo(self.flowLb.mas_bottom).with.offset(20);
    }];
    [self.ipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.userIdLb);
        make.top.equalTo(self.balanceLb.mas_bottom).with.offset(20);
    }];
    
}


#pragma mark - GETTER
- (GatewayComponentInfoLb *)flowLb {
    if (!_flowLb) {
        _flowLb = [[GatewayComponentInfoLb alloc] init];
        
        [self addSubview:_flowLb];
    }
    return _flowLb;
}

- (GatewayComponentInfoLb *)balanceLb {
    if (!_balanceLb) {
        _balanceLb = [[GatewayComponentInfoLb alloc] init];
        
        [self addSubview:_balanceLb];
    }
    return _balanceLb;
}

- (GatewayComponentInfoLb *)timeLb {
    if (!_timeLb) {
        _timeLb = [[GatewayComponentInfoLb alloc] init];
        
        [self addSubview:_timeLb];
    }
    return _timeLb;
}

- (GatewayComponentInfoLb *)ipLb {
    if (!_ipLb) {
        _ipLb = [[GatewayComponentInfoLb alloc] init];
        
        [self addSubview:_ipLb];
    }
    return _ipLb;
}

- (GatewayComponentInfoLb *)userIdLb {
    if (!_userIdLb) {
        _userIdLb = [[GatewayComponentInfoLb alloc] init];
        [self addSubview:_userIdLb];
    }
    return _userIdLb;
}

@end
