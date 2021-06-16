//
//  HomeCellTableViewCell.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface PollCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *gridListTypeStr;
@property (nonatomic, strong) NSString *layoutCountStr;
@property (nonatomic, strong) NSString *imageFullString;

@end
@interface HomeCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pollDescLable;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutPoll;
@property (weak, nonatomic) IBOutlet UILabel *dateShow;
@property (weak, nonatomic) IBOutlet UIImageView *IMageView;

@property (weak, nonatomic) IBOutlet PollCollectionView *pollCollectionView;
@property (weak, nonatomic) IBOutlet UIView *sepratorView;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *slideViewBtn;
@property (weak, nonatomic) IBOutlet UIButton *gridBtn;
@property (weak, nonatomic) IBOutlet UILabel *commentLbl;
@property (weak, nonatomic) IBOutlet UILabel *voteLbl;
@property (weak, nonatomic) IBOutlet UILabel *voteperLbl;
@property (weak, nonatomic) IBOutlet UIButton *NameBtn;
@property (weak, nonatomic) IBOutlet UILabel *bottomLbl;
@property (weak, nonatomic) IBOutlet UIView *lineView;



- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath layoutChangeStr:(NSString *)_cellayoutStr gridAndListType:(NSString *)type imageFull : (NSString *)imageFull ;

@end
