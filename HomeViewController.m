//
//  HomeViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCellTableViewCell.h"
#import "PollCollectionViewCell.h"
#import <Social/Social.h>
#import "AFHTTPSessionManager.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Social/Social.h>
#import "ProfileViewController.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "VotesViewController.h"
#import "CommentViewController.h"
#import "ChatViewController.h"
#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "DHSmartScreenshot.h"
#import "Utility.h"
#import "MyAndCurrentPollViewController.h"
#import "BranchInviteViewController.h"
#import "BranchInviteTextContactProvider.h"
#import "BranchInviteEmailContactProvider.h"
#import "BranchActivityItemProvider.h"
#import "BranchSharing.h"
#import "UIViewController+BranchShare.h"
#import "BranchReferralController.h"
#import "CurrentUserModel.h"

@interface HomeViewController ()
{
    NSArray  *imageArray;
    NSString *SelectedPollIdStr,*selectedUserIdStr,*likeDislikeStr,*MediaIdStr, *inviteName;
    NSMutableArray *AlldataArray ;
    NSDictionary * dic;
    UIScrollView * imageScrollView;
    UIView * pollView;
    NSUInteger index;
    NSMutableArray *likeStatusArray;
    UIRefreshControl*  refreshControl;
    NSTimer*timer;
    NSIndexPath *moreBtnindexPath;  AVPlayer*  avPlayer ;  AVPlayerLayer*   avPlayerLayer;
    UIImage *screenImage;
    UIView*BagView; NSArray *dataArray;
    BOOL vote;NSInteger votingtag;
    NSIndexPath *votingindexPath ;
    NSInteger notification_status, comment_status;
   
}
@property (strong,nonatomic) NSMutableSet *selectedGridRows, *selectedListRows , *fullListRows;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation HomeViewController
- (void)inviteControllerDidFinish {
    [self dismissViewControllerAnimated:YES completion:^{
        [[[UIAlertView alloc] initWithTitle:@"Hooray!" message:@"Your invites have been sent!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)inviteControllerDidCancel {
    [self dismissViewControllerAnimated:YES completion:^{
        //[[[UIAlertView alloc] initWithTitle:@"Awe :(" message:@"Your invites were canceled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}
- (NSDictionary *)inviteUrlCustomData {
    return @{ };
}

- (NSString *)invitingUserId {
    return [CurrentUserModel sharedModel].userId;
}

- (NSString *)invitingUserFullname {
    return [CurrentUserModel sharedModel].userFullname;
}

- (NSString *)finvitingUserShortName {
    return [CurrentUserModel sharedModel].userShortName;
}

- (NSString *)invitingUserImageUrl {
    return [CurrentUserModel sharedModel].userImageUrl;
}

- (NSArray *)inviteContactProviders {
    
    return @[
             [BranchInviteTextContactProvider textContactProviderWithInviteMessageFormat:[NSString stringWithFormat:@"Hi,\n\nDownload POP and follow me so you\ncan vote on my photos and videos.\nMy user name is %@,\n\n Here's the link: https://itunes.apple.com/us/app/p-o-p/id1200362716?ls=1&mt=8", inviteName]],
             ];
}
#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self shiftKeyboardIfNecessary];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userFullnameField) {
        [self.userShortNameField becomeFirstResponder];
    }
    else if (textField == self.userShortNameField) {
        [self.userImageUrlField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.userFullnameField) {
        [CurrentUserModel sharedModel].userFullname = textField.text;
    }
    else if (textField == self.userShortNameField) {
        [CurrentUserModel sharedModel].userShortName = textField.text;
    }
    else {
        [CurrentUserModel sharedModel].userImageUrl = textField.text;
    }
}


#pragma mark - BranchReferralScore delegate

- (NSString *)referringUserId {
    return [CurrentUserModel sharedModel].userId;
}

- (void)branchReferralControllerCompleted {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Keyboard Management methods

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.keyboardFrame = keyboardFrame;
    
    [self shiftKeyboardIfNecessary];
}

- (void)keyboardWillHide:(NSNotification *)notification  {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = 0;
    self.view.frame = viewFrame;
}


#pragma mark - Internal methods

- (void)setUpCurrentUserIfNecessary {
    CurrentUserModel *sharedModel = [CurrentUserModel sharedModel];
    if (!sharedModel.userId) {
        sharedModel.userId = [NSUUID UUID].UUIDString;
        sharedModel.userFullname = @"Graham Mueller";
        sharedModel.userShortName = @"Graham";
        sharedModel.userImageUrl = @"https://www.gravatar.com/avatar/28ed70ee3c8275f1d307d1c5b6eddfa5";
    }
    
    self.userIdLabel.text = sharedModel.userId;
    self.userFullnameField.text = sharedModel.userFullname;
    self.userShortNameField.text = sharedModel.userShortName;
    self.userImageUrlField.text = sharedModel.userImageUrl;
}

- (void)shiftKeyboardIfNecessary {
    CGRect viewFrame = self.view.frame;
    CGRect activeTextFieldFrame = self.activeTextField.frame;
    CGFloat bottomPadding = 4;
    CGFloat lowestPointCoveredByKeyboard = -viewFrame.origin.y + viewFrame.size.height - self.keyboardFrame.size.height;
    CGFloat distanceActiveTextFieldIsUnderFrame = activeTextFieldFrame.origin.y + activeTextFieldFrame.size.height - lowestPointCoveredByKeyboard;
    
    if (distanceActiveTextFieldIsUnderFrame > 0) {
        viewFrame.origin.y -= distanceActiveTextFieldIsUnderFrame + bottomPadding;
        
        self.view.frame = viewFrame;
    }
}
-(void)GetUserProfileInfo
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_user_profile" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             inviteName = [[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"];
             notification_status=(int)[[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"is_notification"] integerValue];
             comment_status=(int)[[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"is_comment"] integerValue];
             
             if (notification_status ==0){
                 [_bellBtn setHidden:YES];
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     }];
}

-(void)CallGetFollowers
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
       
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSInteger indexFollowScreen = [[[NSUserDefaults standardUserDefaults] objectForKey:@"indexFollowScreen"] longValue];
    NSInteger tag= [[[NSUserDefaults standardUserDefaults] objectForKey:@"tag"] longValue];
    NSDictionary * params = @{@"user_id":[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"]};
    
    [manager POST:@"get_all_follower_users_polls" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [refreshControl endRefreshing];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [AlldataArray removeAllObjects];
             NSMutableArray*array=[[NSMutableArray alloc]init];
             NSDictionary * dict = [[NSDictionary alloc]init];
             array  =[[responseObject objectForKey:@"data"]valueForKey:@"result"];
             dict =   [[array[indexFollowScreen]valueForKey:@"list_of_polls"] objectAtIndex:tag] ;
             [AlldataArray addObject: dict];
             [_feedTableview reloadData];
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:@"followercall" object:self];

         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }];
}
-(void)CallGetFollowings
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSInteger indexFollowScreen = [[[NSUserDefaults standardUserDefaults] objectForKey:@"indexFollowScreen"] longValue];
    NSInteger tag= [[[NSUserDefaults standardUserDefaults] objectForKey:@"tag"] longValue];
    NSDictionary * params = @{@"user_id":[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"]};
    
    [manager POST:@"get_all_following_users_polls" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [refreshControl endRefreshing];
         
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [AlldataArray removeAllObjects];
             NSMutableArray*array=[[NSMutableArray alloc]init];
             NSDictionary * dict = [[NSDictionary alloc]init];
             array  =[[responseObject objectForKey:@"data"]valueForKey:@"result"];
             dict =   [[array[indexFollowScreen]valueForKey:@"list_of_polls"] objectAtIndex:tag] ;
             [AlldataArray addObject: dict];
             [_feedTableview reloadData];

         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }];
}
#pragma mark-DeletePoll
-(void)deletePoll
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary * params = @{@"poll_id":SelectedPollIdStr};
    
    [manager POST:@"delete_poll_post" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             [timer invalidate];
             [AlldataArray removeAllObjects];
             [self CallServiceGetAllPolls];
         }
        
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }];

}
-(void)CallLikeDeslikePoll
{
    

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSLog(@"______ poll_id: %@, ---- media_id: %@", SelectedPollIdStr, MediaIdStr);

    NSDictionary * params = @{@"user_id":userid,@"poll_id":SelectedPollIdStr,@"like_dislike":likeDislikeStr,@"media_id":MediaIdStr};
    
    [manager POST:@"vote_like_dislikes" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
            
             if ([_followgFollowString isEqual:FOLLOWER_VIEW]) {
                 [self CallGetFollowers];
             }
             else if ([_followgFollowString isEqual:FOLLOWING_VIEW]) {
                 [self CallGetFollowings];
             }
            
             [self CallServiceGetAllPolls];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }];
    
}
-(void)CallGetCurrentlyVoting
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"getidfollow"];
    
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_all_current_votes_activities" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {}
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              NSLog(@"JSON: %@", responseObject);
              if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
                  
                  [AlldataArray removeAllObjects];
                  AlldataArray =[[[responseObject objectForKey:@"data"]valueForKey:@"result"] mutableCopy];
                  [_feedTableview reloadData];
              }
              else {
                  [AlldataArray removeAllObjects];
                  [_feedTableview reloadData];
              }
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
              NSLog(@"Error: %@", error);
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
     //[[Utility sharedObject] showMBProgress:self.view message:@""];
    
    [_bellBtn setHidden:YES];
    [_messageBtn setHidden:YES];
    [_feedTableview reloadData];
    
    [self GetUserProfileInfo];
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"FromHome"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"LogInKey"];
    
    [self CallServiceGetAllPolls];
    
    _feedTableview.frame = CGRectMake(_feedTableview.frame.origin.x, 65, _feedTableview.frame.size.width,  _feedTableview.frame.size.height+65);
    _feedTableview.frame = CGRectMake(_feedTableview.frame.origin.x, 65, _feedTableview.frame.size.width,  _feedTableview.frame.size.height-65);
    _feedTableview.scrollEnabled = YES;

    NSString*notification_typeStr=   [[NSUserDefaults standardUserDefaults]valueForKey:@"notification_typeStr"];
    
    if ( [notification_typeStr isEqualToString:@"chat"]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"notification_typeStr"];

        ChatViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        [self.navigationController pushViewController:ProfileView animated:NO];
        
    }
    
    else if ([notification_typeStr isEqualToString:@"like_dislike"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"notification_typeStr"];

        VotesViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"VotesViewController"];
        [self.navigationController pushViewController:ProfileView animated:NO];
    }
    
    else if ([notification_typeStr isEqualToString:@"comment"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"notification_typeStr"];

        CommentViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
        [self.navigationController pushViewController:ProfileView animated:NO];
        
    }
    else if ([notification_typeStr isEqualToString:@"follower_request"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"notification_typeStr"];

        MyAndCurrentPollViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAndCurrentPollViewController"];
        [self.navigationController pushViewController:ProfileView animated:NO];
        
    }
    else if ([notification_typeStr isEqualToString:@"follower"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"notification_typeStr"];

        MyAndCurrentPollViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAndCurrentPollViewController"];
        [self.navigationController pushViewController:ProfileView animated:NO];
        
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_feedTableview  addSubview:refreshControl];

    self.automaticallyAdjustsScrollViewInsets= NO;
    UIImage *image = [UIImage imageNamed:@"popText.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    bottomBorder.frame = CGRectMake(0, 63, _feedTableview.frame.size.width, 2);
    [_notificationView.layer addSublayer:bottomBorder];
    _feedTableview.pagingEnabled = NO;
    
}
- (void)refresh:(id)sender
{
    [self CallServiceGetAllPolls];
    
}
- (void)makeRoot:(NSNotification *)notification {
     [self CallServiceGetAllPolls];
}
-(void)viewWillAppear:(BOOL)animated{
    [_bellBtn setHidden:YES];
    [self GetUserProfileInfo];
    [self refresh:selectedUserIdStr];
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeRoot:) name:@"DeletePoll" object:nil];
}
#pragma mark -GetAllPolls
-(void)CallServiceGetAllPolls {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_all_polls_including_following_users" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
           [refreshControl endRefreshing];
           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
           NSLog(@"get all polls: %@", responseObject);
         
             if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             [self reloadInputViews];
             [AlldataArray removeAllObjects];
             likeStatusArray=[[NSMutableArray alloc]init];

             AlldataArray =[[[[responseObject objectForKey:@"data"]valueForKey:@"result"] valueForKey:@"list_of_polls"] mutableCopy];
             dataArray=[[NSArray alloc]init];
             dataArray=[[responseObject valueForKey:@"data"] valueForKey:@"result"];
             NSInteger notiCount=[[dataArray valueForKey:@"new_notifications_count"] longValue];
             NSInteger msgCount=[[dataArray valueForKey:@"new_msg_count"] longValue];
             
             if (notiCount ==0) {
                 [_bellBtn setHidden:YES];
             }
             else
             {
                 [_bellBtn setHidden:NO];
                 [_bellBtn setTitle:[NSString stringWithFormat:@"%ld",(long)notiCount] forState:UIControlStateNormal];
                 _bellBtn.layer.cornerRadius = _bellBtn.frame.size.width/2;
                 _bellBtn.clipsToBounds = YES;
                 
             }
             if (msgCount==0) {
                 [_messageBtn setHidden:YES];
             }
             else
             {
                 [_messageBtn setHidden:NO];
                 [_messageBtn setTitle:[NSString stringWithFormat:@"%ld",(long)msgCount] forState:UIControlStateNormal];
                 _messageBtn.layer.cornerRadius = _messageBtn.frame.size.width/2;
                 _messageBtn.clipsToBounds = YES;
                 
             }
             
             if (vote==YES) {
                 HomeCellTableViewCell*cell = [self.feedTableview cellForRowAtIndexPath:votingindexPath];
                 [cell.pollCollectionView reloadData];
               
                 vote=NO;
             }
             else {
                 [_feedTableview reloadData];
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [refreshControl endRefreshing];

         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }];
 
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%@",AlldataArray);
    if(AlldataArray.count>0)
    return AlldataArray.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellidentifier = @"cellId";
    HomeCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    [self.feedTableview setSeparatorColor:[UIColor clearColor]];
    
    cell.userImageView.frame = CGRectMake(cell.userImageView.frame.origin.x, 8, cell.userImageView.frame.size.width, cell.userImageView.frame.size.height);
    cell.userNameLabel.frame = CGRectMake(cell.userImageView.frame.size.width+cell.userImageView.frame.origin.x+4, 10, cell.userNameLabel.frame.size.width, cell.userNameLabel.frame.size.height);
    cell.NameBtn.frame = CGRectMake(cell.userImageView.frame.origin.x, 8, cell.userImageView.frame.size.width + cell.userNameLabel.frame.size.width, cell.NameBtn.frame.size.height);
    cell.lineView.frame = CGRectMake(0, cell.userImageView.frame.origin.y + cell.userImageView.frame.size.height + 5, self.view.frame.size.width, 1);
    
    [cell.NameBtn addTarget:self action:@selector(Name_action:) forControlEvents:UIControlEventTouchUpInside];
    cell.userNameLabel.text=[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
    cell.userImageView.layer.cornerRadius =  cell.userImageView.frame.size.width/2 +2;
    cell.userImageView.clipsToBounds = YES;
    cell.userImageView.imageURL=[NSURL URLWithString:[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
    
    if ([[AlldataArray [indexPath.row] valueForKey:@"question"] isEqualToString:@""]) {
        [cell.aboutPoll setHidden:YES];
    }else {
        [cell.aboutPoll setHidden:NO];
    }
    
    NSArray *collectionViewArray = [AlldataArray[indexPath.row]valueForKey:@"media_files"] ;
    CALayer *bottomBorder1;
    
    if (collectionViewArray.count ==1) {
        [cell.bottomLbl setHidden:YES];
        cell.pollCollectionView.frame = CGRectMake(0, cell.userImageView.frame.origin.y +cell.userImageView.frame.size.height +30, cell.contentView.frame.size.width, self.view.frame.size.width + 55);
        
    } if (collectionViewArray.count==2) {
        [cell.bottomLbl setHidden:YES];
        [bottomBorder1 setHidden:YES];
        cell.pollCollectionView.frame = CGRectMake(0, cell.userImageView.frame.origin.y +cell.userImageView.frame.size.height +30, cell.contentView.frame.size.width, (self.view.frame.size.width + 30)/2 +40 );
        
    }if (collectionViewArray.count ==3){
        [cell.bottomLbl setHidden:YES];
        [bottomBorder1 setHidden:YES];
        cell.pollCollectionView.frame = CGRectMake(0,  cell.userImageView.frame.origin.y +cell.userImageView.frame.size.height +30, cell.contentView.frame.size.width,(self.view.frame.size.width + 30)/2 -30);
        
    }if (collectionViewArray.count ==4) {
        [cell.bottomLbl setHidden:YES];
        cell.pollCollectionView.frame = CGRectMake(0, cell.userImageView.frame.origin.y +cell.userImageView.frame.size.height +30, cell.contentView.frame.size.width, self.view.frame.size.width + 30*2 +40);
    }
    
    cell.pollDescLable.frame = CGRectMake(40, cell.pollCollectionView.frame.origin.y +cell.pollCollectionView.frame.size.height +10, cell.contentView.frame.size.width - 80, cell.pollDescLable.frame.size.height);
    cell.timerLabel.frame = CGRectMake(cell.timerLabel.frame.origin.x, cell.pollCollectionView.frame.origin.y +cell.pollCollectionView.frame.size.height +10 + cell.pollDescLable.frame.size.height, cell.timerLabel.frame.size.width, cell.timerLabel.frame.size.height);

    cell.aboutPoll.frame = CGRectMake(15, cell.timerLabel.frame.origin.y + cell.timerLabel.frame.size.height + 8, self.view.frame.size.width -30, ((NSString*)[[Utility getHeightOfText:[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"question"] fontSize:14 width:self.view.frame.size.width] valueForKey:@"height"]).floatValue);

    cell.aboutPoll.text =[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"question"];
    
    cell.IMageView.frame = CGRectMake(0, cell.pollCollectionView.frame.origin.y +cell.pollCollectionView.frame.size.height +5, cell.IMageView.frame.size.width, cell.IMageView.frame.size.height);
    if ([[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"media_type"] isEqualToString:@"Video"]) {
        
        [cell. IMageView setHidden:NO];
    }
    else
    {
        [cell. IMageView setHidden:YES];
    }
    
  
    if ([[AlldataArray [indexPath.row] valueForKey:@"poll_duration"] isEqualToString:@"0"]||[[AlldataArray [indexPath.row] valueForKey:@"poll_duration"] isEqualToString:@"0"]) {
        [cell.timerLabel setHidden:YES];
    }
    else {
        [cell.timerLabel setHidden:NO];

        cell.timerLabel.frame = CGRectMake(cell.timerLabel.frame.origin.x, cell.pollCollectionView.frame.origin.y +cell.pollCollectionView.frame.size.height +10 + cell.pollDescLable.frame.size.height, cell.timerLabel.frame.size.width , cell.timerLabel.frame.size.height);
    }
        CALayer*  bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
        bottomBorder.frame = CGRectMake(0, cell.sepratorView.frame.size.height - 2, cell.contentView.frame.size.width, 2);
        [cell.sepratorView.layer addSublayer:bottomBorder];

    
        CALayer *topBorder = [CALayer layer];
        topBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
        topBorder.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, 2);
        [cell.sepratorView.layer addSublayer:topBorder];

        [cell.moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    

        [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath layoutChangeStr: [[AlldataArray objectAtIndex:indexPath.row]valueForKey:@"media_count"] gridAndListType:GRIDVIEW imageFull:nil];
  
        cell.pollDescLable.text=[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"poll_description"];
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * dateFromString1 = [dateFormatter dateFromString:[[AlldataArray objectAtIndex:indexPath.row]valueForKey:@"created_date"]];
        
    
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        NSString * getHourMinuteString =[NSString stringWithFormat:@"%@", [[AlldataArray objectAtIndex:indexPath.row]valueForKey:@"poll_duration"]];
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
    
        cell.sepratorView.frame = CGRectMake(0, cell.frame.size.height-44, cell.frame.size.width, 40);
    
        NSDate *newDate= [calendar dateByAddingComponents:components toDate:dateFromString1 options:0];
        
        NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
        [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [localDateFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
    
        cell.dateShow.text  = [NSString stringWithFormat:@"Popped on %@", [localDateFormatter stringFromDate:newDate]];
            
        cell.commentLbl.text=[NSString stringWithFormat:@"%@ Comments",[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"comment_count"]];
    if ( [cell.commentLbl.text isEqualToString:@"1 Comments"]) {
        cell.commentLbl.text=[NSString stringWithFormat:@"%@ Comment",[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"comment_count"]];
    }
        cell.voteLbl.text=[NSString stringWithFormat:@"%@ Votes",[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"total_votes_count"]];
    
    if ( [cell.voteLbl.text isEqualToString:@"1 Votes"]) {
        cell.voteLbl.text=[NSString stringWithFormat:@"%@ Vote",[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"total_votes_count"]];

    }
    
     timer=  [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateCountdown:) userInfo:indexPath repeats:YES];

     return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float desc_hight = ((NSString*)[[Utility getHeightOfText:[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"question"] fontSize:14 width:self.view.frame.size.width] valueForKey:@"height"]).floatValue;
    NSString *about_text =[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"question"];
    NSString *desc_text =[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"poll_description"];
    NSString *timer_text = [[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"poll_duration"];
    
    NSArray *collectionViewArray = [AlldataArray[indexPath.row]valueForKey:@"media_files"] ;
    
        if (collectionViewArray.count == 1) {
            
            if (IS_IPHONE_5) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+325 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+345 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+345 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+390 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+390 + desc_hight;
                }
                
            }else  if (IS_IPHONE_6 || IS_IPHONE_7 ||IS_IPHONE_8 ||IS_IPHONE_X || IS_IPHONE_SE) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+325 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+345 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+345 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+390 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+390 + desc_hight;
                }
                
            }else if (IS_IPHONE_6_PLUS || IS_IPHONE_7_PLUS || IS_IPHONE_8_PLUS) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+345 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+410 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+385 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+410 + desc_hight;
                }
            } else {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+345 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+410 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+385 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+410 + desc_hight;
                }
            }
        }if (collectionViewArray.count == 2) {
            
            if (IS_IPHONE_5) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+135 + desc_hight;
                }else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+155 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+155 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+200 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+175 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+200 + desc_hight;
                }

                
            }else  if (IS_IPHONE_6 || IS_IPHONE_7 ||IS_IPHONE_8 ||IS_IPHONE_X || IS_IPHONE_SE) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+135 + desc_hight;
                }else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+155 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+155 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+200 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+175 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+200 + desc_hight;
                }

                
            }else if (IS_IPHONE_6_PLUS || IS_IPHONE_7_PLUS || IS_IPHONE_8_PLUS) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+135 + desc_hight;
                }else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+155 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+155 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+200 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+175 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+200 + desc_hight;
                }
            } else {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+185 + desc_hight;
                }else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+205 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+205 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+250 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+225 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+240 + desc_hight;
                }
            }
        }if (collectionViewArray.count == 3) {
            if (IS_IPHONE_5) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+65 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+85 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+105 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+150 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+125 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+150 + desc_hight;
                }
                
            }else  if (IS_IPHONE_6 || IS_IPHONE_7 ||IS_IPHONE_8 ||IS_IPHONE_X || IS_IPHONE_SE) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+65 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+85 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+85 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+130 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+105 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+130 + desc_hight;
                }
                
            }else if (IS_IPHONE_6_PLUS || IS_IPHONE_7_PLUS || IS_IPHONE_8_PLUS) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+65 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+85 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+85 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+130 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+105 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+130 + desc_hight;
                }
            } else {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+115 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+135 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+135 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+180 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+155 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+180 + desc_hight;
                }
            }
        }if (collectionViewArray.count ==4) {
            if (IS_IPHONE_5) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+385 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+385 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+430 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+405 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+430 + desc_hight;
                }
                
            }else  if (IS_IPHONE_6 || IS_IPHONE_7 ||IS_IPHONE_8 ||IS_IPHONE_X || IS_IPHONE_SE) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+385 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+385 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+430 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+405 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+430 + desc_hight;
                }
                
            }else if (IS_IPHONE_6_PLUS || IS_IPHONE_7_PLUS || IS_IPHONE_8_PLUS) {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+385 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+405 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+405 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+450 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+425 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+450 + desc_hight;
                }
            } else {
                if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+405 + desc_hight;
                }
                else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+425 + desc_hight;
                }
                else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+425 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+470 + desc_hight;
                }
                else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+445 + desc_hight;
                }else {
                    return (self.view.frame.size.height-65-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+470 + desc_hight;
                }
            }
        }
    
    return 0;
}

#pragma mark - UICollectionView Delegate

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionViewArray = [AlldataArray[[(PollCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"] ;
    if (collectionViewArray.count>0)
        
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
    
        if(other > percentage)
            return NO;
    }
    
    return YES;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PollCollectionViewCell* Cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    Cell.votePercentageBtn.tag = indexPath.row;
    [Cell.votePercentageBtn addTarget:self action:@selector(voting_action:) forControlEvents:UIControlEventTouchUpInside];

    Cell.dislikeBtn.tag = indexPath.row;
    [Cell.dislikeBtn addTarget:self action:@selector(dislike_action:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *collectionViewArray = [AlldataArray[[(PollCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"] ;
    
    NSLog(@"------- media file: %@", collectionViewArray);
    
    Cell.likeUpView.hidden = NO;
    
    if (collectionViewArray.count == 1) {
           
         Cell.dislikeView.hidden = NO;
         Cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height);
         Cell.pollImageView.frame= CGRectMake(0, Cell.contentView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width, collectionView.frame.size.height - Cell.likeUpView.frame.size.height - 6);
         Cell.pollbackImageView.frame = CGRectMake(0, Cell.contentView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width, collectionView.frame.size.height - Cell.likeUpView.frame.size.height - 1);
         Cell.dislikeView.frame = CGRectMake(self.view.frame.size.width/2-Cell.dislikeView.frame.size.width -2, Cell.contentView.frame.origin.y+2, Cell.dislikeView.frame.size.width, Cell.dislikeView.frame.size.height);
         Cell.likeUpView.frame = CGRectMake(self.view.frame.size.width/2 +2,Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
    }
    else if (collectionViewArray.count == 2) {
        
         Cell.dislikeView.hidden = YES;
         Cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width/2 , collectionView.frame.size.height);
         Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2-  Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
         Cell.pollImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width / 2-1 , collectionView.frame.size.height  - Cell.likeUpView.frame.size.height - 1);
         Cell.pollbackImageView.frame =CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width / 2-1 , collectionView.frame.size.height  - Cell.likeUpView.frame.size.height - 1);
         Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2-  Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
        Cell.pollbackImageView.backgroundColor = [UIColor clearColor];

    }
    else if (collectionViewArray.count == 3) {
        
        Cell.dislikeView.hidden = YES;
        Cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width  , collectionView.frame.size.height);
        Cell.likeUpView.frame = CGRectMake(Cell.pollImageView.frame.size.width/2-  Cell.likeUpView.frame.size.width/2, Cell.contentView.frame.origin.y+2, Cell.likeUpView.frame.size.width, Cell.likeUpView.frame.size.height);
        Cell.pollImageView.frame= CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width / 3-1 , collectionView.frame.size.height - Cell.likeUpView.frame.size.height);
        Cell.pollbackImageView.frame = CGRectMake(0, Cell.likeUpView.frame.origin.y +Cell.likeUpView.frame.size.height +2, collectionView.frame.size.width / 3-1 , collectionView.frame.size.height - Cell.likeUpView.frame.size.height);
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
        NSString* likeStatus=[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"like_dislike"];
    
            if([likeStatus isEqualToString:@"1"])
            {
                
                Cell.likeImageView.image=[UIImage imageNamed:@"green_btn.png"] ;
                Cell.likepercentageLabel.textColor = [UIColor whiteColor];
                Cell.dislikeLabel.textColor = [UIColor blackColor];
                
            }
            else if([likeStatus isEqualToString:@""])
            {
                Cell.likeImageView.image=[UIImage imageNamed:@"pop_btn.png"] ;
                Cell.dislikeLabel.textColor = [UIColor blackColor];
                Cell.likepercentageLabel.textColor = [UIColor blackColor];
                if(![self isFirstPost:collectionViewArray])
                {
                   // Cell.pollbackImageView.backgroundColor = [UIColor blackColor];
                   // Cell.pollbackImageView.alpha = 0.6;
                }
                    
            }
    }

    if (collectionViewArray.count==1) {
        Cell.likepercentageLabel.text=[NSString stringWithFormat:@"%@%@",[AlldataArray [[(PollCollectionView *)collectionView indexPath].row]valueForKey:@"likes_percentage"],@"%"];
        
        Cell.dislikeLabel.text=[NSString stringWithFormat:@"%@%@",[AlldataArray[[(PollCollectionView *)collectionView indexPath].row]valueForKey:@"dislikes_percentage"],@"%"];
        
    }
    else
    {
        Cell.likepercentageLabel.text=[NSString stringWithFormat:@"%@%@",[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"media_likes_percentage"],@"%"];
        
        
    }
    if ([[AlldataArray[[(PollCollectionView *)collectionView indexPath].row]valueForKey:@"media_type"] isEqualToString:@"Video"]) {
     
        NSURL *ratingUrl = [NSURL URLWithString:[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"video_thumbnail"]];
        [Cell.pollImageView setImageWithURLRequest:[NSURLRequest requestWithURL:ratingUrl] placeholderImage:[UIImage imageNamed:@"likeWhite.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             Cell.pollImageView.image = image;
             
         }failure:nil];
        
            
    }
    else {
        avPlayerLayer.player = nil;
        [avPlayerLayer removeFromSuperlayer];
        avPlayer = nil;
        [avPlayer pause];
        
        
        NSURL *ratingUrl = [NSURL URLWithString:[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"media_name"]];
        [Cell.pollImageView setImageWithURLRequest:[NSURLRequest requestWithURL:ratingUrl] placeholderImage:[UIImage imageNamed:@"likeWhite.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             Cell.pollImageView.image = image;
             [Cell.pollImageView setContentMode:UIViewContentModeScaleAspectFill];
             [Cell.pollImageView setClipsToBounds:YES];
             
         }failure:nil];
        
    }
     [Cell.pollImageView setUserInteractionEnabled:YES];
    
     return Cell;
    
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
    
    
    CGPoint center= collectionView.center;
    CGPoint rootViewPoint = [collectionView.superview convertPoint:center toView:self.feedTableview];
    NSIndexPath *indexPathfeed = [self.feedTableview indexPathForRowAtPoint:rootViewPoint];
    
    [self.fullListRows addObject:indexPathfeed];
    if ([self.selectedListRows containsObject:indexPath]) {
        [self.selectedListRows removeObject:indexPath];
    }
    if ([self.selectedGridRows containsObject:indexPath]) {
        [self.selectedGridRows removeObject:indexPath];
    }
    
    if ([[AlldataArray[[(PollCollectionView *)collectionView indexPath].row]valueForKey:@"media_type"] isEqualToString:@"Video"]) {
       
        NSArray *collectionViewArray = [AlldataArray[[(PollCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"] ;
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
            [[Utility sharedObject] showMBProgress:self.view message:@""];
            [BagView removeFromSuperview];
            [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [avPlayerLayer setFrame:CGRectMake(0, 27, collectionView.frame.size.width, collectionView.frame.size.height-47)];
            BagView=[[UIView alloc]initWithFrame:CGRectMake(0, 27, collectionView.frame.size.width, collectionView.frame.size.height-47)];
            
            [BagView addGestureRecognizer:doubleTap];
            [BagView. layer addSublayer:avPlayerLayer];
            [collectionView addSubview:BagView];
            
        }else {
            //[[Utility sharedObject] showMBProgress:self.view message:@""];
            [BagView removeFromSuperview];
            
            [avPlayerLayer setFrame:CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height)];
            
            BagView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            BagView.backgroundColor = [UIColor whiteColor];
            [BagView addGestureRecognizer:doubleTap];
            
            [BagView. layer addSublayer:avPlayerLayer];
            [self.view addSubview:BagView];
        }

        [avPlayer seekToTime:kCMTimeZero];
        [avPlayer play];
    }else {
        int x = 0;
        NSArray *collectionViewArray = [AlldataArray[[(PollCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"] ;
        if (collectionViewArray.count==1) {

        }
        else
        {
            pollView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height)];
        }
        pollView.backgroundColor = [UIColor whiteColor];
        
        imageScrollView.pagingEnabled  = YES;
        imageScrollView.showsHorizontalScrollIndicator = NO;
        [imageScrollView setContentSize:CGSizeMake(self.view.frame.size.width* collectionViewArray.count, 0)];
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
        [imageScrollView setContentOffset:CGPointMake(self.view.frame.size.width * indexPath.item, 0) animated:NO];
        [pollView addSubview: imageScrollView];
        if (collectionViewArray.count==1) {
            [collectionView addSubview: pollView];
            
        }
        else {
            [self.view addSubview: pollView];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound) {
        
        [self scrollingFinish];
    }
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [[Utility sharedObject] hideMBProgress];
    }
}
-(void)observeValueForKeyPath:(NSString*)path ofObject:(id)object change:(NSDictionary*)change context:(void*) context {
    
    if([avPlayer status] == AVPlayerStatusReadyToPlay){
        [[Utility sharedObject] hideMBProgress];
    }
}
#pragma mark - UIScrollViewDelegate Methods
- (void)scrollingFinish {
    [pollView setHidden:YES];
   
    [avPlayerLayer.player pause];
    [avPlayer pause];
    [avPlayerLayer removeFromSuperlayer];
    avPlayerLayer.player = nil;
    avPlayer = nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    PollCollectionView *collectionView = (PollCollectionView *)scrollView;
    NSInteger indexx = collectionView.indexPath.row;
    self.contentOffsetDictionary[[@(indexx) stringValue]] = @(horizontalOffset);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[(PollCollectionView *)collectionView layoutCountStr] isEqualToString:@"1"]) {
        return CGSizeMake(collectionView.frame.size.width , collectionView.frame.size.height  );  //1
    }
    if ([[(PollCollectionView *)collectionView layoutCountStr] isEqualToString:@"2"]) {
        return CGSizeMake(collectionView.frame.size.width / 2 , collectionView.frame.size.height );//2
    }
    if ([[(PollCollectionView *)collectionView layoutCountStr] isEqualToString:@"3"])
    {
        return CGSizeMake(collectionView.frame.size.width/3, collectionView.frame.size.height);   //3
    }
    if ([[(PollCollectionView *)collectionView layoutCountStr] isEqualToString:@"4"]) {
        return CGSizeMake(collectionView.frame.size.width / 2  , collectionView.frame.size.height / 2);//4
    }
  
  
    return CGSizeMake(collectionView.frame.size.width , collectionView.frame.size.height);  //1

}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    if ([[(PollCollectionView *)collectionView layoutCountStr] isEqualToString:@"2"]) {
         return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else{
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }

}

#pragma mark - Update poll Timer
- (void)updateCountdown:(NSTimer * )timer1 {
    
    NSIndexPath * cellIndex = timer1.userInfo;
    if(cellIndex.row<AlldataArray.count)
    {
    HomeCellTableViewCell *cell = [self.feedTableview cellForRowAtIndexPath:cellIndex];
    //get date from server
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
  
    NSDate * dateFromString1 = [dateFormatter dateFromString:[[AlldataArray objectAtIndex:cellIndex.row]valueForKey:@"created_date"]];
       
    //add duration in created date
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth |  NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
        NSString * getHourMinuteString =[NSString stringWithFormat:@"%@", [[AlldataArray objectAtIndex:cellIndex.row]valueForKey:@"poll_duration"]];
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
    NSInteger timeUntilEnd = (NSInteger)[[NSDate date] timeIntervalSinceDate:newDate];
        
    if (timeUntilEnd > 0)
    {
        cell.timerLabel.text = @"0:00:00";
    }
    if (timeUntilEnd <= 0)
    {
        NSDateComponents *componentsDaysDiff = [calendar components:unitFlags  fromDate:[NSDate date]   toDate:newDate     options:0];
        NSInteger hours = [componentsDaysDiff hour];
        NSInteger minutes = [componentsDaysDiff minute];
        NSInteger seconds = [componentsDaysDiff second];
        if (hours)
        {
            if (hours>1)
            {
                cell.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
            }
            else
            {
                cell.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
            }
        }
        else
        {
            if (minutes>1)
            {
                cell.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
            }
            else
            {
                cell.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
            }
        }
    }
    }
}
#pragma mark - Grid And Slide View Btn Action

- (IBAction)like_action:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.feedTableview];
    NSIndexPath *indexPath = [self.feedTableview indexPathForRowAtPoint:buttonPosition];
    [[NSUserDefaults standardUserDefaults]setObject:[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"poll_id"] forKey:@"poll_id"];
    
    VotesViewController *votes = [self.storyboard instantiateViewControllerWithIdentifier:@"VotesViewController"];
    [self.navigationController pushViewController:votes animated:NO];
}
-(void)Name_action:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.feedTableview];
    NSIndexPath *indexPath = [self.feedTableview indexPathForRowAtPoint:buttonPosition];
    [[NSUserDefaults standardUserDefaults]setObject:[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"user_id"] forKey:@"clickedUserid"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromHome"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Fromsearch"];

    MyAndCurrentPollViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAndCurrentPollViewController"];
    [self.navigationController pushViewController:ProfileView animated:YES];
    
    
}
-(void)fbShare
{
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        //[fbSheetOBJ setInitialText:@"Hi I want your opinion on this question.Install the app to vote on my polls: https://itunes.apple.com/us/app/pop-the-world/id1200362716?ls=1&mt=8 "];
        [fbSheetOBJ addImage:screenImage];
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
- (UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame {
    
    UIGraphicsBeginImageContextWithOptions(screenImage.size, NO, 0.0);
    [screenImage drawInRect:CGRectMake(0.0, 0.0, screenImage.size.width, screenImage.size.height)];
    [inputImage drawInRect:frame];
    screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}
#pragma mark:ActionSheet
-(void)moreBtnAction:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.feedTableview];
    moreBtnindexPath = [self.feedTableview indexPathForRowAtPoint:buttonPosition];
    screenImage = [self.feedTableview screenshotOfCellAtIndexPath:moreBtnindexPath];
   
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
    
    /*
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Share to Instagram" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self instaGramWallPost];
        
               [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Share to Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self fbShare];
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    */
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
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Invite" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        id branchInviteViewController = [BranchInviteViewController branchInviteViewControllerWithDelegate:self];
        [self presentViewController:branchInviteViewController animated:YES completion:NULL];
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    SelectedPollIdStr=[[AlldataArray objectAtIndex:moreBtnindexPath.row] valueForKey:@"poll_id"];
    selectedUserIdStr=[[AlldataArray objectAtIndex:moreBtnindexPath.row]valueForKey:@"user_id"];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    if ([selectedUserIdStr isEqualToString:userid]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
               [self deletePoll];
            
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }]];

    }
      [self presentViewController:actionSheet animated:YES completion:nil];

}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(void)instaGramWallPost
{

    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {

        NSString* imagePath = [NSString stringWithFormat:@"%@/instagramShare.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];

        [UIImagePNGRepresentation(screenImage) writeToFile:imagePath atomically:YES];
        NSLog(@"Image Size >>> %@", NSStringFromCGSize(screenImage.size));
        
        self.documentController=[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];


        self.documentController.delegate = self;
        self.documentController.UTI = @"com.instagram.exclusivegram";
        self.documentController.annotation = [NSDictionary dictionaryWithObject:@"John wants your opinion on this question on POP." forKey:@"InstagramCaption"];
            
        

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
- (IBAction)CommentBtn_Action:(id)sender {
    
    if (comment_status ==0) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Comment is Off !"
                                      message:@"Please On Comment !"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else {
    
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.feedTableview];
        NSIndexPath *indexPath = [self.feedTableview indexPathForRowAtPoint:buttonPosition];
        [[NSUserDefaults standardUserDefaults]setObject:[[AlldataArray objectAtIndex:indexPath.row] valueForKey:@"poll_id"] forKey:@"poll_id"];
        
        CommentViewController *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
        [self.navigationController pushViewController:comment animated:NO];
    }

}


- (IBAction)dislike_action:(id)sender
{
    UIButton *button = (UIButton *) sender;
    votingtag=button.tag;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.feedTableview];
    votingindexPath = [self.feedTableview indexPathForRowAtPoint:buttonPosition];
    
    
    SelectedPollIdStr=[[AlldataArray objectAtIndex:votingindexPath.row] valueForKey:@"poll_id"];
    selectedUserIdStr=[[AlldataArray objectAtIndex:votingindexPath.row] valueForKey:@"user_id"];
    NSArray *collectionViewArray = [AlldataArray[votingindexPath.row]valueForKey:@"media_files"] ;
    
    NSMutableArray * MediaArray=[[NSMutableArray alloc]init];
    likeStatusArray=[[NSMutableArray alloc]init];
    
    [MediaArray addObject: [[AlldataArray objectAtIndex:votingindexPath.row]valueForKey:@"media_files"]];
    
    NSArray*array=[MediaArray objectAtIndex:0];
    
    
    [likeStatusArray addObject:[array[votingtag] valueForKey:@"like_dislike"]];
    NSString* likeStatus;
    
    likeStatus=likeStatusArray[0];
    likeDislikeStr=@"0";
   
    MediaIdStr=[[collectionViewArray objectAtIndex:votingtag] valueForKey:@"media_id"];
    [self CallLikeDeslikePoll];
 }


- (IBAction)voting_action:(id)sender {
    
    UIButton *button = (UIButton *) sender;
     vote=YES;
    votingtag=button.tag;

    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.feedTableview];
    votingindexPath = [self.feedTableview indexPathForRowAtPoint:buttonPosition];
   
    SelectedPollIdStr=[[AlldataArray objectAtIndex:votingindexPath.row] valueForKey:@"poll_id"];
    selectedUserIdStr=[[AlldataArray objectAtIndex:votingindexPath.row] valueForKey:@"user_id"];
    NSArray *collectionViewArray = [AlldataArray[votingindexPath.row]valueForKey:@"media_files"] ;

    NSMutableArray * MediaArray=[[NSMutableArray alloc]init];
    likeStatusArray=[[NSMutableArray alloc]init];
    
        [MediaArray addObject: [[AlldataArray objectAtIndex:votingindexPath.row]valueForKey:@"media_files"]];
    
    NSArray*array=[MediaArray objectAtIndex:0];
    
    
        [likeStatusArray addObject:[array[votingtag] valueForKey:@"like_dislike"]];
        NSString* likeStatus;
        
        likeStatus=likeStatusArray[0];
        likeDislikeStr=@"1";

    
    MediaIdStr=[[collectionViewArray objectAtIndex:votingtag] valueForKey:@"media_id"];
    [self CallLikeDeslikePoll];
    
    
}
- (IBAction)backBtnAction:(id)sender {
        [self.navigationController popViewControllerAnimated:YES];
    
}
-(IBAction)notification:(id)sender {
    if (notification_status ==0) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Notification is Off !"
                                      message:@"Please On Notification !"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else {
        HomeViewController * notification = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
        [self.navigationController pushViewController:notification animated:NO];
    }
}
-(IBAction)message:(id)sender {
    HomeViewController * message = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
    [self.navigationController pushViewController:message animated:NO];
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//
//    return YES;
//}
-(void)viewWillDisappear:(BOOL)animated
{
    [_feedTableview reloadData];
    [self GetUserProfileInfo];
    [ timer invalidate];
    timer = nil;
}

@end
