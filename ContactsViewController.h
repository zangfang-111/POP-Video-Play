//
//  ContactsViewController.h
//  POP
//
//  Created by KingTon on 9/20/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchABar;
- (IBAction)cancelBtn:(id)sender;
@end
