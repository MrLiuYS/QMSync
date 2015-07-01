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

#define kBaseURLString @"http://fengsu.m.supfree.net/"


@interface Service : AFHTTPSessionManager

+ (instancetype)sharedClient;

+ (FMDatabase *)db;


@end
