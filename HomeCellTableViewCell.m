//
//  HomeCellTableViewCell.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "HomeCellTableViewCell.h"
@implementation PollCollectionView

@end
@implementation HomeCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   
}
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath layoutChangeStr:(NSString *)_cellayoutStr gridAndListType:(NSString *)type imageFull : (NSString *)imageFull {
    self.pollCollectionView.dataSource = dataSourceDelegate;
    self.pollCollectionView.delegate = dataSourceDelegate;
    self.pollCollectionView.tag = indexPath.row;
    self.pollCollectionView.indexPath = indexPath;
    self.pollCollectionView.gridListTypeStr = type;
    self.pollCollectionView.imageFullString = imageFull;
    
  
    self.pollCollectionView.layoutCountStr = _cellayoutStr;
    [self.pollCollectionView reloadData];

    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    

    if([type isEqualToString:LISTVIEW])
    {
        self.pollCollectionView.pagingEnabled = YES;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    else{
        self.pollCollectionView.pagingEnabled = NO;

        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    [self.pollCollectionView setCollectionViewLayout:layout];
    
}
@end
