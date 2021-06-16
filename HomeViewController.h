//
//  HomeViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface HomeViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,MFMailComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedTableview;
@property (weak, nonatomic) IBOutlet UICollectionView *userImageCollectionView;
@property (weak, nonatomic) NSString *viewString;
@property (weak, nonatomic) NSDictionary *instantDic;
@property (weak, nonatomic) NSDictionary *FollowerDic;
@property (weak, nonatomic) NSDictionary *MyPollsDic;
@property (weak, nonatomic) NSString *followgFollowString;

@property (weak, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *bellBtn;
@property (weak, nonatomic) IBOutlet UIButton *clockBtn;
@property (nonatomic,assign)BOOL isAutoHeight;

@property(nonatomic, readonly, getter=status) BOOL status;
@property (nonatomic, retain) UIDocumentInteractionController *documentController;

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *userFullnameField;
@property (weak, nonatomic) IBOutlet UITextField *userShortNameField;
@property (weak, nonatomic) IBOutlet UITextField *userImageUrlField;
@property (weak, nonatomic) UITextField *activeTextField;
@property (assign, nonatomic) CGRect keyboardFrame;


@end
