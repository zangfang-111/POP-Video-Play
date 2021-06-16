//
//  PollCollectionViewCell.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface PollCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *pollImageView;
@property (weak, nonatomic) IBOutlet  UIView *pollbackImageView;
@property (weak, nonatomic) IBOutlet UIButton *votePercentageBtn;
@property (weak, nonatomic) IBOutlet UIButton *dislikeBtn;
@property (weak, nonatomic) IBOutlet UIView *likeUpView;
@property (weak, nonatomic) IBOutlet UIView *dislikeView;
@property (weak, nonatomic) IBOutlet UILabel *dislikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *dislikeImageView;
@property (weak, nonatomic) IBOutlet UILabel *likepercentageLabel;

@end
