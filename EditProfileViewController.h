//
//  EditProfileViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import <MessageUI/MessageUI.h>
@interface EditProfileViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate,MFMailComposeViewControllerDelegate>{    
}
@property (strong, nonatomic) IBOutlet UIScrollView *bgScrollView;
@property (strong, nonatomic) IBOutlet UIButton *profilePicBtn;
@property (strong, nonatomic) IBOutlet UITextField *nameTxtField;
@property (strong, nonatomic) IBOutlet AsyncImageView *userImageView;
@property (strong, nonatomic) IBOutlet UIButton *EditImageBtn;
@property (strong, nonatomic) IBOutlet UIButton *SaveBtn;
@property (strong, nonatomic) IBOutlet UISwitch *swichbtn;
- (IBAction)profilePicBtnTapped:(id)sender;

@end
