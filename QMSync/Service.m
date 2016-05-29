//
//  Service.m
//  QMSync
//
//  Created by Lin on 15/7/1.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "Service.h"

@implementation Service

#pragma mark - 数据转换成中文
+ (NSString *)encodingGBKFromData:(id)aData {
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *string = [[NSString alloc] initWithData:aData encoding:gbkEncoding];
    return string;
}
#pragma mark - 中文转换成GBK码
+ (NSString *)encodingBKStr:(NSString *)aStr {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    aStr = [aStr stringByAddingPercentEscapesUsingEncoding:enc];
    return aStr;
}


+ (instancetype)fengshuClient {
    static Service *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Service alloc] initWithBaseURL:[NSURL URLWithString:@"http://miyu.m.supfree.net/"]];
        
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sharedClient.operationQueue.maxConcurrentOperationCount = 1;
    });
    
    return _sharedClient;
}

+ (id)fengshuBaseBlock:(void (^)(NSArray *array, NSError *error))block
{
    [SVProgressHUD show];
    return [[Service fengshuClient] GET:@"index.asp"
                             parameters:nil
                                success:^(NSURLSessionDataTask *task, id responseObject) {
                                    
                                    block([self parseFengshuList:responseObject],nil);
                                    
                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    
                                    [SVProgressHUD showErrorWithStatus:@"数据错误,请稍后再试"];
                                    
                                }];
    
}
+ (NSArray *)parseFengshuList:(id)response {
    
    NSMutableArray * mainArray = [NSMutableArray array];
    
    @autoreleasepool {
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithHTMLData:response
                                                                  encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
                                                                     error:NULL];
        if (doc) {
            
            NSArray * trArray = [doc nodesForXPath:@"//table[@id='table1']" error:NULL];
            
            for (GDataXMLElement * item2 in trArray)
            {
                
                NSArray * tr = [item2  elementsForName:@"tr"];
                
                for (GDataXMLElement * element0 in tr) {
                    
                    NSArray * td = [element0  elementsForName:@"td"];
                    
                    for (GDataXMLElement * element1 in td) {
                        
                        NSArray * a = [element1  elementsForName:@"a"];
                        
                        for (GDataXMLElement * element in a) {
                            
                            NSLog(@"%@:%@",element.stringValue,[[element attributeForName:@"href"] stringValue]);
                            
                            if ([element attributeForName:@"href"]) {
                                
                                NSString * href = [[element attributeForName:@"href"] stringValue];
                                
                                Model * m = nil;
                                
                                if ([href hasPrefix:@"left"])
                                {
                                    m = [[Model alloc]initHref:href title:@"" parent:element.stringValue parentHref:href];
                                }
                                else
                                {
                                    m = [[Model alloc]initHref:href title:element.stringValue];
                                }
                                
                                [mainArray addObject:m];
                            }
                            
                            
                        }
                        
                        
                        
                        
                    }
                    
                    
                    
                }
            }
            
        }
    }
    
    
    [Service insertArray:mainArray];
    
    return mainArray;
    
}

+ (id)fengshuSub:(Model *)aModel Block:(void (^)(NSArray *array, NSError *error))block
{
    [SVProgressHUD show];
    return [[Service fengshuClient] GET:[Service encodingBKStr:aModel.parentHref]
                             parameters:nil
                                success:^(NSURLSessionDataTask *task, id responseObject) {
                                    
                                    block([self parseFengshuSubList:responseObject],nil);
                                    
                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    
                                    [SVProgressHUD showErrorWithStatus:@"数据错误,请稍后再试"];
                                    
                                }];
    
}
+ (NSArray *)parseFengshuSubList:(id)response {
    
    NSMutableArray * mainArray = [NSMutableArray array];
    
    @autoreleasepool {
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithHTMLData:response
                                                                  encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
                                                                     error:NULL];
        if (doc) {
            
            NSArray * trArray = [doc nodesForXPath:@"//table" error:NULL];
            
            for (GDataXMLElement * item2 in trArray)
            {
                
                NSArray * tr = [item2 elementsForName:@"tr"];
                
                for (GDataXMLElement * item1 in tr) {
                    
                    NSArray * td = [item1 elementsForName:@"td"];
                    
                    for (GDataXMLElement * item3 in td) {
                        NSArray * a = [item3  elementsForName:@"a"];
                        
                        for (GDataXMLElement * element in a) {
                            
                            NSLog(@"%@:%@",element.stringValue,[[element attributeForName:@"href"] stringValue]);
                            
                            NSString * href = [[element attributeForName:@"href"] stringValue];
                            
                            Model * m = [[Model alloc]initHref:href title:element.stringValue];
                            
                            [mainArray addObject:m];
                            
                        }
                    }
                    
                }
                
                
                
            }
            
        }
    }
    
    
    //    [Service insertArray:mainArray];
    
    return mainArray;
    
}


+ (id)info:(Model *)aModel withBlock:(void (^)(id infoModel, NSError *error))block {
    
    return [[Service fengshuClient] GET:[Service encodingBKStr:aModel.href]
                             parameters:nil
                                success:^(NSURLSessionDataTask *task, id responseObject) {
                                    
                                    NSLog(@"成功 ---- %@ : %@", aModel.title,aModel.href);
                                    
                                    block([self parseInfoModel:aModel withData:responseObject],nil);
                                    
                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"数据错误,请稍后再试"];
                                    
                                    NSLog(@"失败 ---- %@ : %@", aModel.title,aModel.href);
                                }];
    
}

+ (Model *)parseInfoModel:(Model *)aModel withData:(id)response {
    
    aModel.info = @"";
    
    
    NSMutableArray * mainArray = [NSMutableArray array];
    
    @autoreleasepool {
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithHTMLData:response
                                                                  encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
                                                                     error:NULL];
        if (doc) {
            //            
            //            <div id="main">
            //div[@class='cdiv']
            
            
            NSArray * trArray = [doc nodesForXPath:@"//table" error:NULL];
            
            for (GDataXMLElement * item2 in trArray)
            {
                
                NSArray * tr = [item2 elementsForName:@"tr"];
                
                for (GDataXMLElement * item1 in tr) {
                    
                    NSArray * td = [item1 elementsForName:@"td"];
                    
                    NSString * anTitle = @"";
                    
                    if (td.count == 2) {
                        anTitle = [item1.stringValue stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                        anTitle = [anTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        anTitle = [anTitle stringByReplacingOccurrencesOfString:@"查看谜底" withString:@""];
                    }
                    
                    
                    
                    for (GDataXMLElement * item3 in td) {
                        NSArray * a = [item3  elementsForName:@"a"];
                        
                        for (GDataXMLElement * element in a) {
                            
                            NSLog(@"%@:%@",element.stringValue,[[element attributeForName:@"href"] stringValue]);
                            
                            NSString * href = [[element attributeForName:@"href"] stringValue];
                            
                            //                            Model * m = [[Model alloc]initHref:href title:element.stringValue];
                            Model *m = [[Model alloc]initHref:href
                                                        title:anTitle
                                                       parent:aModel.title
                                                   parentHref:aModel.href];
                            
                            [mainArray addObject:m];
                            
                        }
                    }
                    
                }
                
                
                
            }
            
            [Service insertArray:mainArray];
            
            //            NSArray * trArray = [doc nodesForXPath:@"//table" error:NULL];
            //            
            //            if (trArray.count>0) {
            //                int i = 0;
            //                for (GDataXMLElement * item2 in trArray)
            //                {
            //                    
            //                    if (i == 17) {
            //                        NSString * xmlString = [item2.stringValue stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"<td>" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"</td>" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@" " withString:@""];
            //                        
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&#13;\n" withString:@""];
            //                        
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
            //                        
            //                        xmlString = [xmlString stringByTrimmingCharactersInSet:
            //                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            //                        
            //                        aModel.info = [NSString stringWithFormat:@"%@\n%@",aModel.info,xmlString.length?xmlString:@""];
            //                        
            //                        break;
            //                    }
            //                    i++;
            //                }
            //                
            //                
            //                
            //            }else {
            //                
            //                trArray = [doc nodesForXPath:@"//p" error:NULL];
            //                
            //                for (GDataXMLElement * item2 in trArray)
            //                {
            //                    
            //                    NSArray * dr = [item2 elementsForName:@"br"];
            //                    
            //                    if (dr) {
            //                        
            //                        NSString * xmlString = [item2.XMLString stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"<td>" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"</td>" withString:@""];
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@" " withString:@""];
            //                        
            //                        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"&#13;\n" withString:@""];
            //                        
            //                        xmlString = [xmlString stringByTrimmingCharactersInSet:
            //                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            //                        
            //                        aModel.info = [NSString stringWithFormat:@"%@\n%@",aModel.info,xmlString.length?xmlString:@""];
            //                        
            //                    }
            //                }
            //            }
        }
    }
    
    return aModel;
}


#pragma mark - 数据库
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
        
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS fengshu (href TEXT PRIMARY KEY, title TEXT, info TEXT , parent TEXT , parenthref text)"];
    }
    
    return _db;
}
+ (void)insertArray:(NSArray *)aArray {
    
    FMDatabase * db = [Service db];
    
    [db beginTransaction];
    
    
    
    for (Model * m in aArray) {
        
        NSString *hrefStr = @"";
        NSString *parentHrefStr = @"";
        
        NSRange range = [m.href rangeOfString:@"&page"];//匹配得到的下标
        
        if (range.length > 0) {
            
            hrefStr = [m.href substringToIndex:range.location];
        }else {
            hrefStr = m.href;
        }
        
        NSRange range1 = [m.parentHref rangeOfString:@"&page"];//匹配得到的下标
        
        if (range1.length > 0) {
            
            parentHrefStr = [m.parentHref substringToIndex:range1.location];
        }else {
            parentHrefStr = m.parentHref;
        }
        
        
        [db executeUpdate:@"REPLACE INTO fengshu (href, title, info ,parent,parenthref) VALUES (?,?,?,?,?)",hrefStr,m.title,m.info,m.parent,parentHrefStr];
        
    }
    [db commit];
    [db close];
}

+ (NSArray *)readFengSu {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM fengshu where  title != '' and parenthref = ''   order by href desc  LIMIT 110,10"];
    
    while ([rs next]) {
        
        NSString * href = [rs stringForColumn:@"href"];
        
        NSString * title = [rs stringForColumn:@"title"];
        
        int count = 30;
        
        if ([title isEqualToString:@"成语"]) {
            count = 278;
        }
        else if ([title isEqualToString:@"人名"]) {
            count = 300;
        }
        else if ([title isEqualToString:@"诗词句"] || [title isEqualToString:@"古文句"]) {
            count = 111;
        }
        else if ([title isEqualToString:@"电影名"]) {
            count = 117;
        }
        else if ([title isEqualToString:@"商品名"] || [title isEqualToString:@"称谓职务"]) {
            count = 45;
        }
        else if ([title isEqualToString:@"常言俗语"]) {
            count = 120;
        }
        else if ([title isEqualToString:@"中国地名"]) {
            count = 80;
        }
        else if ([title isEqualToString:@"中药名"]) {
            count = 40;
        }
        else {
            count = 30;
        }
        
        for (int index = 0; index < count; index ++) {
            
            if ([href rangeOfString:@"page"].location == NSNotFound) {
                [array addObject:[[Model alloc]initHref:[NSString stringWithFormat:@"%@&page=%d",href,index]
                                                  title:title
                                                 parent:[rs stringForColumn:@"parent"]
                                             parentHref:[rs stringForColumn:@"parenthref"]]];
            }
        }
        
    }
    
    if (array.count == 0) {
        return array;
    }
    
    
    [db open];
    
    int j = 0;
    
    for (int i=j; i< array.count; i++) {
        
        Model * m = array[i];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Service info:m withBlock:^(Model * infoModel, NSError *error) {
                
                
                NSString *hrefStr = @"";
                NSString *parentHrefStr = @"";
                
                NSRange range = [infoModel.href rangeOfString:@"&page"];//匹配得到的下标
                
                if (range.length > 0) {
                    
                    hrefStr = [infoModel.href substringToIndex:range.location];
                }else {
                    hrefStr = infoModel.href;
                }
                
                NSRange range1 = [infoModel.parentHref rangeOfString:@"&page"];//匹配得到的下标
                
                if (range1.length > 0) {
                    
                    parentHrefStr = [infoModel.parentHref substringToIndex:range1.location];
                }else {
                    parentHrefStr = infoModel.parentHref;
                }
                
                
                [db executeUpdate:@"REPLACE INTO fengshu (href, title, info ,parent,parenthref) VALUES (?,?,?,?,?)",hrefStr,infoModel.title,infoModel.info,infoModel.parent,parentHrefStr];
                
                [SVProgressHUD showProgress:i/(1.0 * array.count)];
                
            }];
            
            
        });
        
        
    }
    
    return array;
}

+ (NSArray *)readFengSuSubCity {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM fengshu where parenthref == ''"];
    
    while ([rs next]) {
        
        [array addObject:[[Model alloc]initHref:[rs stringForColumn:@"href"]
                                          title:[rs stringForColumn:@"title"]
                                         parent:[rs stringForColumn:@"parent"]
                                     parentHref:[rs stringForColumn:@"parenthref"]]];
    }
    
    if (array.count == 0) {
        return array;
    }
    
    [db open];
    
    int j = 0;
    
    for (int i=j; i< array.count; i++) {
        
        Model * m = array[i];
        
        [Service fengshuSub:m Block:^(NSArray *array, NSError *error) {
            
            
            for (Model * temp in array) {
                
                NSString *hrefStr = @"";
                NSString *parentHrefStr = @"";
                
                NSRange range = [temp.href rangeOfString:@"&page"];//匹配得到的下标
                
                if (range.length > 0) {
                    
                    hrefStr = [temp.href substringToIndex:range.location];
                }else {
                    hrefStr = temp.href;
                }
                
                NSRange range1 = [temp.parentHref rangeOfString:@"&page"];//匹配得到的下标
                
                if (range1.length > 0) {
                    
                    parentHrefStr = [temp.parentHref substringToIndex:range1.location];
                }else {
                    parentHrefStr = temp.parentHref;
                }
                
                
                [db executeUpdate:@"REPLACE INTO fengshu (href, title, info ,parent,parenthref) VALUES (?,?,?,?,?)",hrefStr,temp.title,temp.info,m.parent,parentHrefStr];
                
            }
            
            
        }];
    }
    
    return array;
}


+ (NSArray <NSDictionary*> *)readAllData {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM fengshu"];
    
    while ([rs next]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        for (NSString *str in rs.columnNameToIndexMap) {
            [dic setObject:[rs stringForColumn:str]?[rs stringForColumn:str]:@"" forKey:str ];
        }
        //        [dic setObject:@"" forKey:kshoujia];
        [array addObject:dic];
        
        //        [array addObject:[[Model alloc]initHref:[rs stringForColumn:@"href"]
        //                                          title:[rs stringForColumn:@"title"]
        //                                         parent:[rs stringForColumn:@"parent"]
        //                                     parentHref:[rs stringForColumn:@"parenthref"]]];
    }
    
    return array;
    
    
}


@end
