//
//  SignUpViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTxtFiled;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxtFiled;
@property (weak, nonatomic) IBOutlet UIButton *CancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *faceBookBtnAction;
@property (weak, nonatomic) IBOutlet UIButton *twitertBtnAction;


-(IBAction)login:(id)sender;
@end
