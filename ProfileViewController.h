//
//  ProfileViewController.h
//  POP
//
//  Created by salentro on 11/11/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import <MessageUI/MessageUI.h>

@interface ProfileViewController : UIViewController<
UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,UITextFieldDelegate,MFMailComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *winnerTableView;
@property (weak, nonatomic) IBOutlet UIButton *gridBtn;
@property (weak, nonatomic) IBOutlet UIButton *listBtn;
@property (weak, nonatomic) IBOutlet UIButton *FollowBtn;
@property (weak, nonatomic) IBOutlet UIButton *ChatBtn;
@property (weak, nonatomic) IBOutlet UIButton *pollBtn;
@property (weak, nonatomic) IBOutlet UIButton *followerBtn;
@property (weak, nonatomic) IBOutlet UIButton *followingBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIView *winnerPoolView;
@property (weak, nonatomic) IBOutlet UIScrollView *profileScrollView;
@property (weak, nonatomic) IBOutlet UILabel *UserNameLbl;
@property (weak, nonatomic) IBOutlet AsyncImageView *UserImgView;
@property (weak, nonatomic) IBOutlet AsyncImageView *UserBagImgView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UITextView *webLabel;
@property (weak, nonatomic) IBOutlet UIView *HeaderView;

@property (weak, nonatomic) IBOutlet UILabel *pollLbl;
@property (weak, nonatomic) IBOutlet UILabel *followersLbl;
@property (weak, nonatomic) IBOutlet UILabel *followingsLbl;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet AsyncImageView *userImgView;
@property (nonatomic, retain) UIDocumentInteractionController *documentController;

- (IBAction)editBtnTapped:(id)sender;
- (IBAction)followingBtnAction:(id)sender;
- (IBAction)followerBtnAction:(id)sender;
- (IBAction)gridBtnAction:(id)sender;
- (IBAction)listBtnAction:(id)sender;

@end
