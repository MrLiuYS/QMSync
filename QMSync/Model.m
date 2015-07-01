//
//  Model.m
//  QMSync
//
//  Created by Lin on 15/7/1.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "Model.h"

@implementation Model

- (instancetype)initHref:(NSString *)aHref title:(NSString *)aTitle
{
    return [self initHref:aHref title:aTitle info:@"" parent:@"" parentHref:@""];
}

- (instancetype)initParentHref:(NSString *)aParentHref parent:(NSString *)aParent
{
    return [self initHref:@"" title:@"" info:@"" parent:aParent parentHref:aParentHref];
}

- (instancetype)initHref:(NSString *)aHref title:(NSString *)aTitle parent:(NSString *)aParent parentHref:(NSString *)aParentHref
{
    return [self initHref:aHref title:aTitle info:@"" parent:aParent parentHref:aParentHref];
}

- (instancetype)initHref:(NSString *)aHref title:(NSString *)aTitle info:(NSString *)aInfo parent:(NSString *)aParent parentHref:(NSString *)aParentHref
{
    self = [super init];
    if (self) {
        _href = aHref;
        _title = aTitle;
        _info = aInfo;
        _parent = aParent;
        _parentHref = aParentHref;
    }
    return self;
}
@end
