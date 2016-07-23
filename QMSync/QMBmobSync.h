//
//  QMBmobSync.h
//  QMSync
//
//  Created by 刘永生 on 16/7/23.
//  Copyright © 2016年 QiMENG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMBmobSync : NSObject

@property (nonatomic,copy) NSString *bmobKey;/**< bmob 注册key */

@property (nonatomic,copy) NSString *bmobTable;/**< bmob 表 */

@property (nonatomic,copy) NSString *bmobTableKey;/**< bmob 表 列 */

/**
 *  如果开启随机数.就在online 跟offline 数值之间随机产生
 *  如果传入bmobTableKeyObject
 */
@property (nonatomic,copy) NSString *bmobTableKeyObject;/**< 同步的列值 */
@property (nonatomic, assign) BOOL isRandom; /**< 是否开启随机数 默认不开启,去读 bmobTableKeyObject*/
@property (nonatomic, assign) int intOnline; /**< 随机数上线 */
@property (nonatomic, assign) int intOffline; /**< 随机数下线 */

@property (nonatomic,copy) NSString *bmobSyncIden;/**< 用来判断是否已经同步过,每次需要手动调整 */

- (void)startSyncBmobBlock:(void (^)(BOOL isSuccessful, NSError *error))block;

@end
