//
//  MyAndCurrentPollViewController.m
//  POP
//
//  Created by salentro on 12/30/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import "MyAndCurrentPollViewController.h"
#import "MyPollCellTableViewCell.h"
#import "MyPollCellTableViewCell.h"
#import "PollCollectionViewCell.h"
#import "AFHTTPSessionManager.h"
#import "ProfileViewController.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "DHSmartScreenshot.h"
#import "HomeViewController.h"
#import "FollowersViewController.h"
#import "EditProfileViewController.h"
#import "PollViewController.h"
#import "Utility.h"
#import "ChatViewController.h"
#import "CommentViewController.h"
#import "VotesViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+AFNetworking.h"
#import "BranchInviteViewController.h"
#import "BranchInviteTextContactProvider.h"
#import "BranchInviteEmailContactProvider.h"
#import "BranchActivityItemProvider.h"
#import "BranchSharing.h"
#import "UIViewController+BranchShare.h"
#import "BranchReferralController.h"
#import "CurrentUserModel.h"

@interface MyAndCurrentPollViewController ()

{
    UIImage *screenImage;
    NSIndexPath *moreBtnindexPath;
    NSMutableArray *ActivePollArray ;
    BOOL slideViewBool;
    UICollectionView * mypollCollectionVW ;
    NSTimer *timer;
    NSString *follow_approval;
    PollCollectionViewCell *Cell; NSString*SelectedPollIdStr;
    UIRefreshControl*  refreshControl;
    NSMutableArray *WinningPollArray;BOOL follow;
    NSString *followStatus, *inviteName;
    NSUInteger privacyStatus;
    UIView * pollView; AVPlayer*  avPlayer ;  AVPlayerLayer*   avPlayerLayer;
    UIView*BagView;
    UIScrollView * imageScrollView;
    

}
@property (strong,nonatomic) NSMutableSet *selectedGridRows, *selectedListRows;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@end

@implementation MyAndCurrentPollViewController
@synthesize pollTypeStr;

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
             [BranchInviteTextContactProvider textContactProviderWithInviteMessageFormat:[NSString stringWithFormat:@"Hi,\n\n Download POP and follow me so you\n can vote on my photos and videos.\n My user name is %@,\n\n Here's the link: https://itunes.apple.com/", inviteName]],
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
#pragma mark-DeletePoll
-(void)deletePoll
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary * params = @{@"poll_id":SelectedPollIdStr};
    
    [manager POST:@"delete_poll_post" parameters:params progress:^(NSProgress * _Nonnull uploadProgress){
         
     }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             if ([pollTypeStr isEqualToString: @"CallGetActivePoll"]) {
                 //[self CallGetActivePoll];
                 [self CallGetWinningPolls];
                 [self CallGetMyPoll];
              } else {
                 [self CallGetCurrentlyVoting];
              }
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePoll" object:self];
         }
         else{
             
         }
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
     }];
    
}

-(void)CallGetWinningPolls
{
    //[[Utility sharedObject] showMBProgress:self.view message:@""];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid;
    NSString*  clickedUserid;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"])
    {
        clickedUserid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
        userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
    }
    else if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromSearch"])
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
             
             ActivePollArray=[[responseObject valueForKey:@"data"] valueForKey:@"result"];
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
                 [_pollsTableView reloadData];
             }
             else
             {
                 
                 if ([[[responseObject valueForKey:@"data"] valueForKey:@"follow_approval"] isEqualToString:@"1"]&&[[[WinningPollArray objectAtIndex:0] valueForKey:@"privacy_status"] isEqualToString:@"0"]) {
                     [_pollsTableView reloadData];
                 }
                 else if ([[[responseObject valueForKey:@"data"] valueForKey:@"follow_approval"] isEqualToString:@"1"]&&[[[WinningPollArray objectAtIndex:0] valueForKey:@"privacy_status"] isEqualToString:@"1"]) {
                     [_pollsTableView reloadData];
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
              [_pollsTableView reloadData];
             
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
                     [ActivePollArray removeAllObjects];
                     [_pollsTableView reloadData];
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
             [_pollsTableView reloadData];
         }
         else
         {
             
             
         }
         
     }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
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

    NSLog(@"_______$$$$$$_________ user_id:  %@", userid);
    NSDictionary * params = @{@"user_id":userid};

    [manager POST:@"get_user_profile" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {

     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             inviteName = [[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"];

             NSNumber*followersCount=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"followers_count"];
             _followersLbl.text=[NSString stringWithFormat:@"%@",followersCount];
             _followersLbl.frame = CGRectMake(_followerBtn.frame.origin.x, _followerBtn.frame.origin.y - _followersLbl.frame.size.height, _followersLbl.frame.size.width, _followersLbl.frame.size.height);
             NSNumber*followingsCount=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"following_count"];
             _webLabel.text = [[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"website"];
             [_webLabel setTextAlignment:NSTextAlignmentCenter];
             [_webLabel setTextColor:[UIColor whiteColor]];
             [_webLabel setTintColor:[UIColor whiteColor]];

             privacyStatus=[[[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"privacy_status"] integerValue];
             [_webLabel setEditable:NO];
             [_webLabel setScrollEnabled:NO];

             [_webLabel setDataDetectorTypes:UIDataDetectorTypeLink];
             _webLabel.userInteractionEnabled = YES;
             _followingsLbl.text=[NSString stringWithFormat:@"%@",followingsCount];
             _followingsLbl.frame = CGRectMake(_followingBtn.frame.origin.x, _followingBtn.frame.origin.y - _followingsLbl.frame.size.height, _followingsLbl.frame.size.width, _followingsLbl.frame.size.height);

             NSString*profileimg=[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"profile_pic"];

             NSURL *imageURL = [NSURL URLWithString:profileimg];

             [[NSUserDefaults standardUserDefaults]
              setObject:[imageURL absoluteString] forKey:@"imageURL"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"] forKey:@"user_name"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"email"] forKey:@"email"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"website"] forKey:@"website"];
//             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_url"] forKey:@"user_url"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"description"] forKey:@"description"];


             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"password"] forKey:@"password"];
             [self CallGetWinningPolls];
             [self CallGetMyPoll];
         }
         else
         {

         }


     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
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
             
             [ActivePollArray removeAllObjects];
             ActivePollArray =[[[responseObject objectForKey:@"data"]valueForKey:@"result"] mutableCopy];
             [_pollsTableView reloadData];
         }
         else {
             [ActivePollArray removeAllObjects];
             [_pollsTableView reloadData];
         }
         
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }];
}

-(void)CallGetMyPoll
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString*userid;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"]) {
        userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
    }
    else {
        userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    }

    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_user_profile" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             
             [_imageScrollView reloadInputViews];
             _userNameLbl.text = [[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"];
             _userImgView.imageURL = [NSURL URLWithString:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"profile_pic"]];
             _userImgView.layer.cornerRadius = _userImgView.frame.size.width / 2;
             _userImgView.layer.borderWidth = 1.5;
             _userImgView.layer.borderColor = [UIColor orangeColor].CGColor;
             _userImgView.clipsToBounds = YES;
             _userImageButton.frame = CGRectMake(_userImgView.frame.origin.x, _userImgView.frame.origin.y, _userImgView.frame.size.width, _userImgView.frame.size.height);
             _urlLbl.frame = CGRectMake(_pollsTableView.frame.size.width/2 - _urlLbl.frame.size.width/2, _userImgView.frame.origin.y + _userImgView.frame.size.height, _urlLbl.frame.size.width, _urlLbl.frame.size.height);
         }
         else {
             
         }
        
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

     }];
}
- (void)refresh: (id)sender
{
    [self CallGetWinningPolls];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_pollsTableView  addSubview:refreshControl];
    
    ActivePollArray=[[NSMutableArray alloc]init];
    [self.navigationController setNavigationBarHidden:NO];
    
    pollTypeStr=@"CallGetActivePoll";
    [[NSUserDefaults standardUserDefaults]setObject:@"CallGetActivePoll" forKey:@"pollTypeStr"];
    if (privacyStatus ==1) {
        
    }else {
       
       // [self CallGetWinningPolls];
        [self CallGetMyPoll];
    }
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.selectedGridRows=[NSMutableSet new];
    self.selectedListRows=[NSMutableSet new];
    //[self CallGetMyPoll];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)makeRoot:(NSNotification *)notification {
    if ([pollTypeStr isEqualToString: @"CallGetActivePoll"]) {
       
       // [self CallGetWinningPolls];
        [self CallGetMyPoll];
    }
    else {
        [self CallGetCurrentlyVoting];
    }
}
-(void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeRoot:) name:@"callpoll" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"__________________ view did appear ___________________________");
    [self GetUserProfileInfo];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(ActivePollArray.count>0)
    return ActivePollArray.count;
    else
        return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellidentifier = @"cellId";
    MyPollCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    cell.viewController = self;
    NSArray *collectionViewArray = [ActivePollArray[indexPath.row]valueForKey:@"media_files"] ;
    CALayer *bottomBorder1;
    if (collectionViewArray.count ==1) {
        [cell.bottomLbl setHidden:YES];
        cell.activePollCollectionView.frame = CGRectMake(0, cell.contentView.frame.origin.y +10 , cell.contentView.frame.size.width, self.view.frame.size.width + 30+25);
        
    } if (collectionViewArray.count==2) {
        [cell.bottomLbl setHidden:YES];
        [bottomBorder1 setHidden:YES];
        cell.activePollCollectionView.frame = CGRectMake(0, cell.contentView.frame.origin.y +10, cell.contentView.frame.size.width, (self.view.frame.size.width + 30)/2 +50);
        
    }if (collectionViewArray.count ==3){
        [cell.bottomLbl setHidden:YES];
        [bottomBorder1 setHidden:YES];
        cell.activePollCollectionView.frame = CGRectMake(0,  cell.contentView.frame.origin.y +10, cell.contentView.frame.size.width, (self.view.frame.size.width + 30)/2 -30);
        
    }if (collectionViewArray.count ==4) {
        [cell.bottomLbl setHidden:YES];
        cell.activePollCollectionView.frame = CGRectMake(0, cell.contentView.frame.origin.y +10, cell.contentView.frame.size.width, self.view.frame.size.width + 30*2 +50);
    }
    
    if ([[ActivePollArray [indexPath.row] valueForKey:@"question"] isEqualToString:@""]) {
        [cell.aboutPoll setHidden:YES];
    }else {
        [cell.aboutPoll setHidden:NO];
    }

    cell.pollDescLable.frame = CGRectMake(40, cell.activePollCollectionView.frame.origin.y +cell.activePollCollectionView.frame.size.height +10, cell.contentView.frame.size.width - 80, cell.pollDescLable.frame.size.height);
    cell.timerLabel.frame = CGRectMake(cell.timerLabel.frame.origin.x, cell.activePollCollectionView.frame.origin.y +cell.activePollCollectionView.frame.size.height +10 + cell.pollDescLable.frame.size.height, cell.timerLabel.frame.size.width, cell.timerLabel.frame.size.height);
    cell.aboutPoll.frame = CGRectMake(15, cell.timerLabel.frame.origin.y + cell.timerLabel.frame.size.height + 8, cell.activePollCollectionView.frame.size.width - 30, ((NSString*)[[Utility getHeightOfText:[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"question"] fontSize:14 width:self.view.frame.size.width] valueForKey:@"height"]).floatValue +25);
    
    cell.aboutPoll.text =[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"question"];
    cell.sepratorView.frame = CGRectMake(0, cell.frame.size.height-44, cell.frame.size.width, 40);

    [cell.moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[ActivePollArray [indexPath.row] valueForKey:@"poll_duration"] isEqualToString:@"0"]||[[ActivePollArray [indexPath.row] valueForKey:@"poll_duration"] isEqualToString:@"0"]) {
        [cell.timerLabel setHidden:YES];
    }
    else {
        [cell.timerLabel setHidden:NO];
        
        cell.timerLabel.frame = CGRectMake(cell.timerLabel.frame.origin.x, cell.activePollCollectionView.frame.origin.y +cell.activePollCollectionView.frame.size.height +10 + cell.pollDescLable.frame.size.height, cell.timerLabel.frame.size.width, cell.timerLabel.frame.size.height);
    }
    cell.IMageView.frame = CGRectMake(0, cell.activePollCollectionView.frame.origin.y +cell.activePollCollectionView.frame.size.height +5, cell.IMageView.frame.size.width, cell.IMageView.frame.size.height);
    if ([[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"media_type"] isEqualToString:@"Video"]) {
        
        [cell. IMageView setHidden:NO];
    }
    else
    {
        [cell. IMageView setHidden:YES];
    }

    cell.sepratorView.frame = CGRectMake(0, cell.frame.size.height-44, cell.frame.size.width, 40);

    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    bottomBorder.frame = CGRectMake(0, cell.sepratorView.frame.size.height - 2, cell.contentView.frame.size.width, 2);
    [cell.sepratorView.layer addSublayer:bottomBorder];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    topBorder.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, 2);
    [cell.sepratorView.layer addSublayer:topBorder];
    
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath  imageArray:ActivePollArray layoutChangeStr:[[ActivePollArray objectAtIndex:indexPath.row]valueForKey:@"media_count"] gridAndListType:GRIDVIEW];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * dateFromString1 = [dateFormatter dateFromString:[[ActivePollArray objectAtIndex:indexPath.row]valueForKey:@"created_date"]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSString * getHourMinuteString =[NSString stringWithFormat:@"%@", [[ActivePollArray objectAtIndex:indexPath.row]valueForKey:@"poll_duration"]];
    if ([getHourMinuteString rangeOfString:@"MIN" options:NSRegularExpressionSearch].location != NSNotFound) {
        getHourMinuteString = [getHourMinuteString stringByReplacingOccurrencesOfString:@"MIN" withString:@""];
        [components setMinute:[getHourMinuteString integerValue]];
    }
    else {
        getHourMinuteString = [getHourMinuteString stringByReplacingOccurrencesOfString:@"HR" withString:@""];
        [components setHour:[getHourMinuteString integerValue]];
    }

    NSDate *newDate= [calendar dateByAddingComponents:components toDate:dateFromString1 options:0];
    
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [localDateFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
   
    cell.dateShow.text  = [NSString stringWithFormat:@"Popped on %@", [localDateFormatter stringFromDate:newDate]];
    cell.pollDescLable.text=[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"poll_description"];
    cell.aboutPoll.text =[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"question"];

    cell.commentLbl.text=[NSString stringWithFormat:@"%@ Comments",[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"comment_count"]];
    if ( [cell.commentLbl.text isEqualToString:@"1 Comments"]) {
        cell.commentLbl.text=[NSString stringWithFormat:@"%@ Comment",[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"comment_count"]];
    }
    cell.voteLbl.text=[NSString stringWithFormat:@"%@ Votes",[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"total_votes_count"]];
    
    if ( [cell.voteLbl.text isEqualToString:@"1 Votes"]) {
        cell.voteLbl.text=[NSString stringWithFormat:@"%@ Vote",[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"total_votes_count"]];
    }
    
    if (ActivePollArray.count>0) {
        timer =  [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateCountdown:) userInfo:indexPath repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer: timer forMode:NSRunLoopCommonModes];
    }
    
    if ([[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"media_type"] isEqualToString:@"Video"]) {
        [cell. IMageView setHidden:NO];
    }
    else {
        [cell. IMageView setHidden:YES];
    }

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    float desc_hight = ((NSString*)[[Utility getHeightOfText:[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"question"] fontSize:14 width:self.view.frame.size.width] valueForKey:@"height"]).floatValue;
    
    NSString *about_text =[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"question"];
    NSString *desc_text =[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"poll_description"];
    NSString *timer_text = [[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"poll_duration"];

    NSArray *collectionViewArray = [ActivePollArray[indexPath.row]valueForKey:@"media_files"] ;
    if (collectionViewArray.count == 1) {
        if (IS_IPHONE_5) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+300 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+320 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+320 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+340 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
            }
            
        }else  if (IS_IPHONE_6 || IS_IPHONE_7 || IS_IPHONE_8 || IS_IPHONE_X || IS_IPHONE_SE) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+300 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+320 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+320 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+340 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+365 + desc_hight;
            }
            
        }else if (IS_IPHONE_6_PLUS || IS_IPHONE_7_PLUS || IS_IPHONE_8_PLUS){
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+330 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+350 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+350 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+395 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+370 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+395 + desc_hight;
            }
        }else {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+340 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+360 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+360 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+405 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+380 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+405 + desc_hight;
            }
        }
    }if (collectionViewArray.count == 2) {
        if (IS_IPHONE_5) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+145 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+165 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+165 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+210 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+185 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+210 + desc_hight;
            }
            
        }else  if (IS_IPHONE_6 || IS_IPHONE_7 || IS_IPHONE_8 || IS_IPHONE_X || IS_IPHONE_SE) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+145 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+165 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+165 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+210 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+185 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+210 + desc_hight;
            }
            
        }else if (IS_IPHONE_6_PLUS || IS_IPHONE_7_PLUS || IS_IPHONE_8_PLUS) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+125 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+145 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+145 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+190 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+165 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+190 + desc_hight;
            }
        } else {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+185 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+205 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+205 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+250 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+225 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+250 + desc_hight;
            }
        }
    }if (collectionViewArray.count == 3) {
        if (IS_IPHONE_5) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+90 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+110+ desc_hight;
            }            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+110+ desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+155 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+130+ desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+155 + desc_hight;
            }
            
        }else  if (IS_IPHONE_6 || IS_IPHONE_7 || IS_IPHONE_8 || IS_IPHONE_X || IS_IPHONE_SE) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+65 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+85 + desc_hight;
            }            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+85+ desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+130 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+105+ desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+130 + desc_hight;
            }
            
        }else if (IS_IPHONE_6_PLUS || IS_IPHONE_7_PLUS || IS_IPHONE_8_PLUS) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+50 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+70 + desc_hight;
            }            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+70 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+115 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+90 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+115 + desc_hight;
            }
        } else {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+105 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+125 + desc_hight;
            }            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+125+ desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+170 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+145+ desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+170 + desc_hight;
            }
        }
    }if (collectionViewArray.count ==4) {
        if (IS_IPHONE_5) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+380 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+400 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+400 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+440 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+415 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+440 + desc_hight;
            }
            
        }else  if (IS_IPHONE_6 || IS_IPHONE_7 || IS_IPHONE_8 || IS_IPHONE_X || IS_IPHONE_SE) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+380 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+400 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+400 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+440 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+415 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+440 + desc_hight;
            }
            
        }else if (IS_IPHONE_6_PLUS || IS_IPHONE_7_PLUS || IS_IPHONE_8_PLUS) {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+390 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+410 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+410 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+450 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+425 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+450 + desc_hight;
            }
        }else {
            if (desc_text.length == 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+420 + desc_hight;
            }
            else if (desc_text.length == 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+440 + desc_hight;
            }
            else if (desc_text.length != 0 && [timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+440 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length != 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+480 + desc_hight;
            }
            else if (desc_text.length != 0 && ![timer_text isEqualToString:@"0"] && about_text.length == 0 ) {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+455 + desc_hight;
            }else {
                return (self.view.frame.size.height-165-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-[[UIApplication sharedApplication] statusBarFrame].size.height)/2+480 + desc_hight;
            }
        }
    }
    
    return 0;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionView * collectionView1 = (UICollectionView *)collectionView;
    NSArray *collectionViewArray = [ActivePollArray[collectionView1.tag]valueForKey:@"media_files"] ;
    if (collectionViewArray.count == 1) {
        return CGSizeMake(collectionView.frame.size.width , collectionView.frame.size.height  );  //1
    }
    else if (collectionViewArray.count == 2) {
        return CGSizeMake(collectionView.frame.size.width / 2 , collectionView.frame.size.height );//2
    }
    else if(collectionViewArray.count == 3) {
        return CGSizeMake(collectionView.frame.size.width/3, collectionView.frame.size.height);      //3
    }
    else if(collectionViewArray.count == 4) {
        return CGSizeMake(collectionView.frame.size.width / 2  , collectionView.frame.size.height / 2);//4
    }
    else {
        return CGSizeMake(collectionView.frame.size.width  , collectionView.frame.size.height );
    }
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //[[Utility sharedObject] hideMBProgress];
    }
}
- (void)updateCountdown:(NSTimer * )timer1 {
    
    NSIndexPath * cellIndex = timer1.userInfo;
    if(cellIndex.row<ActivePollArray.count) {
        MyPollCellTableViewCell *cell = [self.pollsTableView cellForRowAtIndexPath:cellIndex];
            
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * dateFromString1 = [dateFormatter dateFromString:[[ActivePollArray objectAtIndex:cellIndex.row]valueForKey:@"created_date"]];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth |  NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *components = [[NSDateComponents alloc] init];
        NSString * getHourMinuteString =[NSString stringWithFormat:@"%@", [[ActivePollArray objectAtIndex:cellIndex.row]valueForKey:@"poll_duration"]];
        if ([getHourMinuteString rangeOfString:@"MIN" options:NSRegularExpressionSearch].location != NSNotFound) {
            getHourMinuteString = [getHourMinuteString stringByReplacingOccurrencesOfString:@"MIN" withString:@""];
            [components setMinute:[getHourMinuteString integerValue]];
        }
        else {
            getHourMinuteString = [getHourMinuteString stringByReplacingOccurrencesOfString:@"HR" withString:@""];
            [components setHour:[getHourMinuteString integerValue]];
        }
            
        NSDate *newDate= [calendar dateByAddingComponents:components toDate:dateFromString1 options:0];
        NSInteger timeUntilEnd = (NSInteger)[[NSDate date] timeIntervalSinceDate:newDate];
        if (timeUntilEnd > 0) {
            cell.timerLabel.text = @"0:00:00";
        }
        if (timeUntilEnd <= 0) {
            
            NSDateComponents *componentsDaysDiff = [calendar components:unitFlags  fromDate:[NSDate date]   toDate:newDate     options:0];
            NSInteger hours = [componentsDaysDiff hour];
            NSInteger minutes = [componentsDaysDiff minute];
            NSInteger seconds = [componentsDaysDiff second];
            if (hours) {
                if (hours>1) {
                    cell.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
                }
                else {
                    cell.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
                }
            }
            else {
                if (minutes>1) {
                    cell.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
                }
                else {
                    cell.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
                }
            }
        }
    }
}
#pragma mark - Collection View Delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   
    UICollectionView * collectionView1 = (UICollectionView *)collectionView;
    NSArray *collectionViewArray = [ActivePollArray[collectionView1.tag]valueForKey:@"media_files"] ;
    if(collectionViewArray.count>0)
    return [collectionViewArray count];
    else
        return 0;
}

-(void)VideoDoubleTap:(UITapGestureRecognizer *)UITapGestureRecognizer
{
    [BagView removeFromSuperview];
    [self scrollingFinish];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
        HomeViewController * homeVw = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewId"];
        homeVw.viewString = HOME_VIEW;
        homeVw.indexPath = indexPath;
        homeVw.FollowerDic =  [ActivePollArray objectAtIndex:collectionView.tag] ;
        [self.navigationController pushViewController:homeVw animated:NO];
    
   
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    UICollectionView * collectionView1 = (UICollectionView *)collectionView;
    NSArray *collectionViewArray = [ActivePollArray[collectionView1.tag]valueForKey:@"media_files"] ;
    if (collectionViewArray.count == 2) {
         return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else{
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

-(void)instaGramWallPost {
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSString* imagePath = [NSString stringWithFormat:@"%@/instagramShare.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        
        NSArray *collectionViewArray = [ActivePollArray[moreBtnindexPath.row]valueForKey:@"media_files"] ;
        
        Cell.pollImageView.imageURL =[NSURL URLWithString:[[collectionViewArray objectAtIndex:moreBtnindexPath.item]valueForKey:@"media_name"]];
        [UIImagePNGRepresentation(screenImage) writeToFile:imagePath atomically:YES];
        NSLog(@"Image Size >>> %@", NSStringFromCGSize(screenImage.size));
        
        self.documentController=[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
        self.documentController.delegate = self;
        self.documentController.UTI = @"com.instagram.exclusivegram";
        [self.documentController presentOpenInMenuFromRect: self.view.frame inView:self.view animated:YES ];
    }
    else {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Instagram not installed!"
                                      message:@"Instagram integration is not available. A Instagram account must be set up on your device."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
    
    }
}

-(void)fbShare {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *fbSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [fbSheetOBJ setInitialText:@"Check out pop App"];
        [fbSheetOBJ addImage:screenImage];
        
        [fbSheetOBJ setInitialText:@"pop App"];
        [self presentViewController:fbSheetOBJ animated:YES completion:Nil];
        
    }
    else {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Facebook not installed!"
                                      message:@"Facebook integration is not available.  A Facebook account must be set up on your device."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)TwitterShare {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Hi I want your opinion on this question.Install the app to vote on my polls: https://itunes.apple.com/us/app/pop-the-world/id1200362716?ls=1&mt=8 "];
        
        [tweetSheet addImage:screenImage];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
    }
    else {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Twitter not installed!"
                                      message:@"Twitter integration is not available. A Twitter account must be set up on your device."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
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
-(void)moreBtnAction:(UIButton *)sender {

    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.pollsTableView];
    moreBtnindexPath = [self.pollsTableView indexPathForRowAtPoint:buttonPosition];
    screenImage = [self.pollsTableView screenshotOfCellAtIndexPath:moreBtnindexPath];
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
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:nil];
        
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
    
        NSString*  selectedUserIdStr=[[ActivePollArray objectAtIndex:moreBtnindexPath.row]valueForKey:@"user_id"];
        NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
        if ([selectedUserIdStr isEqualToString:userid]) {

            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                SelectedPollIdStr=[[ActivePollArray objectAtIndex:moreBtnindexPath.row] valueForKey:@"poll_id"];
                
                [self deletePoll];
                
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }]];
        }
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Invite" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        id branchInviteViewController = [BranchInviteViewController branchInviteViewControllerWithDelegate:self];
        [self presentViewController:branchInviteViewController animated:YES completion:NULL];
        
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
}


- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    NSLog(@"file url %@",fileURL);
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
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

- (IBAction)like_action:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.pollsTableView];
    NSIndexPath *indexPath = [self.pollsTableView indexPathForRowAtPoint:buttonPosition];
    [[NSUserDefaults standardUserDefaults]setObject:[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"poll_id"] forKey:@"poll_id"];
    
    VotesViewController *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"VotesViewController"];
    [self.navigationController pushViewController:comment animated:NO];
}

- (IBAction)CommentBtn_Action:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.pollsTableView];
    NSIndexPath *indexPath = [self.pollsTableView indexPathForRowAtPoint:buttonPosition];
    [[NSUserDefaults standardUserDefaults]setObject:[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"poll_id"] forKey:@"poll_id"];
    
    CommentViewController *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    [self.navigationController pushViewController:comment animated:NO];
    
}
- (IBAction)FollowAction:(id)sender
{
    [self CallGetWinningPolls];
    follow=YES;
    
}
- (IBAction)Chat_action:(id)sender
{
    NSString*reciever_id= [[NSUserDefaults standardUserDefaults ]valueForKey:@"clickedUserid"];
    [[NSUserDefaults standardUserDefaults]setObject:reciever_id forKey:@"reciever_id"];
    
    ChatViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    [self.navigationController pushViewController:ProfileView animated:YES];
}

#pragma mark - Events
- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)viewWillDisappear:(BOOL)animated
{
      [ timer invalidate];
      timer = nil;
}
- (IBAction)userImageButton:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.pollsTableView];
    NSIndexPath *indexPath = [self.pollsTableView indexPathForRowAtPoint:buttonPosition];
    if (ActivePollArray.count ==0) {

    }else {
        [[NSUserDefaults standardUserDefaults]setObject:[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"user_id"] forKey:@"clickedUserid"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromHome"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Fromsearch"];
    }
    
    PollViewController * poll = [self.storyboard instantiateViewControllerWithIdentifier:@"PollViewController"];
    [self.navigationController pushViewController:poll animated:NO];
}
@end
