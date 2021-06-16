//
//  FollowersViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface FollowersViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate> {
}
@property (strong, nonatomic) IBOutlet UITableView *followersTbleView;
@property (strong, nonatomic) NSString * followViewTypeString;
@property (weak, nonatomic) IBOutlet AsyncImageView *userimgview;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchABar;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;

- (IBAction)backBtnAction:(id)sender;

@end
