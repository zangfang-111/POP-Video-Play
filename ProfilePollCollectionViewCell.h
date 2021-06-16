//
//  ProfilePollCollectionViewCell.h
//  POP
//
//  Created by salentro on 12/7/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *CollectionViewCellIdentifier = @"Cell";
@interface GridProfileCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;


@end
@interface ProfilePollCollectionViewCell : UICollectionViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSString * gridAndListString;

}
@property (nonatomic, strong) NSArray * dataArray;
@property (strong, nonatomic) IBOutlet GridProfileCollectionView *gridProfileCollectionVW;


- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath imageArray:(NSArray *)imageArray layoutChangeStr:(NSString *)_cellayoutStr;
@end
