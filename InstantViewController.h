//
//  InstantViewController.h
//  POP
//
//  Created by salentro on 12/20/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstantViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *instantTableView;


- (IBAction)backBtnAction:(id)sender;

@end
