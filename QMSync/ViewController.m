//
//  ViewController.m
//  QMSync
//
//  Created by Lin on 15/7/1.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "ViewController.h"

#import "Service.h"
#import <UIImageView+WebCache.h>

#import <CommonCrypto/CommonDigest.h>

@interface ViewController () {
    
    
    __weak IBOutlet UIButton *fengsuInfoBtn;
    
    int intPage;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    intPage = 765;
    
    fengsuInfoBtn.enabled = YES;
    
    
    //    for (int index = 1; index < 700; index ++) {
    //        [Service fengshuBasePage:index
    //                           Block:^(NSArray *array, NSError *error) {
    //                               
    //                           }];
    //    }
    
    
    //    [Service fengshuBaseBlock:^(NSArray *array, NSError *error) {
    //        
    //        //        [Service readFengSuSubCity];
    //        
    //        fengsuInfoBtn.enabled = YES;
    //        
    //        [SVProgressHUD dismiss];
    //    }];
    //    
    
    
    
}


- (IBAction)touchFengsuInfo:(id)sender {
    
    
    [Service readFengSu];
    //    [Service readFengSuSubCity];
    
    
    
    
}

- (IBAction)touchAnswer:(id)sender {
    
    [Service getAnswer];
    
    [self performSelector:@selector(touchAnswer:) withObject:nil afterDelay:60*1];
}



- (IBAction)touchSync:(id)sender {
    
    NSLog(@"page:%d",intPage);
    
    NSArray * dbArray = [Service readAllDataPage:intPage];
    
    if (dbArray.count == 0) {
        
        intPage = 0;
        
        [self touchSync:nil];
        
        return;
    }
    
    __block int secion = 0;
    
    for (int index = 0 ; index < dbArray.count ; index++) {
        
        NSDictionary * dic = dbArray[index];
        
        
        BmobQuery   *bquery = [BmobQuery queryWithClassName:@"art"];
        
        [bquery whereKey:@"href" equalTo:dic[@"href"]];
        
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            
            
            if (array.count == 0) {
                
                BmobObject  *cargo = [BmobObject objectWithClassName:@"art"];
                
                [cargo saveAllWithDictionary:dic];
                
                {
                    BmobFile *thumFile = [[BmobFile alloc] initWithFilePath:[ViewController filePathHref:[NSString stringWithFormat:@"%@&thumbnail",dic[@"href"]]]];
                    
                    [thumFile saveInBackground:^(BOOL isSuccessful, NSError *error) {
                        //如果文件保存成功，则把文件添加到filetype列
                        if (isSuccessful) {
                            
                            NSLog(@"小图片提交成功");
                            
                            [cargo setObject:thumFile.url  forKey:@"thumbnail"];
                            
                            
                            BmobFile *imageFile = [[BmobFile alloc] initWithFilePath:[ViewController filePathHref:dic[@"href"]]];
                            
                            [imageFile saveInBackground:^(BOOL isSuccessful, NSError *error) {
                                //如果文件保存成功，则把文件添加到filetype列
                                if (isSuccessful) {
                                    
                                    NSLog(@"原图提交成功");
                                    
                                    
                                    
                                    [cargo setObject:imageFile.url  forKey:@"imageUrl"];
                                    
                                    //                            [cargo saveInBackground];
                                    
                                    [cargo saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                                        
                                        if (isSuccessful) {
                                            
                                            NSLog(@"成功");
                                            
                                            secion ++;
                                            
                                            if (secion >= dbArray.count) {
                                                
                                                [self touchSync:nil];
                                            }
                                        }else {
                                            NSLog(@"失败:%@",error);
                                            
                                            intPage ++;
                                            [self touchSync:nil];
                                        }
                                        
                                    }];
                                    
                                    
                                    
                                }else{
                                    //进行处理
                                    
                                    intPage ++;
                                    [self touchSync:nil];
                                }
                            }];
                            
                            
                        }else{
                            //进行处理
                            
                            intPage ++;
                            [self touchSync:nil];
                        }
                    }];
                }
                
                
            }else {
                
                
                intPage ++;
                
                [self touchSync:nil];
            }
            
            
        }];
        
        
        
        
        
        
        
        //        [cargo saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        //            if (isSuccessful) {
        //                NSLog(@"成功 :%@",cargo.objectId);
        //            }else{
        //                if (error) {
        //                    NSLog(@"失败:%@",error);
        //                    
        //                }
        //            }
        //        secion ++;
        //        
        //        if (secion >= dbArray.count) {
        //            
        //            [self touchSync:nil];
        //        }
        //
        //        }];
        
    }
    
    
    //    [self performSelector:@selector(touchSync:) withObject:nil afterDelay:60*2];
}


- (IBAction)touchImages:(id)sender {
    
    
    [SVProgressHUD showProgress:0 status:0];
    
    NSArray * array = [Service readAllDataModel];
    
    __block int secion = 1;
    
    
    
    for (Model * model in array) {
        
        UIImageView  * imageView = [[UIImageView alloc]init];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.href]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                
                                if (image) {
                                    
                                    
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        NSData * imageData = UIImageJPEGRepresentation(image,1);
                                        
                                        [ViewController saveMedia:imageData
                                                         withName:[ViewController md5:model.href]
                                                          Replace:YES];
                                        
                                        UIImage * thnImage = [self compressImage:image
                                                                   toTargetWidth:200];
                                        
                                        
                                        [ViewController saveMedia:UIImageJPEGRepresentation(thnImage,1)
                                                         withName:[ViewController md5:[NSString stringWithFormat:@"%@&thumbnail",model.href]]
                                                          Replace:YES];
                                        
                                        
                                        [SVProgressHUD showProgress:1.0 * secion / array.count
                                                             status:[NSString stringWithFormat:@"%d",secion]];
                                        
                                        secion++;
                                        
                                    });
                                    
                                    
                                }
                                
                            }];
        
        
    }
    
    
    
    
}

- (UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)targetWidth {
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mark - 本地路径
+ (NSString *)pathString {
    
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    //    DLog(@"%@",docsdir);
    
    return docsdir;
    
}

+ (NSString *)filePathHref:(NSString *)aHref {
    
    NSString *mediaPath = [NSString stringWithFormat:@"%@/%@.jpg",[ViewController pathString],[ViewController md5:aHref]];
    
    return mediaPath;
    
}

#pragma mark - 保存多媒体数据到本地
+ (void)saveMedia:(NSData *)media withName:(NSString *)name Replace:(BOOL)isReplace{
    
    NSString *mediaPath = [NSString stringWithFormat:@"%@/%@.jpg",[ViewController pathString],name];
    
    NSFileManager *file_manager = [NSFileManager defaultManager];
    
    if ([file_manager fileExistsAtPath:mediaPath]) {
        
        if (isReplace) {
            
            [file_manager removeItemAtPath:mediaPath error:nil];
            
        }
        
    }
    
    [media writeToFile:mediaPath atomically:YES];
    
}

+ (NSString *) md5:(NSString *) str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
