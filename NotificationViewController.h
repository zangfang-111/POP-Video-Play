//
//  NotificationViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *notificationTableview;
- (IBAction)backBtnAction:(id)sender;
- (IBAction)deleted:(id)sender;
@end
