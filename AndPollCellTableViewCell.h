//
//  AndPollCellTableViewCell.h
//  POP
//
//  Created by KingTon on 9/2/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "PollViewController.h"

static NSString *ActivePollCellId = @"ActiveCell";
@interface ActivePollCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *gridListTypeStr;
@property (nonatomic, strong) NSString *layoutCountStr;
@end

@interface AndPollCellTableViewCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

{
    NSArray * dataArray;
    NSString * gridAndListString;
    
}
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (weak, nonatomic) IBOutlet UILabel *pollDescLable;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet ActivePollCollectionView *activePollCollectionView;
@property (weak, nonatomic) IBOutlet UIView *sepratorView;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UILabel *commentLbl;
@property (weak, nonatomic) IBOutlet UILabel *voteLbl;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (weak, nonatomic)IBOutlet UITextView *aboutPoll;
@property (weak,nonatomic) IBOutlet UILabel *dateShow;
@property (weak, nonatomic) IBOutlet UIImageView *IMageView;
@property (strong, nonatomic) IBOutlet PollViewController* viewController;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath imageArray:(NSArray *)imageArray layoutChangeStr:(NSString *)_cellayoutStr gridAndListType:(NSString *)type;

@end
