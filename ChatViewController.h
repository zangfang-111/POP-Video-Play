//
//  ChatViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSArray* messageArray;
    NSArray* actionArray;
    NSArray* senderImageArray;
    NSString *senderProfile_url;
    NSString *receiverProfile_url;
    NSArray *messageIdArray;
    NSString *senderName;
    NSString *receiverName;
    NSMutableArray *timeArray;
}

@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UITableView *chatDetailTbleView;
@property (strong, nonatomic) IBOutlet UITextField *messageTxtField;

- (IBAction)sendBtn_Tapped:(id)sender;
- (IBAction)backBtn_Tapped:(id)sender;
@end
