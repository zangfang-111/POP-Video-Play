//
//  termsViewController.m
//  POP
//
//  Created by KingTon on 9/3/17.
//  Copyright © 2017 salentro. All rights reserved.
//


#import "termsViewController.h"

@interface termsViewController ()

@end

@implementation termsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textView scrollRangeToVisible:NSMakeRange(0, 0)];
    [_textView setFont:[UIFont fontWithName:@"Arial" size:15.0]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
