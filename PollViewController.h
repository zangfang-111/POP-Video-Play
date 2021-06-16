//
//  PollViewController.h
//  POP
//
//  Created by KingTon on 9/2/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AsyncImageView.h"
@interface PollViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,MFMailComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *pollsTableView;
@property (strong, nonatomic) NSString*pollTypeStr;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet AsyncImageView *userImgView;
@property (nonatomic, retain) UIDocumentInteractionController *documentController;
@property (weak,nonatomic) IBOutlet UIButton *moreBtn;

@end
