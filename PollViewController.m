//
//  PollViewController.m
//  POP
//
//  Created by KingTon on 9/2/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "PollViewController.h"
#import "AndPollCellTableViewCell.h"
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
#import "Utility.h"
#import "VotesViewController.h"
#import "CommentViewController.h"

@interface PollViewController ()
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
    NSString *followStatus;
    NSUInteger privacyStatus;
}
@property (strong,nonatomic) NSMutableSet *selectedGridRows, *selectedListRows;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@end

@implementation PollViewController
@synthesize pollTypeStr;

#pragma mark-DeletePoll
-(void)deletePoll {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"poll_id":SelectedPollIdStr};
    [manager POST:@"delete_poll_post" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             if ([pollTypeStr isEqualToString: @"CallGetActivePoll"]) {
                 [self CallGetActivePoll];
             }
             else {
                 [self CallGetCurrentlyVoting];
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePoll" object:self];
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
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
     }];
}
-(void)GetUserProfileInfo {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"]) {
        userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
    }
    else {
        userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    }
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid};
    [manager POST:@"get_user_profile" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             privacyStatus=[[[[responseObject valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"privacy_status"] integerValue];
             NSString*profileimg=[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"profile_pic"];
             NSURL *imageURL = [NSURL URLWithString:profileimg];
             [[NSUserDefaults standardUserDefaults]
             setObject:[imageURL absoluteString] forKey:@"imageURL"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"] forKey:@"user_name"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"email"] forKey:@"email"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"website"] forKey:@"website"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"description"] forKey:@"description"];
             [[NSUserDefaults standardUserDefaults]setObject:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"password"] forKey:@"password"];
         }
         else {
             UIAlertController * alert=   [UIAlertController
                                           alertControllerWithTitle:@"Error!"
                                           message:@"Please try again later"
                                           preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
             }];
             [alert addAction:payAction];
             [self presentViewController:alert animated:YES completion:nil];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
     }];
}
-(void)CallGetCurrentlyVoting {
    //[[Utility sharedObject] showMBProgress:self.view message:@""];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid;
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"]) {
        userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
    }
    else {
        userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    }
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid};
    [manager POST:@"get_all_current_votes_activities" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
     }];
}
-(void)CallGetActivePoll {
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
    [manager POST:@"get_all_current_votes_activities" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         [refreshControl endRefreshing];
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             ActivePollArray =[[[responseObject objectForKey:@"data"]valueForKey:@"result"] mutableCopy];
             [_pollsTableView reloadData];
         }
         else {
             [ActivePollArray removeAllObjects];
             [_pollsTableView reloadData];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
     }];
}
-(void)CallGetMyPoll {
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
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             _userNameLbl.text = [[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"];
             _userImgView.imageURL = [NSURL URLWithString:[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"profile_pic"]];
             _userImgView.layer.cornerRadius = _userImgView.frame.size.width/2 +2;
             _userImgView.layer.borderWidth = 1.5;
             _userImgView.layer.borderColor = [UIColor orangeColor].CGColor;
             _userImgView.clipsToBounds = YES;
             [_moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
         }
         else {
             UIAlertController * alert=   [UIAlertController
                                           alertControllerWithTitle:@"Error!"
                                           message:@"Please try again later"
                                           preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
             }];
             [alert addAction:payAction];
             [self presentViewController:alert animated:YES completion:nil];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
     }];
}
- (void)refresh:(id)sender {
    if ([pollTypeStr isEqualToString: @"CallGetActivePoll"]) {
        [self CallGetActivePoll];
    }
    else {
        [self CallGetCurrentlyVoting];
    }
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
    [self CallGetActivePoll];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.selectedGridRows=[NSMutableSet new];
    self.selectedListRows=[NSMutableSet new];
    [self CallGetMyPoll];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)makeRoot:(NSNotification *)notification {
    if ([pollTypeStr isEqualToString: @"CallGetActivePoll"]) {
        [self CallGetActivePoll];
    }
    else {
        [self CallGetCurrentlyVoting];
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [self refresh:pollTypeStr];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeRoot:) name:@"callpoll" object:nil];
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
    AndPollCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    cell.viewController = self;
    NSArray *collectionViewArray = [ActivePollArray[indexPath.row]valueForKey:@"media_files"] ;
    CALayer *bottomBorder1;
    if (collectionViewArray.count ==1) {
        cell.activePollCollectionView.frame = CGRectMake(0, cell.contentView.frame.origin.y +10 , cell.contentView.frame.size.width, self.view.frame.size.width + 55);
    } if (collectionViewArray.count==2) {
        cell.activePollCollectionView.frame = CGRectMake(0, cell.contentView.frame.origin.y +10, cell.contentView.frame.size.width, (self.view.frame.size.width + 30)/2 +50);
    }if (collectionViewArray.count ==3){
        [bottomBorder1 setHidden:YES];
        cell.activePollCollectionView.frame = CGRectMake(0,  cell.contentView.frame.origin.y +10, cell.contentView.frame.size.width, (self.view.frame.size.width + 30)/2 -30);
    }if (collectionViewArray.count ==4) {
        cell.activePollCollectionView.frame = CGRectMake(0, cell.contentView.frame.origin.y +10, cell.contentView.frame.size.width, self.view.frame.size.width + 30*2 +40);
    }
    if ([[ActivePollArray [indexPath.row] valueForKey:@"question"] isEqualToString:@""]) {
        [cell.aboutPoll setHidden:YES];
    }else {
        [cell.aboutPoll setHidden:NO];
    }
    cell.pollDescLable.frame = CGRectMake(40, cell.activePollCollectionView.frame.origin.y +cell.activePollCollectionView.frame.size.height +10, cell.contentView.frame.size.width - 80, cell.pollDescLable.frame.size.height);
    cell.timerLabel.frame = CGRectMake(cell.timerLabel.frame.origin.x, cell.activePollCollectionView.frame.origin.y +cell.activePollCollectionView.frame.size.height +10 + cell.pollDescLable.frame.size.height, cell.timerLabel.frame.size.width, cell.timerLabel.frame.size.height);
    cell.aboutPoll.frame = CGRectMake(15, cell.timerLabel.frame.origin.y + cell.timerLabel.frame.size.height + 8, cell.activePollCollectionView.frame.size.width - 30,((NSString*)[[Utility getHeightOfText:[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"question"] fontSize:14 width:self.view.frame.size.width] valueForKey:@"height"]).floatValue +25);
    cell.aboutPoll.text =[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"question"];
    cell.sepratorView.frame = CGRectMake(0, cell.frame.size.height-44, cell.frame.size.width, 40);
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
    else {
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
    
    if(cellIndex.row<ActivePollArray.count)
    {
        AndPollCellTableViewCell *cell = [self.pollsTableView cellForRowAtIndexPath:cellIndex];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * dateFromString1 = [dateFormatter dateFromString:[[ActivePollArray objectAtIndex:cellIndex.row]valueForKey:@"created_date"]];
        
        //add duration in created date
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth |  NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *components = [[NSDateComponents alloc] init];
        NSString * getHourMinuteString =[NSString stringWithFormat:@"%@", [[ActivePollArray objectAtIndex:cellIndex.row]valueForKey:@"poll_duration"]];
        if ([getHourMinuteString rangeOfString:@"MIN" options:NSRegularExpressionSearch].location != NSNotFound)
        {
            getHourMinuteString = [getHourMinuteString stringByReplacingOccurrencesOfString:@"MIN" withString:@""];
            [components setMinute:[getHourMinuteString integerValue]];
        }
        else
        {
            getHourMinuteString = [getHourMinuteString stringByReplacingOccurrencesOfString:@"HR" withString:@""];
            [components setHour:[getHourMinuteString integerValue]];
        }

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
#pragma mark - Collection View Delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    UICollectionView * collectionView1 = (UICollectionView *)collectionView;
    NSArray *collectionViewArray = [ActivePollArray[collectionView1.tag]valueForKey:@"media_files"] ;
    if(collectionViewArray.count>0)
        return [collectionViewArray count];
    else
        return 0;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UICollectionView * collectionView1 = (UICollectionView *)collectionView;
    NSArray *collectionViewArray = [ActivePollArray[collectionView1.tag]valueForKey:@"media_files"] ;
    AsyncImageView * imgeView = [[AsyncImageView alloc]initWithFrame:cell.frame];
    [cell.contentView addSubview:imgeView];
    
    if (collectionViewArray.count == 1) {
        
        cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.width );
        imgeView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.width );
        
        
    }
    else if (collectionViewArray.count == 2) {
        cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.width/2 );
        imgeView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.width/2 );
    }
    else if (collectionViewArray.count == 3) {
        if(indexPath.row == 1 || indexPath.row ==2)
        {
            cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.height/2);
            imgeView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.height/2);
            
        }
        else
        {
            cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width  , collectionView.frame.size.height/2);
            imgeView.frame= CGRectMake(collectionView.frame.size.width /4, 0, collectionView.frame.size.width /2 , collectionView.frame.size.height/2);
        }
    }
    else  {
        cell.contentView.frame= CGRectMake(0, 0,collectionView.frame.size.width / 2, collectionView.frame.size.height / 2);
        imgeView.frame= CGRectMake(0, 0,collectionView.frame.size.width / 2, collectionView.frame.size.height / 2);
    }
    
    
    imgeView.imageURL = [NSURL URLWithString:[collectionViewArray[indexPath.item]valueForKey:@"media_name"]];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeViewController * homeVw = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewId"];
    homeVw.viewString = HOME_VIEW;
    homeVw.indexPath = indexPath;
    homeVw.FollowerDic =  [ActivePollArray objectAtIndex:collectionView.tag] ;
    [self.navigationController pushViewController:homeVw animated:NO];
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UICollectionView * collectionView1 = (UICollectionView *)collectionView;
    NSArray *collectionViewArray = [ActivePollArray[collectionView1.tag]valueForKey:@"media_files"] ;
    if (collectionViewArray.count == 2) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else{
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

#pragma mark - Grid And Slide View Btn Action
-(void)gridBtnAction:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.pollsTableView];
    NSIndexPath *indexPath = [self.pollsTableView indexPathForRowAtPoint:buttonPosition];
    AndPollCellTableViewCell *cell = [self.pollsTableView cellForRowAtIndexPath:indexPath];
    
    [self.selectedGridRows addObject:indexPath];
    if ([self.selectedListRows containsObject:indexPath]) {
        [self.selectedListRows removeObject:indexPath];
    }
    
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath  imageArray:ActivePollArray layoutChangeStr:[[ActivePollArray objectAtIndex:indexPath.row]valueForKey:@"media_count"] gridAndListType:GRIDVIEW];
    
    slideViewBool = NO;
    NSString*count=[[ActivePollArray objectAtIndex:indexPath.row]valueForKey:@"media_count"] ;
    
    if ([count isEqualToString:@"3"]) {
        [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath  imageArray:ActivePollArray layoutChangeStr:[[ActivePollArray objectAtIndex:indexPath.row]valueForKey:@"media_count"] gridAndListType:GRIDVIEW];
    }
    
}
-(void)slideViewBtnnAction:(UIButton *)sender
{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.pollsTableView];
    NSIndexPath *indexPath = [self.pollsTableView indexPathForRowAtPoint:buttonPosition];
    AndPollCellTableViewCell *cell = [self.pollsTableView cellForRowAtIndexPath:indexPath];
    
    [self.selectedListRows addObject:indexPath];
    if ([self.selectedGridRows containsObject:indexPath]) {
        [self.selectedGridRows removeObject:indexPath];
    }
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath imageArray:ActivePollArray layoutChangeStr:[[ActivePollArray objectAtIndex:indexPath.row]valueForKey:@"media_count"]  gridAndListType:LISTVIEW];
    
    
}
-(void)instaGramWallPost
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        NSString* imagePath = [NSString stringWithFormat:@"%@/instagramShare.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        
        //moreBtnindexPath
        NSArray *collectionViewArray = [ActivePollArray[moreBtnindexPath.row]valueForKey:@"media_files"] ;
        
        Cell.pollImageView.imageURL =[NSURL URLWithString:[[collectionViewArray objectAtIndex:moreBtnindexPath.item]valueForKey:@"media_name"]];
        [UIImagePNGRepresentation(screenImage) writeToFile:imagePath atomically:YES];
        NSLog(@"Image Size >>> %@", NSStringFromCGSize(screenImage.size));
        
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
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        
        NSString *emailTitle = @"Report Mail";
        NSString *messageBody = @"Type issue with this poll!"; // Change the message body to HTML
        NSArray *toRecipents = [NSArray arrayWithObject:@"info@poptheworld.com"];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:YES];
        [mc setToRecipients:toRecipents];
        
        [self presentViewController:mc animated:YES completion:nil];
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            SelectedPollIdStr=[[ActivePollArray objectAtIndex:moreBtnindexPath.row] valueForKey:@"poll_id"];
            [self deletePoll];
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
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)like_action:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.pollsTableView];
    NSIndexPath *indexPath = [self.pollsTableView indexPathForRowAtPoint:buttonPosition];
    [[NSUserDefaults standardUserDefaults]setObject:[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"poll_id"] forKey:@"poll_id"];
    
    VotesViewController *votes = [self.storyboard instantiateViewControllerWithIdentifier:@"VotesViewController"];
    [self.navigationController pushViewController:votes animated:NO];
}

- (IBAction)CommentBtn_Action:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.pollsTableView];
    NSIndexPath *indexPath = [self.pollsTableView indexPathForRowAtPoint:buttonPosition];
    [[NSUserDefaults standardUserDefaults]setObject:[[ActivePollArray objectAtIndex:indexPath.row] valueForKey:@"poll_id"] forKey:@"poll_id"];
    
    CommentViewController *comment = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    [self.navigationController pushViewController:comment animated:NO];
    
}
- (IBAction)setting:(id)sender {
    EditProfileViewController * setting = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    [self.navigationController pushViewController:setting animated:NO];
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

@end
