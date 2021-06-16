//
//  ProfileSettingViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileSettingViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UIButton *imageBtn;
@property(strong,nonatomic)IBOutlet UITextField *UserNameFld;


@end
