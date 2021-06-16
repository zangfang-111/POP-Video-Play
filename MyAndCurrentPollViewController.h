//
//  MyAndCurrentPollViewController.h
//  POP
//
//  Created by salentro on 12/30/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AsyncImageView.h"
@interface MyAndCurrentPollViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,MFMailComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *pollsTableView;
@property (weak, nonatomic) IBOutlet UIButton *ActivePollBtn;
@property (weak, nonatomic) IBOutlet UIButton *pollBtn;
@property (weak, nonatomic) IBOutlet UIButton *followerBtn;
@property (weak, nonatomic) IBOutlet UIButton *followingBtn;
@property (weak, nonatomic) IBOutlet UIButton *FollowBtn;

@property (weak, nonatomic) IBOutlet UIButton *myPollBtn;
@property (weak, nonatomic) IBOutlet UIButton *currentPollBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (strong, nonatomic) NSString*pollTypeStr;

@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet AsyncImageView *userImgView;
@property (nonatomic, retain) UIDocumentInteractionController *documentController;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *followersLbl;
@property (weak, nonatomic) IBOutlet UILabel *followingsLbl;
@property (weak, nonatomic) IBOutlet UITextView *webLabel;
@property (weak, nonatomic) IBOutlet UIButton *setting;
@property (weak, nonatomic) IBOutlet UILabel *urlLbl;
@property (weak, nonatomic) IBOutlet UIButton *userImageButton;

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *userFullnameField;
@property (weak, nonatomic) IBOutlet UITextField *userShortNameField;
@property (weak, nonatomic) IBOutlet UITextField *userImageUrlField;
@property (weak, nonatomic) UITextField *activeTextField;
@property (assign, nonatomic) CGRect keyboardFrame;



- (IBAction)myPollBtnAction:(id)sender;
- (IBAction)currentPollBtnAction:(id)sender;
- (IBAction)backBtnAction:(id)sender;
- (IBAction)followingBtnAction:(id)sender;
- (IBAction)followerBtnAction:(id)sender;
- (IBAction)userImageButton:(id)sender;
- (void)refresh;
@end
