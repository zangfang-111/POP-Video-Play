//
//  InstantTableViewCell.m
//  POP
//
//  Created by salentro on 12/20/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import "InstantTableViewCell.h"
@implementation instantCollectionView

@end
@implementation InstantTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)screenShotBtn:(id)sender {
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath layoutChangeStr:(NSString *)_cellayoutStr gridAndListType:(NSString *)type
{
    self.instantCollectionView.dataSource = dataSourceDelegate;
    self.instantCollectionView.delegate = dataSourceDelegate;
    //  [self.pollCollectionView setContentOffset:self.pollCollectionView.contentOffset animated:NO];
    self.instantCollectionView.tag = indexPath.row;
    self.instantCollectionView.indexPath = indexPath;
    self.instantCollectionView.gridListTypeStr = type;
    [self.instantCollectionView reloadData];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.instantCollectionView setCollectionViewLayout:layout];
    
}

@end
