//
//  CreateViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
- (IBAction)photoBtn:(id)sender;
- (IBAction)videoBtn:(id)sender;
@end
