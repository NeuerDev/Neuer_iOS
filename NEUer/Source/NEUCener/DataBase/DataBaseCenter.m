//
//  DataBaseCenter.m
//  NEUer
//
//  Created by Jiahong Xu on 2017/10/23.
//  Copyright © 2017年 Jiahong Xu. All rights reserved.
//

#import "DataBaseCenter.h"

static DataBaseCenter *_singletonCenter;

@interface DataBaseCenter ()
@property (strong, nonatomic) FMDatabase *db;
@end

@implementation DataBaseCenter

#pragma mark - Singleton

+ (instancetype)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletonCenter = [[super allocWithZone:NULL] init];
    });
    
    return _singletonCenter;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [DataBaseCenter defaultCenter];
}

- (id)copy {
    return [DataBaseCenter defaultCenter];
}

#pragma mark - Init Methods

- (instancetype)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)setup {
    [self initDatabase];
}

- (void)initDatabase {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/neuer.db"];
    _db = [FMDatabase databaseWithPath:path];
    
    if ([_db open]) {
        [self initTables];
    }
}

- (void)initTables {
    // user table
    NSString *sql = @"create table if not exists t_user (number text primary key, realName text, nickName text, sex integer, campus text, major text, imageData blob, avatarUrl text, wechatId text, qqId text, weiboId text, enrollDate integer, token text, lastLoginTime integer);"
    @"create table if not exists t_key (number text, keyType integer, password text);"
    @"create table if not exists t_ecard (number text primary key, state text, balance text, allowance text, status text, lastUpdateTime integer);"
    @"create table if not exists t_TV (number text not null, tv_sourceurl text, primary key (number, tv_sourceurl))";
    
    if ([_db executeStatements:sql]) {
        NSLog(@"数据库初始化成功");
    } else {
        NSLog(@"数据库初始化失败");
    }
}

#pragma mark - Public Methods
- (FMDatabase *)database {
    return _db;
}

@end
