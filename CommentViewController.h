//
//  CommentViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *commentTabelView;
@property (weak, nonatomic) IBOutlet UITextField *CommentFld;

- (IBAction)backBtnAction:(id)sender;
@end
