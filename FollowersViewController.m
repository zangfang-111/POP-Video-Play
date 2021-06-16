//
//  FollowersViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "FollowersViewController.h"
#import "HomeViewController.h"
#import "AFHTTPSessionManager.h"
#import "AsyncImageView.h"
#import "FollowersCollectionView.h"
#import "UIImageView+AFNetworking.h"
#import "FollowTableViewCell.h"
#import "MyAndCurrentPollViewController.h"
@interface FollowersViewController ()
{
    NSMutableArray * DataArray ;
    NSMutableArray * prevDataArray;
    UIScrollView * imageScrollView ;
    NSArray *pollListArray;
    NSString*toFollowUserIdStr;
    BOOL slideViewBool;
    NSDictionary * pollListDic;
    UIButton *followBtn;
    UIRefreshControl*  refreshControl;
    NSString*followStatus;
    UIView * pollView;
    NSMutableArray*SearchDataArray;
}
@end

@implementation FollowersViewController

-(void)CallFollowAction {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    NSString*follower_id=[[NSUserDefaults standardUserDefaults]valueForKey:@"follower_id"];
    NSDictionary * params = @{@"user_id":userid,@"to_follow_user_id":follower_id ,@"follow_unfollow_status":followStatus};

    [manager POST:@"add_follower_user" parameters:params progress:^(NSProgress * _Nonnull uploadProgress){}
     
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             if ([followStatus isEqualToString:@"1"]) {
                 [_followBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
             }
             
             else {
                 [_followBtn setTitle:@"Follow" forState:UIControlStateNormal];
             }
             
             if([_followViewTypeString isEqualToString:@"Following View"]) {
                 [self CallGetFollowings];
             }
             
             else{
                 [self CallGetFollowers];
             }
         }
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }];
}
-(void)CallGetFollowers {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"getidfollow"];
   
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_all_follower_users_polls" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {}
     
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [DataArray removeAllObjects];
         [refreshControl endRefreshing];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
            
             DataArray  =[[[responseObject objectForKey:@"data"]valueForKey:@"result"] mutableCopy];
            
             [_followersTbleView reloadData];
             
         }
         else {
             [_followersTbleView reloadData];

         }
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         [refreshControl endRefreshing];
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         UIAlertController * alert=   [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }];
}
-(void)CallGetFollowings
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"getidfollow"];
  
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_all_following_users_polls" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {}
     
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [refreshControl endRefreshing];
         [DataArray removeAllObjects];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             DataArray  =[[[responseObject objectForKey:@"data"]valueForKey:@"result"] mutableCopy];
             prevDataArray = [DataArray mutableCopy];
             [_followersTbleView reloadData];
         }
         else {
             [_followersTbleView reloadData];
         }
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         
         [refreshControl endRefreshing];
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         UIAlertController * alert=  [UIAlertController
                                       alertControllerWithTitle:@"Error!"
                                       message:@"Please try again later"
                                       preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }];
}
-(void)CallGetSearchPoll {
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    if([_SearchABar.text isEqualToString:@""]) {
        DataArray = [prevDataArray mutableCopy];
        [_followersTbleView reloadData];
        return ;
    }
     NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"user_name contains[cd] %@", _SearchABar.text];
     DataArray = [[DataArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
     [_followersTbleView reloadData];
}
- (void)makeRoot:(NSNotification *)notification {
    if([_followViewTypeString isEqualToString:@"Following View"]) {
        [self CallGetFollowings];
    }
    else{
        [self CallGetFollowers];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeRoot:) name:@"followercall" object:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    pollListArray=[[NSMutableArray alloc]init];

    DataArray=[[NSMutableArray alloc]init];
    
    if([_followViewTypeString isEqualToString:@"Following View"]) {
        
        self.title = @"Following";
        [self CallGetFollowings];
    }
    else{
        self.title = @"Followers";
        [self CallGetFollowers];
    }

    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    _SearchABar.showsSearchResultsButton=YES;
    _SearchABar.showsCancelButton=YES;
    pollListDic= [[NSDictionary alloc]init];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_followersTbleView  addSubview:refreshControl];
}
- (void)refresh:(id)sender
{
    if([_followViewTypeString isEqualToString:@"Following View"]) {
        self.title = @"Following";
        [self CallGetFollowings];
    }
    else{
        self.title = @"Followers";
        [self CallGetFollowers];
    }
    [self CallGetSearchPoll];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length>0) {
        [self CallGetSearchPoll];
    }else {
        if([_followViewTypeString isEqualToString:@"Following View"]) {
            [self CallGetFollowings];
        }
        else{
            [self CallGetFollowers];
        }
    }
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    [theSearchBar resignFirstResponder];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBaar {
    _SearchABar.text=@"";
    [self CallGetSearchPoll];
    [searchBaar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBr {
    [searchBr resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier=@"cellItem";
    FollowTableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@""];
    if(cell== nil) {
        cell = [[FollowTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

        for(UIView * vw in [cell  subviews])
        {
            if([vw isKindOfClass: [UIScrollView class]])
            {
                UIScrollView * scrollVW = (UIScrollView *)vw;
                if(scrollVW.tag == indexPath.row)
                {
                    [scrollVW removeFromSuperview];
                }
            }
        }
        UILabel *linelbl  = [[UILabel alloc]initWithFrame:CGRectMake(0,67,self.view.frame.size.width,1)];
        linelbl.backgroundColor = RGB(235.0, 235.0, 235.0) ;
        [cell addSubview:linelbl];

        AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(40, 5, 60, 60)];
        [img1.layer setBorderWidth: 0.0];
        img1.layer.cornerRadius=60/2;
        img1. clipsToBounds=YES;
        img1.imageURL=[NSURL URLWithString:[[DataArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
    
        [cell addSubview:img1];
    
        UIButton *nameBtn  = [[UIButton alloc]initWithFrame:CGRectMake(103,14,125, 37)];
        [nameBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        nameBtn.titleLabel.font =FONTNAME_MONTSERRAT__BOLD_Size(15);
        
        [nameBtn addTarget:self action:@selector(lblClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:nameBtn];
        [nameBtn setTitle:[[DataArray objectAtIndex:indexPath.row] valueForKey:@"user_name"] forState:UIControlStateNormal];
      
        followBtn  = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-110,20,90, 25)];
        [followBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        followBtn.titleLabel.font =FONTNAME_MONTSERRAT__BOLD_Size(15);
        
        [followBtn setBackgroundImage:[UIImage imageNamed:@"follow_btn.png"] forState:UIControlStateNormal];
        [followBtn addTarget:self action:@selector(follow_action:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:followBtn];

        if([_followViewTypeString isEqualToString:@"Following View"]) {
            
            [followBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
        }
        else {
            NSInteger followstatus=[[DataArray [indexPath.row]valueForKey:@"follow_status"] integerValue];

            NSString* approvalstatus=[DataArray [indexPath.row]valueForKey:@"follow_approval"];
            
            if (followstatus ==1 &&[approvalstatus isEqualToString:@"1"]) {
                
                [followBtn setTitle:@"Following" forState:UIControlStateNormal];
            }
            else  if (followstatus ==0 &&[approvalstatus isEqualToString:@""]){
                
                [followBtn setTitle:@"Follow" forState:UIControlStateNormal];
            }
            else  if (followstatus ==1 &&[approvalstatus isEqualToString:@"0"]){
                
                [followBtn setTitle:@"Requested" forState:UIControlStateNormal];
            }
            else {
                [followBtn setTitle:@"Follow" forState:UIControlStateNormal];
            }
        }
    
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}
#pragma mark - Collection View Delegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *Array1 =  [NSMutableArray new];
    
    FollowersCollectionView * collectionView1 = (FollowersCollectionView *)collectionView;
    Array1 = [[[DataArray[collectionView1.pollIndexPath.row]valueForKey:@"list_of_polls"] objectAtIndex:collectionView1.tag]valueForKey:@"media_files"] ;
    if (Array1.count>0) {
        return [Array1 count];
    }
    return 0;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Events
-(IBAction)lblClick:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.followersTbleView];
    NSIndexPath *indexPath = [self.followersTbleView indexPathForRowAtPoint:buttonPosition];
    
    if([_followViewTypeString isEqualToString:@"Following View"]) {
        [[NSUserDefaults standardUserDefaults]setObject:[[DataArray objectAtIndex:indexPath.row] valueForKey:@"following_user_id"] forKey:@"clickedUserid"];
    }
    else{
        [[NSUserDefaults standardUserDefaults]setObject:[[DataArray objectAtIndex:indexPath.row] valueForKey:@"follower_id"] forKey:@"clickedUserid"];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromHome"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Fromsearch"];
    MyAndCurrentPollViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAndCurrentPollViewController"];
    [self.navigationController pushViewController:ProfileView animated:YES];
}
- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)follow_action:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.followersTbleView];
    NSIndexPath *indexPath = [self.followersTbleView indexPathForRowAtPoint:buttonPosition];
    if([_followViewTypeString isEqualToString:@"Following View"]) {
        followStatus=@"0";
        [[NSUserDefaults standardUserDefaults]setObject:[DataArray valueForKey:@"following_user_id"][indexPath.row] forKey:@"follower_id"];
    }
    else {
        [[NSUserDefaults standardUserDefaults]setObject:[DataArray valueForKey:@"follower_id"][indexPath.row] forKey:@"follower_id"];
        NSInteger followstatus=[[DataArray [indexPath.row]valueForKey:@"follow_status"] integerValue];
        NSString* approvalstatus=[DataArray [indexPath.row]valueForKey:@"follow_approval"];
        if (followstatus ==1 &&[approvalstatus isEqualToString:@"1"]) {
            followStatus=@"0";
        }
        else  if (followstatus ==0 &&[approvalstatus isEqualToString:@""]){
            followStatus=@"1";
        }
        else  if (followstatus ==1 &&[approvalstatus isEqualToString:@"0"]){
            followStatus=@"0";
        }
    }
    [self CallFollowAction];
}
@end
