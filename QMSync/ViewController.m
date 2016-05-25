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
    
//    fengsuInfoBtn.enabled = YES;
    
    
    [Service fengshuBaseBlock:^(NSArray *array, NSError *error) {
       
        [Service readFengSuSubCity];
        
        fengsuInfoBtn.enabled = YES;

        [SVProgressHUD dismiss];
    }];

}

- (IBAction)touchFengsuInfo:(id)sender {
    
    
    [Service readFengSu];
//    [Service readFengSuSubCity];
    
    
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
