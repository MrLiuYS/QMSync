//
//  Service.m
//  QMSync
//
//  Created by Lin on 15/7/1.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "Service.h"

@implementation Service

+ (instancetype)sharedClient {
    static Service *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Service alloc] initWithBaseURL:[NSURL URLWithString:kBaseURLString]];

        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        
    });
    
    return _sharedClient;
}
+ (NSString *)FMDBPath {
    
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Identifer = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    
    NSLog(@"%@",docsdir);
    return [NSString stringWithFormat:@"%@/%@.db",docsdir,app_Identifer];
    
}

+ (FMDatabase *)db {
    FMDatabase *_db = [FMDatabase databaseWithPath:[Service FMDBPath]];
    if ([_db open]) {
        
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS fengshucity (href TEXT PRIMARY KEY, title TEXT)"];
        
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS fengshu (href TEXT PRIMARY KEY, title TEXT, info TEXT)"];
    }
    
    return _db;
}

@end
