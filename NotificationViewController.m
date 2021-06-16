//
//  NotificationViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "NotificationViewController.h"
#import "AFHTTPSessionManager.h"
#import "AsyncImageView.h"
#import "checkbox.h"
#import "MyAndCurrentPollViewController.h"
@interface NotificationViewController ()
{
    NSMutableArray*NotificationDataArray;
    UIRefreshControl*  refreshControl;NSString *notification_id;UIView*  vi;
    NSString* pollIdStr;
    NSString*timelineStatusStr;
    NSString* followStatusStr;NSString*  req_userid;
    NSString*   userid;  NSInteger notificationindexPath;
}

@end

@implementation NotificationViewController
-(void)CallGetAllNotification {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_all_notifications" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [refreshControl endRefreshing];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [NotificationDataArray removeAllObjects];
             NotificationDataArray=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] mutableCopy];
             [_notificationTableview reloadData];
         }
         else {
             [NotificationDataArray removeAllObjects];
             [_notificationTableview reloadData];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [refreshControl endRefreshing];
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
-(void)DeleteNotification {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"notification_id":notification_id};
    
    [manager POST:@"delete_notification" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [refreshControl endRefreshing];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [self CallGetAllNotification];
         }
         else {
             [_notificationTableview reloadData];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [refreshControl endRefreshing];
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
-(void)DeleteAllNotification {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    NSDictionary * params = @{@"reciever_id":userid};

    [manager POST:@"delete_all_notification" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [refreshControl endRefreshing];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [self CallGetAllNotification];
         }
         else{
             [_notificationTableview reloadData];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [refreshControl endRefreshing];
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
-(void)viewWillAppear:(BOOL)animated {
     [self.navigationController setNavigationBarHidden:NO];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePoll" object:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.automaticallyAdjustsScrollViewInsets= NO;
    NotificationDataArray=[[NSMutableArray alloc]init];
    [self CallGetAllNotification];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_notificationTableview  addSubview:refreshControl];
}
- (void)refresh:(id)sender {
    [self CallGetAllNotification];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - UITableViewDataSource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NotificationDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellidentifier = @"cellId";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if(cell== nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
        CGFloat heigth =[self tableView:tableView heightForRowAtIndexPath:indexPath];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
        bottomBorder.frame = CGRectMake(0, heigth - 2, self.view.frame.size.width, 2);
        [cell.layer addSublayer:bottomBorder];
        AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(5, 15, 45, 45)];
        [img1.layer setBorderWidth: 0.0];
        img1.layer.cornerRadius=45/2;
        [img1.layer setMasksToBounds:YES];
        img1.backgroundColor=[UIColor whiteColor];
        img1.imageURL=[NSURL URLWithString:[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
        [cell addSubview:img1];
        UILabel *nameLbl;
        nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(60, 5, self.view.frame.size.width-70, 60)];
        nameLbl.numberOfLines=2;
        
        NSString *name=[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
        NSString*nameAdd=[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"message"];
        NSString*msgStr=[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"message"];
        NSString *str1=msgStr;
        NSArray *tempArray = [str1 componentsSeparatedByString:@"\""];
        str1 = [tempArray objectAtIndex:0];
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:msgStr];
        [attString addAttribute: NSFontAttributeName value:  FONTNAME_MONTSERRAT__BOLD_Size(14) range: NSMakeRange(0,[name length])];
        [attString addAttribute: NSFontAttributeName value:FONTNAME_MONTSERRAT_REGULAR_Size(14) range: NSMakeRange([name length],[nameAdd length]-[name length])];
        [attString addAttribute: NSFontAttributeName value:FONTNAME_MONTSERRAT__BOLD_Size(14) range: NSMakeRange([str1 length],[msgStr length]-[str1 length])];
        nameLbl.attributedText=attString;
        [cell addSubview:nameLbl];
        
        UILabel *TimeLbl=[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 52, 66, 21)];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * dateFromString1 = [dateFormatter dateFromString:[[NotificationDataArray objectAtIndex:indexPath.row]valueForKey:@"created_date"]];
        
        NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
        [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [localDateFormatter setDateFormat:@"hh:mm aa"];
        TimeLbl.text  = [NSString stringWithFormat:@"%@", [localDateFormatter stringFromDate:dateFromString1]];

        TimeLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        TimeLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(13);
        [cell addSubview:TimeLbl];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    notificationindexPath   = indexPath.row;
    notification_id=[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"notification_id"];

    if ([[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"notification_type"] isEqualToString:@"Winning_poll"]) {
        pollIdStr=[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"poll_id"];
    }
    else if ([[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"notification_type"] isEqualToString:@"follower_request"]) {
             req_userid=[[NotificationDataArray objectAtIndex:indexPath.row] objectForKey:@"user_id"];
             userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
             [self showFollowRequestPopUp];
    }
    [[NSUserDefaults standardUserDefaults]setObject:[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"user_id"] forKey:@"clickedUserid"];
    
    
    [[NSUserDefaults standardUserDefaults]setObject:[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"folllowing_status"] forKey:@"folllowing_status"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Fromsearch"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromHome"];
    
    MyAndCurrentPollViewController * HomeView = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAndCurrentPollViewController"];
    [self.navigationController pushViewController:HomeView animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        notification_id=[[NotificationDataArray objectAtIndex:indexPath.row] valueForKey:@"notification_id"];
        [self DeleteNotification];
    }
}
-(void)showFollowRequestPopUp {
    if (IS_IPHONE_4)
    {
        vi=[[UIView alloc] initWithFrame:CGRectMake(30, 100, self.view.frame.size.width-60, self.view.frame.size.height-280)];
        
    }
    if (IS_IPHONE_5) {
        vi=[[UIView alloc] initWithFrame:CGRectMake(30, 100, self.view.frame.size.width-60, self.view.frame.size.height-320)];
        
    }
    else if (IS_IPHONE_6)
    {
        vi=[[UIView alloc] initWithFrame:CGRectMake(30, 100, self.view.frame.size.width-60, self.view.frame.size.height-400)];
        
    }
    else
    {
        vi=[[UIView alloc] initWithFrame:CGRectMake(30, 100, self.view.frame.size.width-60, self.view.frame.size.height-480)];
    }

    vi.backgroundColor=[UIColor whiteColor];
    vi.layer.cornerRadius = 10;
    vi.layer.borderWidth = 1;
    vi.layer.borderColor = [UIColor orangeColor].CGColor;
    vi.clipsToBounds = YES;
    
    AsyncImageView *ProfileImg=[[AsyncImageView alloc] initWithFrame:CGRectMake((vi.frame.size.width/2)-43, 25, 85, 85)];
    ProfileImg.imageURL=[NSURL URLWithString:[[NotificationDataArray objectAtIndex:0] valueForKey:@"profile_pic"]];
    ProfileImg.layer.cornerRadius = ProfileImg.frame.size.width / 2;
    ProfileImg.layer.borderWidth = 2.5;
    ProfileImg.layer.borderColor = [UIColor orangeColor].CGColor;
    ProfileImg.clipsToBounds = YES;
    [vi addSubview:ProfileImg];
    
    UILabel *nameCus=[[UILabel alloc] initWithFrame:CGRectMake(10, 110, vi.frame.size.width-20, 21)];
    nameCus.text=[[NotificationDataArray objectAtIndex:0] valueForKey:@"user_name"];
    nameCus.textColor=[UIColor grayColor];
    nameCus.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
    nameCus.textAlignment=NSTextAlignmentCenter;
    [vi addSubview:nameCus];
    
    
    
    UILabel *AddressOfCus=[[UILabel alloc] initWithFrame:CGRectMake(10, 130, vi.frame.size.width-20, 45)];
    AddressOfCus.numberOfLines=0;
    AddressOfCus.textColor=[UIColor lightGrayColor];
    AddressOfCus.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
    AddressOfCus.textAlignment=NSTextAlignmentCenter;
    AddressOfCus.text=[NSString stringWithFormat:@"%@ has sent a follower request for approval",[[NotificationDataArray objectAtIndex:0] valueForKey:@"user_name"]];
    [vi addSubview:AddressOfCus];
    
    
    UIButton *donepopup=[[UIButton alloc] initWithFrame:CGRectMake( (vi.frame.size.width/2)-100, vi.frame.size.height-60, 70, 30)];
    
    [donepopup setTitle: @"Reject" forState: UIControlStateNormal];
    [donepopup setBackgroundColor:[UIColor orangeColor]];
    donepopup.titleLabel.font =  FONTNAME_MONTSERRAT_REGULAR_Size(14);
    [donepopup addTarget:self action:@selector(noBtn:) forControlEvents:UIControlEventTouchUpInside];
    [donepopup setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [vi addSubview:donepopup];
    
    UIButton *cancelpopup=[[UIButton alloc] initWithFrame:CGRectMake((vi.frame.size.width/2)+20, vi.frame.size.height-60, 70,30)];
    [cancelpopup setBackgroundColor:[UIColor orangeColor]];
    [cancelpopup setTitle: @"Accept" forState: UIControlStateNormal];
    cancelpopup.titleLabel.font =  FONTNAME_MONTSERRAT_REGULAR_Size(14);
    [cancelpopup addTarget:self action:@selector(yesBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cancelpopup setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [vi addSubview:cancelpopup];
    vi.userInteractionEnabled = YES;
    
    self.view.userInteractionEnabled = YES;
    [self.view addSubview:vi];
}
-(void)Accept_followRequest
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"requester_id":req_userid,@"follow_status":followStatusStr};
    [manager POST:@"accept_reject_follower_request" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
             [self DeleteNotification];
             [vi removeFromSuperview];
         }
         else {
              [vi removeFromSuperview];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }];
}

-(void)winningPollRequest {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"poll_id":pollIdStr,@"timeline_status":timelineStatusStr};
    [manager POST:@"post_on_timeline_status" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
             [self DeleteNotification];
             [vi removeFromSuperview];
         }
         else {
              [vi removeFromSuperview];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }];
}

-(IBAction)yesBtn:(id)sender {
    timelineStatusStr=@"yes";
    followStatusStr=@"1";
    if ([[[NotificationDataArray objectAtIndex:notificationindexPath] valueForKey:@"notification_type"] isEqualToString:@"Winning_poll"]) {
        [self winningPollRequest];
    }
    else {
        [self Accept_followRequest];
    }
}
-(IBAction)noBtn:(id)sender {
    timelineStatusStr=@"no";
    followStatusStr=@"0";
    if ([[[NotificationDataArray objectAtIndex:notificationindexPath] valueForKey:@"notification_type"] isEqualToString:@"Winning_poll"]) {
        [self winningPollRequest];
        [vi removeFromSuperview];
    }
    else {
        [self DeleteFromdataBase];
        [self DeleteNotification];
        [vi removeFromSuperview];
    }
}

-(void)DeleteFromdataBase {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    
    NSString*follower_id=[[NotificationDataArray objectAtIndex:notificationindexPath] valueForKey:@"user_id"];
    NSDictionary * params = @{@"user_id":userid,@"requested_id":follower_id };
    
    [manager POST:@"delete_rejected_request" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
         }
     }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
#pragma mark - Events
- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)deleted:(id)sender {
    [self DeleteAllNotification];
}

@end
