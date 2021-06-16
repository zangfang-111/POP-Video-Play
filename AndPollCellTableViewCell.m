//
//  MyPollCellTableViewCell.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "AndPollCellTableViewCell.h"
#import "PollCollectionViewCell.h"
#import "AFHTTPSessionManager.h"
#import "MyAndCurrentPollViewController.h"
#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIView.h>
#import "Utility.h"
@implementation AndPollCellTableViewCell

{
    UIScrollView * imageScrollView;
    NSString *SelectedPollIdStr,*selectedUserIdStr,*likeDislikeStr,*MediaIdStr;
    NSMutableArray *likeStatusArray;
    UIView * pollView; AVPlayer*  avPlayer ;  AVPlayerLayer*   avPlayerLayer;
    UIView*BagView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath imageArray:(NSArray *)imageArray layoutChangeStr:(NSString *)_cellayoutStr gridAndListType:(NSString *)type
{
    _activePollCollectionView.delegate = self;
    _activePollCollectionView.dataSource = self;
    _activePollCollectionView.indexPath = indexPath;
    _dataArray = [NSMutableArray arrayWithArray:imageArray];
    _activePollCollectionView.gridListTypeStr = type;
    _activePollCollectionView.layoutCountStr = _cellayoutStr;
    [_activePollCollectionView reloadData];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    if([type isEqualToString:LISTVIEW])
    {
        _activePollCollectionView.pagingEnabled = YES;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    else{
        _activePollCollectionView.pagingEnabled = NO;
        
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [_activePollCollectionView setCollectionViewLayout:layout];
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionViewArray = [_dataArray[_activePollCollectionView.indexPath.row]valueForKey:@"media_files"] ;
    if(collectionViewArray.count>0)
        return collectionViewArray.count;
    else
        return 0;
}
- (BOOL)isFirstPost:(NSArray*)mediaArray
{
    for(NSDictionary*media in mediaArray)
    {
        if(![((NSString*)[media valueForKey:@"like_dislike"]) isEqualToString:@""])
            return NO;
    }
    return YES;
}

- (BOOL)isTopPercentage:(NSArray*)mediaArray position:(int)idx
{
    float percentage = ((NSString*)[[mediaArray objectAtIndex:idx] valueForKey:@"media_likes_percentage"]).floatValue;
    
    for(NSDictionary*media in mediaArray)
    {
        float other = ((NSString*)[media valueForKey:@"media_likes_percentage"]).floatValue;
        
        if (other ==0 && percentage ==0)
            return NO;
        if(other > percentage)
            return NO;
    }
    
    return YES;
}


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PollCollectionViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSArray *collectionViewArray = [_dataArray[[(ActivePollCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"] ;
    
    Cell.votePercentageBtn.tag = indexPath.row;
    [Cell.votePercentageBtn addTarget:self action:@selector(voting_action:) forControlEvents:UIControlEventTouchUpInside];
    
    Cell.dislikeBtn.tag = indexPath.row;
    [Cell.dislikeBtn addTarget:self action:@selector(dislike_action:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (collectionViewArray.count == 1) {
        
        Cell.dislikeView.hidden = NO;
        Cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height);
        Cell.pollImageView.frame= CGRectMake(0, Cell.contentView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width, collectionView.frame.size.height - Cell.likeUpView.frame.size.height - 6);
        Cell.pollbackImageView.frame= CGRectMake(0, Cell.contentView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width, collectionView.frame.size.height - Cell.likeUpView.frame.size.height - 1);
        Cell.dislikeView.frame = CGRectMake(collectionView.frame.size.width/2-Cell.dislikeView.frame.size.width-2, Cell.contentView.frame.origin.y +2, Cell.dislikeView.frame.size.width, Cell.dislikeView.frame.size.height);
        Cell.likeUpView.frame = CGRectMake(collectionView.frame.size.width/2+2,Cell.contentView.frame.origin.y +2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
        Cell.pollbackImageView.backgroundColor = [UIColor clearColor];
        
    }
    else if (collectionViewArray.count == 2) {
        
        Cell.dislikeView.hidden = YES;
        Cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width/2 , collectionView.frame.size.height);
        Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2-  Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
        Cell.pollImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width / 2-1, collectionView.frame.size.height  - Cell.likeUpView.frame.size.height - 1);
        Cell.pollbackImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width / 2-1, collectionView.frame.size.height  - Cell.likeUpView.frame.size.height - 1);
        Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2-  Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
        Cell.pollbackImageView.backgroundColor = [UIColor clearColor];
        
    }
    else if (collectionViewArray.count == 3) {
        
        Cell.dislikeView.hidden = YES;
        Cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width  , collectionView.frame.size.height);
        Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2-  Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
        Cell.pollImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width / 3-1, collectionView.frame.size.height - Cell.likeUpView.frame.size.height);
        Cell.pollbackImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width / 3-1, collectionView.frame.size.height - Cell.likeUpView.frame.size.height);
        Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2-  Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
        Cell.pollbackImageView.backgroundColor = [UIColor clearColor];
        
    }
    else  {
        if (indexPath.row ==0 || indexPath.row ==1) {
            
            Cell.dislikeView.hidden = YES;
            Cell.contentView.frame= CGRectMake(0, 0,collectionView.frame.size.width /2, collectionView.frame.size.height /2);
            Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2-  Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
            Cell.pollImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2,collectionView.frame.size.width /2 -1, collectionView.frame.size.height /2 - Cell.likeUpView.frame.size.height - 1);
            Cell.pollbackImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2,collectionView.frame.size.width /2 -1, collectionView.frame.size.height /2 - Cell.likeUpView.frame.size.height - 1);
            Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2-  Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
            Cell.pollbackImageView.backgroundColor = [UIColor clearColor];
            
        }else if (indexPath.row == 2 || indexPath.row ==3){
            
            Cell.dislikeView.hidden = YES;
            Cell.contentView.frame= CGRectMake(0, 0,collectionView.frame.size.width /2, collectionView.frame.size.height /2);
            Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2- Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y + Cell.contentView.frame.size.height - Cell.likeUpView.frame.size.height, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
            Cell.pollImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y - collectionView.frame.size.height /2 + Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width /2 - 1, collectionView.frame.size.height /2 - Cell.likeUpView.frame.size.height - 1);
            Cell.pollbackImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y - collectionView.frame.size.height /2 + Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width /2 - 1, collectionView.frame.size.height /2 - Cell.likeUpView.frame.size.height - 1);
            Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2- Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y + Cell.contentView.frame.size.height - Cell.likeUpView.frame.size.height, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
            Cell.pollbackImageView.backgroundColor = [UIColor clearColor];
            
        }
        
    }
    
    if ([collectionViewArray count]==1) {
        
        NSString* likeStatus=[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"like_dislike"];
        
        if([likeStatus isEqualToString:@"1"])
        {
            Cell.likeImageView.image=[UIImage imageNamed:@"green_btn.png"];
            Cell.dislikeImageView.image=[UIImage imageNamed:@"pop_btn.png"];
            Cell.likepercentageLabel.textColor = [UIColor whiteColor];
            Cell.dislikeLabel.textColor = [UIColor blackColor];
            
            Cell.pollbackImageView.backgroundColor = [UIColor clearColor];
            
        }
        else if([likeStatus isEqualToString:@"0"])
        {
            Cell.likeImageView.image=[UIImage imageNamed:@"pop_btn.png"];
            Cell.dislikeImageView.image=[UIImage imageNamed:@"red_btn.png"];
            Cell.dislikeLabel.textColor = [UIColor whiteColor];
            Cell.likepercentageLabel.textColor = [UIColor blackColor];
            
            Cell.pollbackImageView.backgroundColor = [UIColor clearColor];
            
        }
        else
        {
            Cell.likeImageView.image=[UIImage imageNamed:@"pop_btn.png"];
            Cell.dislikeImageView.image=[UIImage imageNamed:@"pop_btn.png"];
            Cell.dislikeLabel.textColor = [UIColor blackColor];
            Cell.likepercentageLabel.textColor = [UIColor blackColor];
            
            Cell.pollbackImageView.backgroundColor = [UIColor clearColor];
            
        }
    }
    else {
        if([self isTopPercentage:collectionViewArray position:(int)indexPath.item])
        {
            Cell.likeImageView.image=[UIImage imageNamed:@"green_btn.png"] ;
            Cell.likepercentageLabel.textColor = [UIColor whiteColor];
            Cell.dislikeLabel.textColor = [UIColor blackColor];
        }
        else
        {
            Cell.likeImageView.image=[UIImage imageNamed:@"pop_btn.png"] ;
            Cell.dislikeLabel.textColor = [UIColor blackColor];
            Cell.likepercentageLabel.textColor = [UIColor blackColor];
            
            Cell.pollbackImageView.backgroundColor = [UIColor blackColor];
            Cell.pollbackImageView.alpha = 0.6;
        }

    }
    
    if (collectionViewArray.count==1) {
        Cell.likepercentageLabel.text=[NSString stringWithFormat:@"%@%@",[_dataArray [[(ActivePollCollectionView *)collectionView indexPath].row]valueForKey:@"likes_percentage"],@"%"];
        
        Cell.dislikeLabel.text=[NSString stringWithFormat:@"%@%@",[_dataArray [[(ActivePollCollectionView *)collectionView indexPath].row]valueForKey:@"dislikes_percentage"],@"%"];
        
    }
    else{
        Cell.likepercentageLabel.text=[NSString stringWithFormat:@"%@%@",[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"media_likes_percentage"],@"%"];
    }
    
    if ([[_dataArray[[(ActivePollCollectionView *)collectionView indexPath].row]valueForKey:@"media_type"] isEqualToString:@"Video"]) {
        [self scrollingFinish];
        NSURL *ratingUrl = [NSURL URLWithString:[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"video_thumbnail"]];
        [Cell.pollImageView setImageWithURLRequest:[NSURLRequest requestWithURL:ratingUrl] placeholderImage:[UIImage imageNamed:@"likeWhite.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
            [Cell.pollImageView setContentMode:UIViewContentModeScaleAspectFill];
            [Cell.pollImageView setClipsToBounds:YES];
            Cell.pollImageView.image = image;
        }failure:nil];
    }
    else
    {
        [self scrollingFinish];
        NSURL *ratingUrl = [NSURL URLWithString:[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"media_name"]];
        [Cell.pollImageView setImageWithURLRequest:[NSURLRequest requestWithURL:ratingUrl] placeholderImage:[UIImage imageNamed:@"likeWhite.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
            [Cell.pollImageView setContentMode:UIViewContentModeScaleAspectFill];
            [Cell.pollImageView setClipsToBounds:YES];
            Cell.pollImageView.image = image;
            
        }failure:nil];
    }
    
    [Cell.pollImageView setUserInteractionEnabled:YES];
    
    return Cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[(ActivePollCollectionView *)collectionView layoutCountStr]  isEqualToString:@"1"]) {
        return CGSizeMake(collectionView.frame.size.width , collectionView.frame.size.height  );
        
    }
    else if ([[(ActivePollCollectionView *)collectionView layoutCountStr]  isEqualToString:@"2"]) {
        return CGSizeMake(collectionView.frame.size.width / 2 , collectionView.frame.size.height );
        
    }
    else if([[(ActivePollCollectionView *)collectionView layoutCountStr]  isEqualToString:@"3"]) {
        
        return CGSizeMake(collectionView.frame.size.width/3, collectionView.frame.size.height);
    }
    else if([[(ActivePollCollectionView *)collectionView layoutCountStr]  isEqualToString:@"4"]) {
        return  CGSizeMake(collectionView.frame.size.width / 2  , collectionView.frame.size.height / 2);
    }
    else
    {
        return CGSizeMake(collectionView.frame.size.width  , collectionView.frame.size.height );
    }
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    if ([[(ActivePollCollectionView *)collectionView layoutCountStr] isEqualToString:@"2"]) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else{
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [avPlayer pause];
    [avPlayerLayer.player pause];
    [avPlayerLayer removeFromSuperlayer];
    
    avPlayerLayer = nil;
    avPlayer = nil;
    AVAsset*   avAsset = nil;
    [BagView removeFromSuperview];
    BagView = nil;
    
    if ([[_dataArray[[(ActivePollCollectionView *)collectionView indexPath].row]valueForKey:@"media_type"] isEqualToString:@"Video"]) {
        
        NSArray *collectionViewArray = [_dataArray[[(ActivePollCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"] ;
        avAsset = [AVAsset assetWithURL:[NSURL URLWithString:[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"media_name"]]];
        
        AVPlayerItem*avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
        avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
        avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:avPlayer];
        [avPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
        [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        [avPlayerLayer setFrame:CGRectMake(0, 0, collectionView.frame.size.width,  collectionView.frame.size.height)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(VideoDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        
        [BagView setUserInteractionEnabled:YES];
        [collectionView setUserInteractionEnabled:YES];
        
        if (collectionViewArray.count==1) {
            [[Utility sharedObject] showMBProgress:_viewController.view message:@""];
            [BagView removeFromSuperview];
            
            [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [avPlayerLayer setFrame:CGRectMake(0, 32, collectionView.frame.size.width,  collectionView.frame.size.height-52)];
            BagView=[[UIView alloc]initWithFrame:CGRectMake(0, 32, collectionView.frame.size.width, collectionView.frame.size.height-52)];
            [BagView addGestureRecognizer:doubleTap];
            
            [BagView. layer addSublayer:avPlayerLayer];
            [self.contentView addSubview:BagView];
            
        }else {
            [BagView removeFromSuperview];
            
            [avPlayerLayer setFrame:CGRectMake(0, 0, _viewController.view.frame.size.width,  _viewController.view.frame.size.height-144)];
            
            BagView=[[UIView alloc]initWithFrame:CGRectMake(0, 144, _viewController.view.frame.size.width, _viewController.view.frame.size.height - 150)];
            BagView.backgroundColor = [UIColor whiteColor];
            [BagView addGestureRecognizer:doubleTap];
            
            [BagView. layer addSublayer:avPlayerLayer];
            [_viewController.view addSubview:BagView];
            
        }
        
        [avPlayer seekToTime:kCMTimeZero];
        [avPlayer play];
    }else {
        
        int x = 0;
        NSArray *collectionViewArray = [_dataArray[[(ActivePollCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"] ;
        if (collectionViewArray.count==1) {
            
        }
        else
        {
            pollView = [[UIView alloc]initWithFrame:CGRectMake(0, 144, _viewController.view.frame.size.width, _viewController.view.frame.size.height - 144)];
            imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _viewController.view.frame.size.width, _viewController.view.frame.size.height-150)];
        }
        pollView.backgroundColor = [UIColor whiteColor];
        
        
        imageScrollView.pagingEnabled  = YES;
        imageScrollView.showsHorizontalScrollIndicator = NO;
        [imageScrollView setContentSize:CGSizeMake(_viewController.view.frame.size.width* collectionViewArray.count, 0)];
        for (int i = 0; i<collectionViewArray.count; i++)
        {
            UIView * myView = [[UIView alloc] initWithFrame : CGRectMake(x, 0,  imageScrollView.frame.size.width, imageScrollView.frame.size.height)];
            UIImageView * myImage=[[UIImageView alloc]init];
            myImage.frame =  CGRectMake(0, 0,  myView.frame.size.width, myView.frame.size.height);
            myImage.contentMode = UIViewContentModeScaleAspectFit;
            myImage. clipsToBounds=YES;
            NSURL *ratingUrl = [NSURL URLWithString:[[collectionViewArray objectAtIndex:i]valueForKey:@"media_name"]];
            [myImage setImageWithURLRequest:[NSURLRequest requestWithURL:ratingUrl] placeholderImage:[UIImage imageNamed:@"likeWhite.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 if (collectionViewArray.count==1) {
                     [myImage setContentMode:UIViewContentModeScaleAspectFill];
                 }
                 else
                 {
                     [myImage setContentMode:UIViewContentModeScaleAspectFit];
                 }
                 [myImage setClipsToBounds:YES];
                 myImage.image= image;
             }failure:nil];
            myImage.userInteractionEnabled = YES;
            [myView addSubview: myImage];
            UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
            doubleTap.numberOfTapsRequired = 2;
            [myImage addGestureRecognizer:doubleTap];
            [imageScrollView addSubview: myView];
            x= x+imageScrollView.frame.size.width;
            
        }
        [imageScrollView setContentOffset:CGPointMake(_viewController.self.view.frame.size.width * indexPath.item, 0) animated:NO];
        [pollView addSubview: imageScrollView];
        if (collectionViewArray.count==1) {
            [collectionView addSubview: pollView];
            
        }
        else {
            
            [_viewController.view addSubview: pollView];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        [self scrollingFinish];
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([avPlayer status] == AVPlayerLooperStatusReady){
        [[Utility sharedObject] hideMBProgress];
    }
}
#pragma mark - UIScrollViewDelegate Methods
- (void)scrollingFinish {
    [pollView setHidden:YES];
    [BagView setHidden:YES];
    [avPlayerLayer.player pause];
    [avPlayer pause];
    [avPlayerLayer removeFromSuperlayer];
    avPlayerLayer.player = nil;
    avPlayer = nil;
}
#pragma mark - UITapGestureRecognizer

-(void)VideoDoubleTap:(UITapGestureRecognizer *)UITapGestureRecognizer
{
    [BagView removeFromSuperview];
    
    [self scrollingFinish];
    
    
}
-(void)handleDoubleTap:(UITapGestureRecognizer *)UITapGestureRecognizer
{
    pollView.hidden = YES;
}

- (IBAction)dislike_action:(id)sender
{
    UIButton *button = (UIButton *) sender;
    
    NSInteger tag=button.tag;
    
    SelectedPollIdStr=[[_dataArray objectAtIndex:_activePollCollectionView.indexPath.row] valueForKey:@"poll_id"];
    selectedUserIdStr=[[_dataArray objectAtIndex:_activePollCollectionView.indexPath.row] valueForKey:@"user_id"];
    
    likeStatusArray=[[NSMutableArray alloc]init];
    
    NSArray *collectionViewArray = [_dataArray[_activePollCollectionView.indexPath.row]valueForKey:@"media_files"] ;
    
    likeStatusArray=[[NSMutableArray alloc]init];
    
    
    NSString* likeStatus;
    
    likeStatus=[collectionViewArray[tag] valueForKey:@"like_dislike"];
    
    
    if([likeStatus isEqualToString:@"1"])
    {
        
        likeDislikeStr=@"0";
    }
    else if([likeStatus isEqualToString:@"0"])
    {
        
        likeDislikeStr=@"1";
        
    }
    else
    {
        likeDislikeStr=@"0";
        
    }
    MediaIdStr=[[collectionViewArray objectAtIndex:tag] valueForKey:@"media_id"];
    
    [self CallLikeDeslikePoll];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callpoll" object:self];
    
}


- (IBAction)voting_action:(id)sender {
    UIButton *button = (UIButton *) sender;
    
    NSInteger tag=button.tag;
    SelectedPollIdStr=[[_dataArray objectAtIndex:_activePollCollectionView.indexPath.row] valueForKey:@"poll_id"];
    selectedUserIdStr=[[_dataArray objectAtIndex:_activePollCollectionView.indexPath.row] valueForKey:@"user_id"];
    NSArray *collectionViewArray = [_dataArray[_activePollCollectionView.indexPath.row]valueForKey:@"media_files"] ;
    
    likeStatusArray=[[NSMutableArray alloc]init];
    
    
    NSString* likeStatus;
    
    likeStatus=[collectionViewArray[tag] valueForKey:@"like_dislike"];
    
    if([likeStatus isEqualToString:@"1"])
    {
        
        likeDislikeStr=@"0";
    }
    else if([likeStatus isEqualToString:@"0"])
    {
        
        likeDislikeStr=@"1";
        
    }
    else
    {
        likeDislikeStr=@"1";
        
    }
    
    MediaIdStr=[[collectionViewArray objectAtIndex:tag] valueForKey:@"media_id"];
    [self CallLikeDeslikePoll];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callpoll" object:self];
    
}
-(void)CallLikeDeslikePoll
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary * params = @{@"user_id":userid,@"poll_id":SelectedPollIdStr,@"like_dislike":likeDislikeStr,@"media_id":MediaIdStr};
    
    [manager POST:@"vote_like_dislikes" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pollTypeStr"] isEqualToString: @"CallGetActivePoll"]) {
                 [self CallGetActivePoll];
             }
             else {
                 [self CallGetCurrentlyVoting];
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         
     }];
}
-(void)CallGetCurrentlyVoting
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_all_current_votes_activities" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [_dataArray removeAllObjects];
             _dataArray =[[[responseObject objectForKey:@"data"]valueForKey:@"result"] mutableCopy];
             [self.activePollCollectionView reloadData];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }];
}

-(void)CallGetActivePoll
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_all_active_polls_including_following_users" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [_dataArray removeAllObjects];
             _dataArray =[[[responseObject objectForKey:@"data"]valueForKey:@"result"] mutableCopy];
             [self.activePollCollectionView reloadData];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }];
}

@end
