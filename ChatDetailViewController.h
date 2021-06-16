//
//  ChatDetailViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface ChatDetailViewController : UIViewController<UITextFieldDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *chatTableview;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchABar;

- (IBAction)backBtnAction:(id)sender;
@end
