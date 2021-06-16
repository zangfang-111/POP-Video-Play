//
//  AppEntryViewViewController.m
//  POP
//
//  Created by KingTon on 10/20/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "AppEntryViewViewController.h"
#import "AsyncImageView.h"
@interface AppEntryViewViewController ()

@end

@implementation AppEntryViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
-(IBAction)login:(id)sender
{
}
-(IBAction)signup:(id)sender
{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
