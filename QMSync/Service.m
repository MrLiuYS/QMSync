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
        _sharedClient = [[Service alloc] initWithBaseURL:[NSURL URLWithString:@"http://minghua.supfree.net/"]];
        
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sharedClient.operationQueue.maxConcurrentOperationCount = 1;
    });
    
    return _sharedClient;
}

+ (id)fengshuBaseBlock:(void (^)(NSArray *array, NSError *error))block
{
    [SVProgressHUD show];
    return [[Service fengshuClient] GET:@"chai.asp?id=1"
                             parameters:nil
                                success:^(NSURLSessionDataTask *task, id responseObject) {
                                    
                                    block([self parseFengshuList:responseObject],nil);
                                    
                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    
                                    [SVProgressHUD showErrorWithStatus:@"数据错误,请稍后再试"];
                                    
                                }];
    
}

+ (id)fengshuBasePage:(int)aPage
                Block:(void (^)(NSArray *array, NSError *error))block
{
    //    [SVProgressHUD show];
    return [[Service fengshuClient] GET:[NSString stringWithFormat:@"dao.asp?id=%d",aPage]
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
            
            NSString * href = @"";
            NSString * author = @"";
            NSString * title = @"";
            NSString * explain = @"";//画 说明
            NSString * related = @"";
            NSString * tag = @"";   //标签
            
            NSArray * text_danger = [doc nodesForXPath:@"//p[@class='text-danger']" error:NULL];
            
            for (GDataXMLElement * item in text_danger)
            {
                tag = item.stringValue;
                break;
            }
            
            NSArray * p = [doc nodesForXPath:@"//p" error:NULL];
            
            if (p.count > 0) {
                GDataXMLElement * item = [p lastObject];
                
                explain = [item.stringValue stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                explain = [explain stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                explain = [explain stringByReplacingOccurrencesOfString:@"　" withString:@""];
                
            }
            
            NSArray * text_center = [doc nodesForXPath:@"//p[@class='text-center']" error:NULL];
            
            for (GDataXMLElement * item in text_center)
            {
                
                NSArray * a = [item  elementsForName:@"a"];
                
                for (GDataXMLElement * element in a) {
                    //                    NSLog(@"%@:%@",element.stringValue,[[element attributeForName:@"href"] stringValue]);
                    
                    if ([element attributeForName:@"href"]) {
                        
                        href = [[element attributeForName:@"href"] stringValue];
                        
                    }
                    
                }
            }
            
            NSArray * text_success = [doc nodesForXPath:@"//h4[@class='text-success']" error:NULL];
            
            for (GDataXMLElement * item in text_success)
            {
                NSArray * small = [item  elementsForName:@"small"];
                
                if (small.count > 0) {
                    
                    for (GDataXMLElement * element in small) {
                        //                        NSLog(@"%@:%@",element.stringValue,[[element attributeForName:@"small"] stringValue]);
                        
                        author = element.stringValue;
                        
                    }
                    
                    NSArray * strong = [item  elementsForName:@"strong"];
                    
                    for (GDataXMLElement * element in strong) {
                        //                        NSLog(@"%@:%@",element.stringValue,[[element attributeForName:@"strong"] stringValue]);
                        
                        title = element.stringValue;
                        
                    }
                }
                
            }
            
            
            NSArray * oul_tul = [doc nodesForXPath:@"//ul[@class='oul tul']" error:NULL];
            
            for (GDataXMLElement * item in oul_tul)
            {
                
                NSArray * li = [item  elementsForName:@"li"];
                
                NSMutableArray * array = [NSMutableArray array];
                
                for (GDataXMLElement * element in li) {
                    
                    NSString *pRelated = @"";   //收土豆
                    
                    NSArray * a = [element  elementsForName:@"a"];
                    
                    for (GDataXMLElement * element_a in a) {
                        
                        //                        NSLog(@"%@:%@",element_a.stringValue,[[element_a attributeForName:@"href"] stringValue]);
                        
                        if ([element_a attributeForName:@"href"]) {
                            
                            pRelated = [NSString stringWithFormat:@"%@|-|%@|-|thumbnail/%@",element_a.stringValue,
                                        [[element_a attributeForName:@"href"] stringValue],
                                        [[element_a attributeForName:@"href"] stringValue]];
                            
                        }
                    }
                    
                    [array addObject:pRelated];
                    
                }
                
                related = [array componentsJoinedByString:@"$-$"];
            }
            
            Model * model = [[Model alloc]init];
            
            model.title = title;
            model.author = author;
            model.href = href;
            model.explain = explain;
            model.related = related;
            model.tag = tag;
            
            [mainArray addObject:model];
            
            NSLog(@"%@",model.href);
            
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
            
            NSArray * trArray = [doc nodesForXPath:@"//table" error:NULL];
            
            NSString * explainStr = @"";
            
            for (GDataXMLElement * item2 in trArray)
            {
                explainStr = @"";
                NSArray * tr = [item2 elementsForName:@"tr"];
                
                for (GDataXMLElement * item1 in tr) {
                    
                    NSArray * td = [item1 elementsForName:@"td"];
                    
                    NSString * anTitle = @"";
                    
                    if (td.count == 2) {
                        anTitle = [item1.stringValue stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                        anTitle = [anTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        anTitle = [anTitle stringByReplacingOccurrencesOfString:@"查看谜底" withString:@""];
                    }
                    
                    if ([anTitle hasPrefix:@"提示"]) {
                        explainStr = anTitle;
                    }
                    
                    if ([anTitle hasPrefix:@"谜底"]) {
                        
                        aModel.info = [NSString stringWithFormat:@"%@&-&-&%@",explainStr,anTitle];
                        
                        Model *m = [[Model alloc]initHref:aModel.href
                                                    title:aModel.title
                                                     info:aModel.info
                                                   parent:aModel.parent
                                               parentHref:aModel.parentHref];
                        
                        [mainArray addObject:m];
                        
                    }else {
                        
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
        
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS minghua (href TEXT PRIMARY KEY, title TEXT , related text , tag text , explain text , author text)"];
    }
    
    return _db;
}
+ (void)insertArray:(NSArray *)aArray {
    
    FMDatabase * db = [Service db];
    
    [db beginTransaction];
    
    for (Model * m in aArray) {
        
        [db executeUpdate:@"REPLACE INTO minghua (href, title, explain ,tag,author, related) VALUES (?,?,?,?,?,?)",m.href,m.title,m.explain,m.tag,m.author,m.related];
        
    }
    [db commit];
    [db close];
}


+ (void)getAnswer {
    
    
    FMDatabase * db = [Service db];
    
    
    [db open];
    
    __block NSArray * dbArray = [Service readAllDataModel];
    
    for (int index = 0; index < 1000; index++) {
        
        if (dbArray.count <=index) {
            return;
        }
        
        Model * model = dbArray[index];
        
        if (model.parentHref.length > 0 && model.info.length == 0) {
            
            
            //            dispatch_async(dispatch_get_main_queue(), ^{
            
            [Service info:model withBlock:^(Model * infoModel, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showProgress:index/(1.0 * dbArray.count)
                                         status:[NSString stringWithFormat:@"%f",index/(1.0 * dbArray.count)]];
                    
                });
                
            }];
            
            
            //            });
            
        }
        
    }
    
    
    
    
}

+ (NSArray *)readFengSu {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM minghua where  title != '' and parenthref = ''   order by href desc  LIMIT 95 , 5"];
    
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
                
                
                [db executeUpdate:@"REPLACE INTO minghua (href, title, info ,parent,parenthref) VALUES (?,?,?,?,?)",hrefStr,infoModel.title,infoModel.info,infoModel.parent,parentHrefStr];
                
                //                [SVProgressHUD showProgress:i/(1.0 * array.count)];
                [SVProgressHUD showProgress:i/(1.0 * array.count)
                                     status:[NSString stringWithFormat:@"%f",i/(1.0 * array.count)]];
                
            }];
            
            
        });
        
        
    }
    
    return array;
}


+ (NSArray *)readFengSuSubCity {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM minghua where parenthref == ''"];
    
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
                
                
                [db executeUpdate:@"REPLACE INTO minghua (href, title, info ,parent,parenthref) VALUES (?,?,?,?,?)",hrefStr,temp.title,temp.info,m.parent,parentHrefStr];
                
            }
            
            
        }];
    }
    
    return array;
}


+ (NSArray <NSDictionary*> *)readAllData {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM minghua limit 0 , 500"];
    
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

+ (NSArray <NSDictionary*> *)readAllDataPage:(int)aPage {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM minghua order by href limit %d , 50",aPage*50]];
    
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



+ (NSArray <Model*> *)readAllDataModel {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [Service db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM minghua"];
    
    while ([rs next]) {
        
        //        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        //        for (NSString *str in rs.columnNameToIndexMap) {
        //            [dic setObject:[rs stringForColumn:str]?[rs stringForColumn:str]:@"" forKey:str ];
        //        }
        //        //        [dic setObject:@"" forKey:kshoujia];
        //        [array addObject:dic];
        
        [array addObject:[[Model alloc]initHref:[rs stringForColumn:@"href"]
                                          title:[rs stringForColumn:@"title"]
                                         parent:[rs stringForColumn:@"parent"]
                                     parentHref:[rs stringForColumn:@"parenthref"]]];
    }
    
    return array;
    
    
}


@end
