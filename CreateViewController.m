//
//  CreateViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "CreateViewController.h"
#import "AddPollViewController.h"
@interface CreateViewController () {
    UIView * overlayView;
    BOOL  pollShowBool;
}
@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)photoBtn:(id)sender {
    pollShowBool = YES;
    [self performSegueWithIdentifier:@"addPollViewID" sender:sender];
}
-(IBAction)videoBtn:(id)sender {
    pollShowBool = YES;
    [self performSegueWithIdentifier:@"addPollViewID" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIButton * btn = (UIButton *)sender;
    if([segue.identifier isEqualToString:@"addPollViewID"]) {
        AddPollViewController * addpoolView = [segue destinationViewController];
        if(btn.tag == 11){
            addpoolView.navTitleString= PHOTOPOLL;
        }
        else{
            addpoolView.navTitleString= VIDEOPOLL;
        }
    }
}

@end
