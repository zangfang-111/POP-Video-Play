//
//  ProfilePollCollectionViewCell.m
//  POP
//
//  Created by salentro on 12/7/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import "ProfilePollCollectionViewCell.h"
#import "PollCollectionViewCell.h"
@implementation GridProfileCollectionView

@end
@implementation ProfilePollCollectionViewCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {

    }
    return self;
}
- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath imageArray:(NSArray *)imageArray layoutChangeStr:(NSString *)_cellayoutStr{
    

    _gridProfileCollectionVW.delegate = self;
    _gridProfileCollectionVW.dataSource = self;
    _gridProfileCollectionVW.indexPath = indexPath;
    _dataArray = [NSArray arrayWithArray:imageArray];
    gridAndListString = _cellayoutStr;
    [_gridProfileCollectionVW reloadData];
    
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [_gridProfileCollectionVW setCollectionViewLayout:layout];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionViewArray = [_dataArray[_gridProfileCollectionVW.indexPath.row]valueForKey:@"Images"] ;
    
    return collectionViewArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
       UIImageView * imgeView = [[UIImageView alloc]initWithFrame:self.contentView.frame];
    [cell.contentView addSubview:imgeView];

    NSArray *collectionViewArray = [_dataArray[_gridProfileCollectionVW.indexPath.row]valueForKey:@"Images"] ;
    if (collectionViewArray.count == 1) {
        cell.contentView.frame= CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height );

        imgeView.frame= CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height );

    }
    else if (collectionViewArray.count == 2) {
        cell.contentView.frame= CGRectMake(0, 0, self.contentView.frame.size.width / 2 , self.contentView.frame.size.height );

        imgeView.frame= CGRectMake(0, 0, self.contentView.frame.size.width / 2 , self.contentView.frame.size.height );
    }
    else if (collectionViewArray.count == 3) {
        
        cell.contentView.frame= CGRectMake(0, 0, self.contentView.frame.size.width / 3 , self.contentView.frame.size.height);
        imgeView.frame= CGRectMake(0, 0, self.contentView.frame.size.width / 3 , self.contentView.frame.size.height);
        
    }
    else  {
        
        cell.contentView.frame= CGRectMake(0, 0,self.contentView.frame.size.width / 2, self.contentView.frame.size.height / 2);
        imgeView.frame= CGRectMake(0, 0,self.contentView.frame.size.width / 2, self.contentView.frame.size.height / 2);
            }
    
    
    imgeView.image = [UIImage imageNamed:collectionViewArray[indexPath.item]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([gridAndListString isEqualToString:@"1"]) {
       return CGSizeMake(self.contentView.frame.size.width , self.contentView.frame.size.height  );  //1
        
    }
    else if ([gridAndListString isEqualToString:@"2"]) {
       return CGSizeMake(self.contentView.frame.size.width / 2 , self.contentView.frame.size.height );//2
        
    }
    else if([gridAndListString isEqualToString:@"3"]) {
        
        return  CGSizeMake(self.contentView.frame.size.width/3 , self.contentView.frame.size.height);//3
        
    }
    else if([gridAndListString isEqualToString:@"4"]) {
        return  CGSizeMake(self.contentView.frame.size.width / 2  , self.contentView.frame.size.height / 2);//4
    }
    else
    {
       return CGSizeMake(self.contentView.frame.size.width  , self.contentView.frame.size.height );
    }

   // return   CGSizeMake(self.contentView.frame.size.width  , self.contentView.frame.size.height );
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
