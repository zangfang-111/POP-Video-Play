//
//  InstantTableViewCell.h
//  POP
//
//  Created by salentro on 12/20/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface instantCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *gridListTypeStr;


@end
@interface InstantTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet instantCollectionView *instantCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *pollBtn;
@property (weak, nonatomic) IBOutlet UIButton *screenShotBtn;
@property (weak, nonatomic) IBOutlet UIImageView *gridView;
@property (weak, nonatomic) IBOutlet UIImageView *slideView;
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath layoutChangeStr:(NSString *)_cellayoutStr gridAndListType:(NSString *)type;
@end
