//
//  QMBmobSync.m
//  QMSync
//
//  Created by 刘永生 on 16/7/23.
//  Copyright © 2016年 QiMENG. All rights reserved.
//

#import "QMBmobSync.h"

#import <BmobSDK/Bmob.h>

#define kBmobKey @""

#define kLimitNumber 50


@implementation QMBmobSync


- (void)setBmobKey:(NSString *)bmobKey {
    
    _bmobKey = bmobKey;
    
    [Bmob registerWithAppKey:_bmobKey];
    
}


- (void)syncTableName:(NSString *)aTableName
              keyName:(NSString *)aKeyName
                block:(void (^)(BOOL isSuccessful, NSError *error))block{
    
    
    BmobQuery   *bquery = [BmobQuery queryWithClassName:aTableName];
    
    bquery.limit = kLimitNumber;
    bquery.skip = 0 ;
    
    [bquery whereKey:@"bmobSyncIden" notEqualTo:self.bmobSyncIden];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (error) {
            
        } else {
            
            if (array.count > 0) {
                
                BmobObjectsBatch *batch = [[BmobObjectsBatch alloc] init] ;
                
                for (BmobObject * object in array) {
                    
                    int intRandom = 0;
                    
                    if (_isRandom) {
                        
                        intRandom = arc4random()%_intOnline + _intOffline;
                        
                    }
                    
                    [batch updateBmobObjectWithClassName:self.bmobTable
                                                objectId:object.objectId
                                              parameters:@{self.bmobTableKey: _isRandom ? @(intRandom) : _bmobTableKeyObject,
                                                           @"bmobSyncIden":self.bmobSyncIden}];
                    
                }
                
                [batch batchObjectsInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    
                    if (isSuccessful) {
                        
                        NSLog(@"更新数据片段成功");
                    }else {
                        NSLog(@"更新数据片段异常:%@",error.description);
                    }
                    
                    [self syncTableName:aTableName keyName:aKeyName block:^(BOOL isSuccessful, NSError *error) {
                        
                    }];
                    
                }];
                
            }
            else {
                NSLog(@"同步结束");
                
                block(YES,nil);
            }
            
        }
    }];
    
}



- (void)startSyncBmobBlock:(void (^)(BOOL isSuccessful, NSError *error))block  {
    
    [self syncTableName:self.bmobTable keyName:self.bmobTableKey block:^(BOOL isSuccessful, NSError *error) {
        
        block(isSuccessful,error);
        
    }];
    
}


@end
