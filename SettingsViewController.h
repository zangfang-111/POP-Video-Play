//
//  SettingsViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BranchInviteViewController.h"
#import "BranchInviteTextContactProvider.h"
#import "BranchInviteEmailContactProvider.h"
#import "BranchActivityItemProvider.h"
#import "BranchSharing.h"
#import "UIViewController+BranchShare.h"
#import "BranchReferralController.h"

@interface SettingsViewController : UIViewController<MFMailComposeViewControllerDelegate, BranchViewControllerDelegate> {
}
@property (weak, nonatomic) IBOutlet UITableView *table_view;
@property (strong, nonatomic) IBOutlet UISwitch *swichbtn;
@property (strong, nonatomic) IBOutlet UISwitch *swichbtn1;
@property (strong, nonatomic) IBOutlet UISwitch *swichbtn2;

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *userFullnameField;
@property (weak, nonatomic) IBOutlet UITextField *userShortNameField;
@property (weak, nonatomic) IBOutlet UITextField *userImageUrlField;
@property (weak, nonatomic) UITextField *activeTextField;
@property (assign, nonatomic) CGRect keyboardFrame;
@end
