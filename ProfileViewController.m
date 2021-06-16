//
//  ProfileViewController.m
//  POP
//
//  Created by salentro on 11/11/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import "ProfileViewController.h"
#import "FollowersViewController.h"
#import "HomeCellTableViewCell.h"
#import "PollCollectionViewCell.h"
#import "AFHTTPSessionManager.h"
#import "ProfilePollCollectionViewCell.h"
#import "HomeViewController.h"
#import "ChatViewController.h"
#import "MyPollCellTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "ChatViewController.h"
#import "ChatDetailViewController.h"
#import "MyAndCurrentPollViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ProfilePollCollectionViewCell.h"
#import "DHSmartScreenshot.h"


@interface ProfileViewController ()
{
    NSArray * pollTypeArray1,* pollTypeArray2 ,* pollTypeArray3 ,* pollTypeArray4 , *imageArray;
    NSString * txtString1,* txtString2,* txtString3,* txtString4;
    NSMutableArray * arr ;
    BOOL slideViewBool; UIImage *screenImage; NSIndexPath *moreBtnindexPath;
    BOOL gridSlideBool; UIView *overlay;
    UIScrollView * imageScrollView;
    NSMutableArray *WinningPollArray;BOOL follow;
    NSString *follow_approval;

   NSString *followStatus;
    NSMutableArray*imagesArray;
    UIRefreshControl*  refreshControl;
    NSInteger status;
    NSString* SelectedPollIdStr;
    NSString* selectedUserIdStr;
    NSUInteger privacyStatus;
}
@property (strong,nonatomic) NSMutableSet *selectedGridRows, *selectedListRows;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@end

@implementation ProfileViewController

#pragma mark-DeletePoll
-(void)deletePoll
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    NSDictionary * params = @{@"poll_id":SelectedPollIdStr};
    
    [manager POST:@"delete_poll_post" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [self CallGetWinningPolls];
             
         }
         else
         {
             
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePoll" object:self];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                     {
                                         
                                     }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }];
    
}

-(void)CallGetWinningPolls
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid;
    NSString*  clickedUserid;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"])
    {
      userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
          clickedUserid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    }
    else
    {
        clickedUserid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];

        userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    }

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"current_id":clickedUserid};
    
    [manager POST:@"get_all_Expiry_polls_winning_media" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [refreshControl endRefreshing];

         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
       
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             follow_approval=[[responseObject valueForKey:@"data"]valueForKey:@"follow_approval"] ;
             
             if (follow==YES) {
                 if ( [follow_approval isEqualToString:@"1"]) {
                     
                     followStatus =@"0";
                     
                 }
                 else  if ([follow_approval isEqualToString:@"0"])
                 {
                     followStatus =@"0";
                 }
                 else
                 {
                     followStatus =@"1";
                     
                 }
                 [self CallFollowAction];
                 
                 follow=NO;
             }

             WinningPollArray=[[responseObject valueForKey:@"data"] valueForKey:@"result"];
             if ( [follow_approval isEqualToString:@"1"]) {
                 
                 
                 [_FollowBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
   
                 
             }
            else if ( [follow_approval isEqualToString:@"0"]) {
                 
                [_FollowBtn setTitle:@"Requested" forState:UIControlStateNormal];

                
             }
             else
             {
                 [_FollowBtn setTitle:@"Follow" forState:UIControlStateNormal];

             }
             
             if ([clickedUserid isEqualToString:userid]) {
                 [_winnerTableView reloadData];
             }
             else
             {

             if ([[[responseObject valueForKey:@"data"] valueForKey:@"follow_approval"] isEqualToString:@"1"]&&[[[WinningPollArray objectAtIndex:0] valueForKey:@"privacy_status"] isEqualToString:@"0"]) {
                   [_winnerTableView reloadData];
             }
             else if ([[[responseObject valueForKey:@"data"] valueForKey:@"follow_approval"] isEqualToString:@"1"]&&[[[WinningPollArray objectAtIndex:0] valueForKey:@"privacy_status"] isEqualToString:@"1"]) {
                  [_winnerTableView reloadData];
             }
             else
             {
                

             }
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"]]) {
                             
                             [_pollBtn setUserInteractionEnabled:YES];
                             [_followerBtn setUserInteractionEnabled:YES];
                             [_followingBtn setUserInteractionEnabled:YES];

                         }
                         else{
                if (privacyStatus==1&&[follow_approval isEqualToString:@"1"]) {
                     
                     [_pollBtn setUserInteractionEnabled:YES];
                     [_followerBtn setUserInteractionEnabled:NO];
                     [_followingBtn setUserInteractionEnabled:NO];
                    
                                    }
                 else if (privacyStatus==0&&[follow_approval isEqualToString:@"1"]) {
                     
                     [_pollBtn setUserInteractionEnabled:YES];
                     [_followerBtn setUserInteractionEnabled:YES];
                     [_followingBtn setUserInteractionEnabled:YES];
                     
                 }
                 else if (privacyStatus==0) {
                     
                     [_pollBtn setUserInteractionEnabled:YES];
                     [_followerBtn setUserInteractionEnabled:YES];
                     [_followingBtn setUserInteractionEnabled:YES];
                 }
                else if (privacyStatus==1)
                   {
                       [_pollBtn setUserInteractionEnabled:NO];
                       [_followerBtn setUserInteractionEnabled:NO];
                       [_followingBtn setUserInteractionEnabled:NO];
                       UILabel *alertLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, self.winnerTableView.frame.size.height/2, self.winnerTableView.frame.size.width, 40)];
                       [alertLbl setTextColor:[UIColor grayColor]];
                       alertLbl.text=@"This Account Is Private.";
                       [alertLbl setTextAlignment:NSTextAlignmentCenter];
                       [self.view addSubview:alertLbl];

                     }
                 else  {
                     
                     [_pollBtn setUserInteractionEnabled:NO];
                     [_followerBtn setUserInteractionEnabled:NO];
                     [_followingBtn setUserInteractionEnabled:NO];
                     
                 }
                         }

                 
         }
         }
         else
         {
//             UILabel *alertLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, self.winnerTableView.frame.size.height/2+30, self.winnerTableView.frame.size.width, 40)];
//             alertLbl.text=@"No Winning Polls Yet";
//             [alertLbl setTextAlignment:NSTextAlignmentCenter];
//             [self.view addSubview:alertLbl];
             
            [_winnerTableView reloadData];
             
          follow_approval=[[responseObject valueForKey:@"data"]valueForKey:@"follow_approval"] ;
             if (follow==YES) {
                 if ( [follow_approval isEqualToString:@"1"]) {
                     
                     followStatus =@"0";
                     
                 }
                 else  if ([follow_approval isEqualToString:@"0"])
                 {
                     followStatus =@"0";
                 }
                 else
                 {
                     followStatus =@"1";
                     
                 }
                 [self CallFollowAction];
                 
                 follow=NO;
             }

             if ( [follow_approval isEqualToString:@"1"]) {
                 
                 
                 [_FollowBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
                 
                 
             }
             else if ( [follow_approval isEqualToString:@"0"]) {
                 
                 [_FollowBtn setTitle:@"Requested" forState:UIControlStateNormal];
             }
             else
             {
                 [_FollowBtn setTitle:@"Follow" forState:UIControlStateNormal];
                 
             }

             
             if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"]]) {
                 
                 [_pollBtn setUserInteractionEnabled:YES];
                 [_followerBtn setUserInteractionEnabled:YES];
                 [_followingBtn setUserInteractionEnabled:YES];
                 
             }
             else{

             if (privacyStatus==1&&[follow_approval isEqualToString:@"1"]) {
                 
                 [_pollBtn setUserInteractionEnabled:YES];
                 [_followerBtn setUserInteractionEnabled:NO];
                 [_followingBtn setUserInteractionEnabled:NO];
                 
         

             }
             else if (privacyStatus==0&&[follow_approval isEqualToString:@"1"]) {
                 
                 [_pollBtn setUserInteractionEnabled:YES];
                 [_followerBtn setUserInteractionEnabled:YES];
                 [_followingBtn setUserInteractionEnabled:
                  YES];
                 
             }
             else if (privacyStatus==0) {
                 
                 [_pollBtn setUserInteractionEnabled:YES];
                 [_followerBtn setUserInteractionEnabled:YES];
                 [_followingBtn setUserInteractionEnabled:YES];
             }
             else if (privacyStatus==1)
             {
                 [_pollBtn setUserInteractionEnabled:NO];
                 [_followerBtn setUserInteractionEnabled:NO];
                 [_followingBtn setUserInteractionEnabled:NO];
                 UILabel *alertLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, self.winnerTableView.frame.size.height/2-20, self.winnerTableView.frame.size.width, 40)];
                 [alertLbl setTextColor:[UIColor grayColor]];
                 alertLbl.text=@"This Account Is Private.";
                 [alertLbl setTextAlignment:NSTextAlignmentCenter];
                 [self.view addSubview:alertLbl];
             }
             else  {
                 
                 [_pollBtn setUserInteractionEnabled:NO];
                 [_followerBtn setUserInteractionEnabled:NO];
                 [_followingBtn setUserInteractionEnabled:NO];
             }
             }
             
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [refreshControl endRefreshing];

         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                     {
                                         
                                     }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }];
    
}
-(void)CallFollowAction
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];

    NSString*follower_id=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
    NSDictionary * params = @{@"user_id":userid,@"to_follow_user_id":follower_id ,@"follow_unfollow_status":followStatus};
    
    [manager POST:@"add_follower_user" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
      
        if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {

            
            
                         if ( [[[responseObject valueForKey:@"data"]  valueForKey:@"msg"] isEqualToString:@"UnFollow this user successfully"]) {
                 
                 [_FollowBtn setTitle:@"Follow" forState:UIControlStateNormal];
             }
             else if( [[[responseObject valueForKey:@"data"]  valueForKey:@"msg"] isEqualToString:@"following saved successfully and waiting for approval."])
             {
             
                 [_FollowBtn setTitle:@"Requested" forState:UIControlStateNormal];
         }
             
             else if( [[[responseObject valueForKey:@"data"]  valueForKey:@"msg"] isEqualToString:@"You already following and waiting for approval."])
             {
                 
                 [_FollowBtn setTitle:@"Follow" forState:UIControlStateNormal];
             }
             else if( [[[responseObject valueForKey:@"data"]  valueForKey:@"msg"] isEqualToString:@"following saved successfully"])

         {
             [_FollowBtn setTitle:@"Unfollow" forState:UIControlStateNormal];

         }
      }
         else
         {

         
         }
     
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                     {
                                         
                                     }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }];
}
-(void)GetUserProfileInfo
{
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"])
    {
       userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
    }
else
{
  userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
}
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_user_profile" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             _UserNameLbl.text=[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"];
           //  self.navigationItem.title = [[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"];

             NSNumber *pollsCount=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"poll_count"];
             _pollLbl.text=[NSString stringWithFormat:@"%@",pollsCount];
             NSNumber*followersCount=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"followers_count"];
             _followersLbl.text=[NSString stringWithFormat:@"%@",followersCount];
             NSNumber*followingsCount=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"following_count"];
          _descLabel.text=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"description"];
             
             _webLabel.text = [[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"website"];
             [_webLabel setTextAlignment:NSTextAlignmentCenter];
             [_webLabel setTextColor:[UIColor whiteColor]];
             [_webLabel setTintColor:[UIColor whiteColor]];
             
        
             
             privacyStatus=[[[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"privacy_status"] integerValue];
            
             
             [_webLabel setEditable:NO];
             [_webLabel setScrollEnabled:NO];
             
             [_webLabel setDataDetectorTypes:UIDataDetectorTypeLink];
             _webLabel.userInteractionEnabled = YES;
//             [_webLabel addGestureRecognizer:
//              [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                      action:@selector(handleTapOnLabel:)]];

             _followingsLbl.text=[NSString stringWithFormat:@"%@",followingsCount];
             
             NSString*profileimg=[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"profile_pic"];
             
             NSURL *imageURL = [NSURL URLWithString:profileimg];

            _UserImgView.layer.cornerRadius = _UserImgView.frame.size.width / 2;
//             _UserImgView.layer.borderWidth = 2.5;
//             _UserImgView.layer.borderColor = [UIColor orangeColor].CGColor;
             _UserImgView.clipsToBounds = YES;
//             [_UserBagImgView addSubview:overlay];
//             [_UserBagImgView setShowActivityIndicator:NO];

                       _UserImgView.imageURL=imageURL;
//             _UserBagImgView.imageURL=imageURL;

             [[NSUserDefaults standardUserDefaults]
              setObject:[imageURL absoluteString] forKey:@"imageURL"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"] forKey:@"user_name"];
          [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"email"] forKey:@"email"];
              [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"website"] forKey:@"website"];
             
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"description"] forKey:@"description"];
             
          
                [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"password"] forKey:@"password"];
              [self CallGetWinningPolls];
         }
         else
         {
             UIAlertController * alert=   [UIAlertController
                                           alertControllerWithTitle:@"Error!"
                                           message:@"Please try again later"
                                           preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                         {
                                             
                                         }];
             [alert addAction:payAction];
             [self presentViewController:alert animated:YES completion:nil];
             
         }
         
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                     {
                                         
                                     }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }];
}
- (void)handleTapOnLabel:(UITapGestureRecognizer *)tapGesture {
   
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_webLabel.text]];

    
}
- (void)refresh:(id)sender
{
    [self CallGetWinningPolls];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
  

    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_winnerTableView  addSubview:refreshControl];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _UserBagImgView.frame.size.width, _UserBagImgView.frame.size.height )];
    [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    

    self.automaticallyAdjustsScrollViewInsets = YES;
    
    _profileScrollView.contentSize = CGSizeMake(0, 0);
    
   // _poolTableView.pagingEnabled = YES;
    
    
   //    gridCollectionView.hidden = YES;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [self GetUserProfileInfo];
   

    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"])
    {
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"]]) {
              [_FollowBtn setHidden:YES];

            [_ChatBtn setHidden:YES];
        //   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FromHome"];
            [_pollBtn setUserInteractionEnabled:YES];
            [_followerBtn setUserInteractionEnabled:YES];
            [_followingBtn setUserInteractionEnabled:YES];

        }
        else
        {
            [_pollBtn setUserInteractionEnabled:NO];
            [_followerBtn setUserInteractionEnabled:NO];
            [_followingBtn setUserInteractionEnabled:NO];
            
        [_FollowBtn setHidden:NO];
        [_ChatBtn setHidden:NO];

        }
    }
    else
    {
        [_backBtn setHidden:YES];
         [_ChatBtn setHidden:YES];
        [_FollowBtn setHidden:YES];
    }
    
    
       }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(WinningPollArray.count>0)
        return WinningPollArray.count;
    else
        return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellidentifier = @"cellId";
    MyPollCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    [_winnerTableView setSeparatorColor:[UIColor lightGrayColor]];
    /// Set Frame
    
    cell.userImageView.frame = CGRectMake(cell.userImageView.frame.origin.x, cell.userImageView.frame.origin.y, cell.userImageView.frame.size.width, cell.userImageView.frame.size.height);
    cell.userNameLabel.frame = CGRectMake(cell.userImageView.frame.size.width+cell.userImageView.frame.origin.x+4, cell.userNameLabel.frame.origin.y, cell.userNameLabel.frame.size.width, cell.userNameLabel.frame.size.height);
    cell.pollDescLable.frame = CGRectMake(0, cell.userImageView.frame.size.height+cell.userImageView.frame.origin.y+6, cell.contentView.frame.size.width, cell.pollDescLable.frame.size.height);
    
    //  cell.activePollCollectionView.frame = CGRectMake(0, cell.pollDescLable.frame.size.height+cell.pollDescLable.frame.origin.y+8, cell.contentView.frame.size.width,  cell.contentView.frame.size.width);
//
    
   cell.activePollCollectionView.frame = CGRectMake(0, cell.pollDescLable.frame.size.height+cell.pollDescLable.frame.origin.y+8, cell.contentView.frame.size.width, cell.contentView.frame.size.height -cell.activePollCollectionView.frame.origin.y-80);
    cell.timerLabel.frame = CGRectMake(cell.timerLabel.frame.origin.x, cell.activePollCollectionView.frame.size.height+cell.activePollCollectionView.frame.origin.y+8, cell.timerLabel.frame.size.width, cell.timerLabel.frame.size.height);
    cell.sepratorView.frame = CGRectMake(0, cell.frame.size.height-44, cell.frame.size.width, 40);
    
    
    /// Seprator  bottom line of view
    CALayer *bottomBorder1 = [CALayer layer];
    bottomBorder1.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    bottomBorder1.frame = CGRectMake(0, cell.activePollCollectionView.frame.size.height - 2, cell.activePollCollectionView.frame.size.width, 2);
    [cell.activePollCollectionView.layer addSublayer:bottomBorder1];
    
    /// Seprator  top line of view
    CALayer *topBorder2 = [CALayer layer];
    topBorder2.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    topBorder2.frame = CGRectMake(0, 0, cell.activePollCollectionView.frame.size.width, 2);
    [cell.activePollCollectionView.layer addSublayer:topBorder2];

      /// CollectionViewLayout
    /// Seprator  bottom line of view
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    bottomBorder.frame = CGRectMake(0, cell.sepratorView.frame.size.height - 2, cell.contentView.frame.size.width, 2);
    [cell.sepratorView.layer addSublayer:bottomBorder];
    
    /// Seprator  top line of view
    CALayer *topBorder = [CALayer layer];
    topBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    topBorder.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, 2);
    [cell.sepratorView.layer addSublayer:topBorder];
    
    //Btn Action
    cell.gridBtn.tag = indexPath.row+100;
    cell.slideViewBtn.tag = indexPath.row+1000;
    cell.moreBtn.tag = indexPath.row+1000;
    
    [cell.gridBtn addTarget:self action:@selector(gridBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.slideViewBtn addTarget:self action:@selector(slideViewBtnnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
   // [cell.NameBtn addTarget:self action:@selector(Name_action:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.selectedGridRows containsObject:indexPath]) {
        
        
        [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath  imageArray:WinningPollArray layoutChangeStr:@"1" gridAndListType:GRIDVIEW];
        [cell.gridBtn setImage:[UIImage imageNamed:@"grid.png"] forState:UIControlStateNormal];
        [cell.slideViewBtn setImage:[UIImage imageNamed:@"arrow-grey.png"] forState:UIControlStateNormal];
    }
    else if ([self.selectedListRows containsObject:indexPath]) {
        [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath imageArray:WinningPollArray layoutChangeStr:@"1"  gridAndListType:LISTVIEW];
        [cell.gridBtn setImage:[UIImage imageNamed:@"grid-grey.png"] forState:UIControlStateNormal];
        [cell.slideViewBtn setImage:[UIImage imageNamed:@"arrow.png"] forState:UIControlStateNormal];
    }
    else{
        [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath  imageArray:WinningPollArray layoutChangeStr:@"1" gridAndListType:GRIDVIEW];
        [cell.gridBtn setImage:[UIImage imageNamed:@"grid.png"] forState:UIControlStateNormal];
        [cell.slideViewBtn setImage:[UIImage imageNamed:@"arrow-grey.png"] forState:UIControlStateNormal];
    }
  
    
    ////////  Get Created  Date From Server  ////////
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate * dateFromString1 = [dateFormatter dateFromString:[[WinningPollArray objectAtIndex:indexPath.row]valueForKey:@"created_date"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * dateFromString1 = [dateFormatter dateFromString:[[WinningPollArray objectAtIndex:indexPath.row]valueForKey:@"created_date"]];
    
    //add duration in created date
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSString * getHourMinuteString =[NSString stringWithFormat:@"%@", [[WinningPollArray objectAtIndex:indexPath.row]valueForKey:@"poll_duration"]];
    if ([getHourMinuteString rangeOfString:@"MIN" options:NSRegularExpressionSearch].location != NSNotFound)
    {
        getHourMinuteString = [getHourMinuteString stringByReplacingOccurrencesOfString:@"MIN"
                               
                                                                             withString:@""];
        [components setMinute:[getHourMinuteString integerValue]];
    }
    else
    {
        getHourMinuteString = [getHourMinuteString stringByReplacingOccurrencesOfString:@"HR"
                                                                             withString:@""];
        [components setHour:[getHourMinuteString integerValue]];
    }
    //add duration in created date
    NSDate *newDate= [calendar dateByAddingComponents:components toDate:dateFromString1 options:0];

    
    
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [localDateFormatter setDateFormat:@"EEEE, dd yyyy, hh:mm a"];
   // Popped on Thursday, 05 2017, 09:34 pm
    cell.createdDateLabel.text  = [NSString stringWithFormat:@"Popped on %@", [localDateFormatter stringFromDate:newDate]];
    
    cell.userNameLabel.text=[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
    cell.pollDescLable.text=[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"poll_description"];
    cell.userImageView.layer.cornerRadius =  cell.userImageView.frame.size.width / 2;
    cell.userImageView.clipsToBounds = YES;
    cell.userImageView.imageURL=[NSURL URLWithString:[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
    
    cell.commentLbl.text=[NSString stringWithFormat:@"%@ Comments",[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"comment_count"]];
    if ( [cell.commentLbl.text isEqualToString:@"1 Comments"]) {
        cell.commentLbl.text=[NSString stringWithFormat:@"%@ Comment",[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"comment_count"]];
        
    }
    
    cell.voteLbl.text=[NSString stringWithFormat:@"%@ Votes",[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"total_votes_count"]];
    
    if ( [cell.voteLbl.text isEqualToString:@"1 Votes"]) {
        cell.voteLbl.text=[NSString stringWithFormat:@"%@ Vote",[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"total_votes_count"]];
        
    }
    if ([[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"media_type"] isEqualToString:@"Video"]) {
        
        [cell. IMageView setHidden:NO];
    }
    else
    {
        [cell. IMageView setHidden:YES];
    }

   
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height-_HeaderView.frame.size.height/2;
    //    return self.view.frame.size.height
    //    -_pollsTableView.frame.origin.y-self.tabBarController.tabBar.frame.size.height;
    
}

#pragma mark - UIScrollViewDelegate Methods


#pragma mark - UITapGestureRecognizer

-(void)handleDoubleTap:(UITapGestureRecognizer *)UITapGestureRecognizer
{
    self.navigationController.navigationBarHidden = NO;
    
    imageScrollView.hidden = YES;
}


#pragma mark - Events


- (IBAction)backBtnAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"FromHome"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)FollowAction:(id)sender
{
    [self CallGetWinningPolls];
    follow=YES;
    
}

- (IBAction)editBtnTapped:(id)sender
{
    [self performSegueWithIdentifier: @"EditProfileViewController" sender: self];
}
- (IBAction)pollBtnAction:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"])
    {
       
        NSString*getid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
        [[NSUserDefaults standardUserDefaults] setObject:getid forKey:@"getidfollow"];

    }
    else
    {
        NSString*getid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
        [[NSUserDefaults standardUserDefaults] setObject:getid forKey:@"getidfollow"];

    }
    MyAndCurrentPollViewController * HomeView = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAndCurrentPollViewController"];
    [self.navigationController pushViewController:HomeView animated:NO];
}
- (IBAction)followingBtnAction:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"])
    {
        
        NSString*getid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
        [[NSUserDefaults standardUserDefaults] setObject:getid forKey:@"getidfollow"];
        
    }
    else
    {
        NSString*getid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
        [[NSUserDefaults standardUserDefaults] setObject:getid forKey:@"getidfollow"];
        
    }
    FollowersViewController * followView = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowerView"];
    followView.followViewTypeString = FOLLOWING_VIEW;
    [self.navigationController pushViewController:followView animated:NO];
}
- (IBAction)followerBtnAction:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"])
    {
        
        NSString*getid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
        [[NSUserDefaults standardUserDefaults] setObject:getid forKey:@"getidfollow"];
        
    }
    else
    {
        NSString*getid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
        [[NSUserDefaults standardUserDefaults] setObject:getid forKey:@"getidfollow"];
        
    }
    FollowersViewController * followView = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowerView"];
    followView.followViewTypeString = FOLLOWER_VIEW;
    [self.navigationController pushViewController:followView animated:NO];
}
- (IBAction)gridBtnAction:(id)sender
{
    gridSlideBool = YES;
    [_gridBtn setImage:[UIImage imageNamed:@"square_icon.png"] forState:UIControlStateNormal];
     [_listBtn setImage:[UIImage imageNamed:@"forma_icon.png"] forState:UIControlStateNormal];


}
- (IBAction)Chat_action:(id)sender
{
    NSString*reciever_id= [[NSUserDefaults standardUserDefaults ]valueForKey:@"clickedUserid"];
    [[NSUserDefaults standardUserDefaults]setObject:reciever_id forKey:@"reciever_id"];
    
        ChatViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        [self.navigationController pushViewController:ProfileView animated:YES];
        

    

    
  }
//-(void)Name_action:(UIButton *)sender
//{
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.winnerTableView];
//    NSIndexPath *indexPath = [self.winnerTableView indexPathForRowAtPoint:buttonPosition];
//    [[NSUserDefaults standardUserDefaults]setObject:[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"user_id"] //forKey:@"userid"];
 //   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Fromsearch"];
    
 //   [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromHome"];
//    ProfileViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
//    [self.navigationController pushViewController:ProfileView animated:YES];
//}
-(void)slideViewBtnnAction:(UIButton *)sender
{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.winnerTableView];
    NSIndexPath *indexPath = [self.winnerTableView indexPathForRowAtPoint:buttonPosition];
    MyPollCellTableViewCell *cell = [self.winnerTableView cellForRowAtIndexPath:indexPath];
    
    [self.selectedListRows addObject:indexPath];
    if ([self.selectedGridRows containsObject:indexPath]) {
        [self.selectedGridRows removeObject:indexPath];
    }
    [cell.gridBtn setImage:[UIImage imageNamed:@"grid-grey.png"] forState:UIControlStateNormal];
    [cell.slideViewBtn setImage:[UIImage imageNamed:@"arrow.png"] forState:UIControlStateNormal];
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath imageArray:WinningPollArray layoutChangeStr:[[WinningPollArray objectAtIndex:indexPath.row]valueForKey:@"media_count"]  gridAndListType:LISTVIEW];
    
    
}
- (UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame {
    
    UIGraphicsBeginImageContextWithOptions(screenImage.size, NO, 0.0);
    [screenImage drawInRect:CGRectMake(0.0, 0.0, screenImage.size.width, screenImage.size.height)];
    [inputImage drawInRect:frame];
    screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}
-(void)moreBtnAction:(UIButton *)sender
{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.winnerTableView];
    moreBtnindexPath = [self.winnerTableView indexPathForRowAtPoint:buttonPosition];
    screenImage = [self.winnerTableView screenshotOfCellAtIndexPath:moreBtnindexPath];
    UIImage*image=[UIImage imageNamed:@"mainlogo.png"];
    [self drawImage:image inRect: CGRectMake(screenImage.size.width-47, screenImage.size.height/2+30, 46, 46) ];

    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(screenImage);
    if (imageData) {
        [imageData writeToFile:@"./screenshot.png" atomically:YES];
    } else {
        NSLog(@"error while taking screenshot");
    }
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"" message:@"Please Select an Option" preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Tweet" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self TwitterShare];
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Share to Instagram" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self instaGramWallPost];
        
        
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Share to Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self fbShare];
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
        NSString *emailTitle = @"Report Mail";
        // Email Content
        NSString *messageBody = @"Type issue with this poll!"; // Change the message body to HTML
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@"info@poptheworld.com"];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:YES];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:nil];
        
        
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    SelectedPollIdStr=[[WinningPollArray objectAtIndex:moreBtnindexPath.row] valueForKey:@"poll_id"];
    selectedUserIdStr=[[WinningPollArray objectAtIndex:moreBtnindexPath.row]valueForKey:@"user_id"];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    if ([selectedUserIdStr isEqualToString:userid]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self deletePoll];
            
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        
    }

    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
}
-(void)fbShare
{
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [fbSheetOBJ setInitialText:@"Check out pop App"];
        [fbSheetOBJ addImage:screenImage];
        
        [fbSheetOBJ setInitialText:@"pop App"];
        [self presentViewController:fbSheetOBJ animated:YES completion:Nil];
        
    }
    else
    {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Facebook not installed!"
                                      message:@"Facebook integration is not available.  A Facebook account must be set up on your device."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)TwitterShare
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
          [tweetSheet setInitialText:@"Hi I want your opinion on this question.Install the app to vote on my polls: https://itunes.apple.com/us/app/pop-the-world/id1200362716?ls=1&mt=8 "];
        
        [tweetSheet addImage:screenImage];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
    }
    else
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Twitter not installed!"
                                      message:@"Twitter integration is not available. A Twitter account must be set up on your device."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    
}


-(void)instaGramWallPost
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {

    NSString* imagePath = [NSString stringWithFormat:@"%@/instagramShare.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    
    UIImage *instagramImage = [UIImage imageNamed:@"square_icon.png"];
    [UIImagePNGRepresentation(instagramImage) writeToFile:imagePath atomically:YES];
    NSLog(@"Image Size >>> %@", NSStringFromCGSize(instagramImage.size));
    
    self.documentController=[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
    self.documentController.delegate = self;
    self.documentController.UTI = @"com.instagram.exclusivegram";
    [self.documentController presentOpenInMenuFromRect: self.view.frame inView:self.view animated:YES ];
    }
    else
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Instagram not installed!"
                                      message:@"Instagram integration is not available. A Instagram account must be set up on your device."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }

    
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    NSLog(@"file url %@",fileURL);
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
}
- (IBAction)CommentBtn_Action:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.winnerTableView];
    NSIndexPath *indexPath = [self.winnerTableView indexPathForRowAtPoint:buttonPosition];
    [[NSUserDefaults standardUserDefaults]setObject:[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"poll_id"] forKey:@"poll_id"];
    
}


- (IBAction)like_action:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.winnerTableView];
    NSIndexPath *indexPath = [self.winnerTableView indexPathForRowAtPoint:buttonPosition];
    [[NSUserDefaults standardUserDefaults]setObject:[[WinningPollArray objectAtIndex:indexPath.row] valueForKey:@"poll_id"] forKey:@"poll_id"];
}
- (IBAction)listBtnAction:(id)sender
{
    gridSlideBool = NO;
//    gridCollectionView.hidden = YES;
    [_gridBtn setImage:[UIImage imageNamed:@"square_icon_gray.png"] forState:UIControlStateNormal];
    [_listBtn setImage:[UIImage imageNamed:@"forma_icon_orange.png"] forState:UIControlStateNormal];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
