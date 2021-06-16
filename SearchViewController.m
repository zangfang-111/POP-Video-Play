//
//  SearchViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "SearchViewController.h"
#import "AFHTTPSessionManager.h"
#import "AsyncImageView.h"
#import "ProfileViewController.h"
#import "MyAndCurrentPollViewController.h"
#import "Utility.h"

@interface SearchViewController () {
    NSMutableArray*SearchDataArray;
    NSMutableArray *prevDataArray;
    UIRefreshControl*  refreshControl ;
    UIButton *followBtn;
    NSInteger *private;
    NSMutableArray *DataArray;
    NSUInteger privacyStatus;
    NSInteger act_status;
}
@end

@implementation SearchViewController

-(void)CallGetAllSearchPoll {
    
    //[[Utility sharedObject] showMBProgress:self.view message:@""];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid};
//    if (_SearchABar.text.length ==0) {
//        [[Utility sharedObject] hideMBProgress];
//    }
    
    [manager POST:@"search_all_user" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [refreshControl endRefreshing];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             //[[Utility sharedObject] showMBProgress:self.view message:@""];
             [SearchDataArray removeAllObjects];
             SearchDataArray=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] mutableCopy];
             prevDataArray = [SearchDataArray mutableCopy];
             [_searchTableView reloadData];
         }
         else {
             [SearchDataArray removeAllObjects];
             [_searchTableView reloadData];
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

-(void)CallFollowAction:(NSString*)follower_id follow_status: (NSString*)follow_status {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    NSDictionary * params = @{@"user_id":userid,@"to_follow_user_id":follower_id ,@"follow_unfollow_status":follow_status};
    
    [manager POST:@"add_follower_user" parameters:params progress:^(NSProgress * _Nonnull uploadProgress){}
     
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
              
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              NSLog(@"JSON: %@", responseObject);
              if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
                  
                  [self refresh:userid];
                  [_searchTableView reloadData];
                  
                  if ([follow_status longLongValue] ==0) {
                      [followBtn setTitle:@"Following" forState:UIControlStateNormal];
                  }else {
                      [followBtn setTitle:@"Follower" forState:UIControlStateNormal];
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
                  [_searchTableView reloadData];
              }
              else {
                  [_searchTableView reloadData];
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
-(void)CallGetFollowings {
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
              [_searchTableView reloadData];
          }
          else {
              [_searchTableView reloadData];
          }
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      }];
}

-(void)CallSendMessage :(NSString*)reciever_id message: (NSString*)message
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"reciever_id":reciever_id,@"message":message};
    
    [manager POST:@"send_message" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [self refresh:userid];
             [_searchTableView reloadData];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
     }];
}
-(void)CallGetSearchPoll {
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    if([_SearchABar.text isEqualToString:@""]) {
        SearchDataArray = [prevDataArray mutableCopy];
        [_searchTableView reloadData];
        return ;
    }
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"user_name contains[c] %@", _SearchABar.text];
    SearchDataArray = [[SearchDataArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    [_searchTableView reloadData];
}
- (void)makeRoot:(NSNotification *)notification {
    if([_followViewTypeString longLongValue] == 1) {
        [self CallGetFollowings];
    }
    else{
    }
    [_searchTableView reloadData];
}
-(void)viewWillAppear:(BOOL)animated {
    [self CallGetAllSearchPoll];
    [_searchTableView reloadData];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self CallGetAllSearchPoll];
    DataArray=[[NSMutableArray alloc]init];
    if([_followViewTypeString longLongValue] ==1) {
        [self CallGetFollowings];
    }
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.automaticallyAdjustsScrollViewInsets= NO;
    SearchDataArray=[[NSMutableArray alloc]init];
    _SearchABar.delegate = self;
    _SearchABar.showsSearchResultsButton=YES;
    _SearchABar.showsCancelButton=YES;
    _searchTableView.delegate=self;
    _searchTableView.dataSource=self;
     refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_searchTableView  addSubview:refreshControl];
}
- (void)refresh:(id)sender {
    if([_followViewTypeString longLongValue] ==1) {
        [self CallGetFollowings];
    }
    [self CallGetAllSearchPoll];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (_SearchABar.text.length >0) {
        [self CallGetSearchPoll];
    }else {
        [self CallGetAllSearchPoll];
    }
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    [self CallGetSearchPoll];
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
#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SearchDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellidentifier = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"" ];
    if(cell== nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
        CGFloat heigth =[self tableView:tableView heightForRowAtIndexPath:indexPath];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
        bottomBorder.frame = CGRectMake(0, heigth - 2, self.view.frame.size.width, 2);
        [cell.layer addSublayer:bottomBorder];
        
        AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(14, 15, 45, 45)];
        [img1.layer setBorderWidth: 0.0];
        img1.layer.cornerRadius=45/2;
        [img1.layer setMasksToBounds:YES];
        img1.backgroundColor=[UIColor whiteColor];
        img1.imageURL=[NSURL URLWithString:[[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
        [cell.contentView addSubview:img1];
        
        UILabel *nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(67, 10, 300, 21)];
        nameLbl.text=[[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
        nameLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        nameLbl.font=FONTNAME_MONTSERRAT__BOLD_Size(15);
        [cell.contentView addSubview:nameLbl];
        
        UILabel *DescLbl=[[UILabel alloc] initWithFrame:CGRectMake(67, 35, 300, 21)];
        DescLbl.text=[[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"description"];
        DescLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        DescLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
        [cell.contentView addSubview:DescLbl];
        
        followBtn  = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-100,20,79, 25)];
        [followBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        followBtn.titleLabel.font =FONTNAME_MONTSERRAT__BOLD_Size(15);
        
        [followBtn setBackgroundImage:[UIImage imageNamed:@"follow_btn.png"] forState:UIControlStateNormal];
        [followBtn addTarget:self action:@selector(follow_action:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:followBtn];
        
        _followViewTypeString = [[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"folllowing_status"];
        _chat_status = [[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"chat_status"];
        
        if ([_chat_status longLongValue] ==1 ) {
            [followBtn setTitle:@"Requested" forState:UIControlStateNormal];
        }else {
            
            if ([_followViewTypeString longLongValue] ==1) {
                [followBtn setTitle:@"Following" forState:UIControlStateNormal];
            }else {
                [followBtn setTitle:@"Follower" forState:UIControlStateNormal];
            }
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSUserDefaults standardUserDefaults]setObject:[[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"user_id"] forKey:@"clickedUserid"];
    
    [[NSUserDefaults standardUserDefaults]setObject:[[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"folllowing_status"] forKey:@"folllowing_status"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Fromsearch"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromHome"];

    MyAndCurrentPollViewController * HomeView = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAndCurrentPollViewController"];
    [self.navigationController pushViewController:HomeView animated:YES];
}
//-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
//        [[Utility sharedObject] hideMBProgress];
//    }
//}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
-(IBAction)follow_action:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.searchTableView];
    NSIndexPath *indexPath = [self.searchTableView indexPathForRowAtPoint:buttonPosition];
    int user_privacy_status = [[[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"privacy_status"] intValue];
    if (user_privacy_status ==1) {
        NSString *message = @"Hello. I'd like to follow you !";
        NSString *reciever_id = [[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"user_id"];
        [self CallSendMessage:reciever_id message:message];
    } else {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"FromHome"]) {
            NSString*getid=[[NSUserDefaults standardUserDefaults]valueForKey:@"clickedUserid"];
            [[NSUserDefaults standardUserDefaults] setObject:getid forKey:@"getidfollow"];
        }
        else {
            NSString*getid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
            [[NSUserDefaults standardUserDefaults] setObject:getid forKey:@"getidfollow"];
        }
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.searchTableView];
        NSIndexPath *indexPath = [self.searchTableView indexPathForRowAtPoint:buttonPosition];

        NSString* follower_id = [[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"user_id"];
        NSString* folllowing_status = [[SearchDataArray objectAtIndex:indexPath.row] valueForKey:@"folllowing_status"];

        [self CallFollowAction:follower_id follow_status:folllowing_status];
    }
}

@end
