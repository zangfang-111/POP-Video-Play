//
//  LogInViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSTwitterEngine.h"

@interface LogInViewController : UIViewController<FHSTwitterEngineAccessTokenDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTxtFiled;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxtFiled;
@property (weak, nonatomic) IBOutlet UIButton *faceBookBtnAction;
@property (weak, nonatomic) IBOutlet UIButton *twitertBtnAction;
@property (weak, nonatomic) IBOutlet UIButton *loginBtnAction;
@property (weak, nonatomic) IBOutlet UIButton *CancelBtn;
- (IBAction)loginBtnAction:(id)sender;

@end
