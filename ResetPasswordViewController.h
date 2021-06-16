//
//  ResetPasswordViewController.h
//  POP
//
//  Created by KingTon on 9/4/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *descriptionlbl;
@property (weak, nonatomic) IBOutlet UIView *passwordview;
@property (weak, nonatomic) IBOutlet UITextField *oldpassword;
@property (weak, nonatomic) IBOutlet UITextField *newpassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmpassword;
@property (weak, nonatomic) IBOutlet UIButton * submit;

-(IBAction)submit:(id)sender;

@end
