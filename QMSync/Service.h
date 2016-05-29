//
//  Service.h
//  QMSync
//
//  Created by Lin on 15/7/1.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <GDataXMLNode.h>
#import <FMDB.h>
#import "Model.h"



@interface Service : AFHTTPSessionManager

+ (instancetype)fengshuClient;

+ (FMDatabase *)db;


+ (id)fengshuBaseBlock:(void (^)(NSArray *array, NSError *error))block;

+ (NSArray *)readFengSu;

+ (NSArray *)readFengSuSubCity;

+ (NSArray <NSDictionary*> *)readAllData;

@end
