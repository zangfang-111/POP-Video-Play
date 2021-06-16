//
//  MyPollCellTableViewCell.h
//  POP
//
//  Created by salentro on 12/30/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "MyAndCurrentPollViewController.h"
static NSString *ActivePollCellId = @"ActiveCell";
@interface ActivePollCollectionView : UICollectionView


@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *gridListTypeStr;
@property (nonatomic, strong) NSString *layoutCountStr;
@end

@interface MyPollCellTableViewCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

{
    NSArray * dataArray;
    NSString * gridAndListString;
    
}
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;
@property (weak, nonatomic) IBOutlet AsyncImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pollDescLable;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet ActivePollCollectionView *activePollCollectionView;
@property (weak, nonatomic) IBOutlet UIView *sepratorView;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *slideViewBtn;
@property (weak, nonatomic) IBOutlet UIButton *gridBtn;
@property (weak, nonatomic) IBOutlet UIButton *NameBtn;
@property (weak, nonatomic) IBOutlet UIButton *votePercentageBtn;
@property (weak, nonatomic) IBOutlet UIButton *dislikeBtn;
@property (weak, nonatomic) IBOutlet UILabel *commentLbl;
@property (weak, nonatomic) IBOutlet UILabel *voteLbl;
@property (weak, nonatomic) IBOutlet UIImageView *IMageView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLbl;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (weak, nonatomic)IBOutlet UITextView *aboutPoll;
@property (weak,nonatomic) IBOutlet UILabel *dateShow;
@property (strong, nonatomic) IBOutlet MyAndCurrentPollViewController* viewController;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath imageArray:(NSArray *)imageArray layoutChangeStr:(NSString *)_cellayoutStr gridAndListType:(NSString *)type;@end
