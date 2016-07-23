//
//  Model.h
//  QMSync
//
//  Created by Lin on 15/7/1.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, copy) NSString * href;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * info;
@property (nonatomic, copy) NSString * parent;
@property (nonatomic, copy) NSString * parentHref;
@property (nonatomic, copy) NSString * related; //相关
@property (nonatomic, copy) NSString * author;  //作则
@property (nonatomic, copy) NSString * explain;
@property (nonatomic, copy) NSString * tag;

- (instancetype)initHref:(NSString *)aHref title:(NSString *)aTitle;

- (instancetype)initParentHref:(NSString *)aParentHref parent:(NSString *)aParent;

- (instancetype)initHref:(NSString *)aHref title:(NSString *)aTitle parent:(NSString *)aParent parentHref:(NSString *)aParentHref;

- (instancetype)initHref:(NSString *)aHref title:(NSString *)aTitle info:(NSString *)aInfo parent:(NSString *)aParent parentHref:(NSString *)aParentHref;

@end
