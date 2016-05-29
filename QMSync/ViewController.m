//
//  ViewController.m
//  QMSync
//
//  Created by Lin on 15/7/1.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

#import "ViewController.h"

#import "Service.h"


@interface ViewController () {
    
    
    __weak IBOutlet UIButton *fengsuInfoBtn;
    
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    fengsuInfoBtn.enabled = YES;
    
    
    //    [Service fengshuBaseBlock:^(NSArray *array, NSError *error) {
    //        
    //        //        [Service readFengSuSubCity];
    //        
    //        fengsuInfoBtn.enabled = YES;
    //        
    //        [SVProgressHUD dismiss];
    //    }];
    
    
    
    
}


- (IBAction)touchFengsuInfo:(id)sender {
    
    
    [Service readFengSu];
    //    [Service readFengSuSubCity];
    
    
    
    
}

- (IBAction)touchAnswer:(id)sender {
    
    [Service getAnswer];
    
    [self performSelector:@selector(touchAnswer:) withObject:nil afterDelay:60*3];
}



- (IBAction)touchSync:(id)sender {
    
    __block NSArray * dbArray = [Service readAllData];
    
    
    NSLog(@"%f",ceil(dbArray.count/50));
    NSLog(@"%lu",MIN(50, dbArray.count % 50));
    
    
    dispatch_group_t group = dispatch_group_create();
    
    __block int subcount = 0;
    
    for (int section =0 ; section <= ceil(dbArray.count/50); section++) {
        
        
        dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
            
            BmobObjectsBatch    *batch = [[BmobObjectsBatch alloc] init] ;
            
            
            for (int row = 0; row < 50; row++) {
                
                if (dbArray.count <= section * 50 + row) {
                    continue;
                }
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dbArray[section * 50 + row]];
                
                [batch saveBmobObjectWithClassName:@"riddle" parameters:dic];
                
            }
            
            
            [batch batchObjectsInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                NSLog(@"batch error %@",[error description]);
                
                if (isSuccessful) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSLog(@"成功");
                        
                        [SVProgressHUD showProgress:1.0*subcount/dbArray.count
                                             status:[NSString stringWithFormat:@"%d",subcount]];
                        
                        //                        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%d",subcount]
                        //                                                    maskType:SVProgressHUDMaskTypeBlack];
                        
                    });
                    
                    subcount++;
                    
                }else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSLog(@"失败");
                        //                        [SVProgressHUD showSuccessWithStatus:@"失败"
                        //                                                    maskType:SVProgressHUDMaskTypeBlack];
                        
                    });
                    
                    
                    
                    
                    //                    failureHandler(error);
                }
                
            }];
            
        });
        
    }
    
    
    //    for (int index = 0 ; index < array.count ; index++) {
    //        
    //        NSDictionary * dic = array[index];
    //        
    //        BmobObject  *cargo = [BmobObject objectWithClassName:@"riddle"];
    //        
    //        [cargo saveAllWithDictionary:dic];
    //        
    //        [cargo saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
    //            if (isSuccessful) {
    //                NSLog(@"成功 :%@",cargo.objectId);
    //            }else{
    //                if (error) {
    //                    NSLog(@"失败:%@",error);
    //                }
    //            }
    //        }];
    //        
    //    }
    
    
    
    [self performSelector:@selector(touchSync:) withObject:nil afterDelay:60*10];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
