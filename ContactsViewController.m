//
//  ContactsViewController.m
//  POP
//
//  Created by KingTon on 9/20/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "ContactsViewController.h"
#import "AFHTTPSessionManager.h"
#import "InviteTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AsyncImageView.h"

@interface ContactsViewController () {
    
    NSMutableArray*SearchDataArray;
    UIRefreshControl*  refreshControl ;
    NSMutableArray *searchedDataArray;
    NSMutableArray *dataArray;
    NSMutableArray * prevDataArray;
     NSArray *pollListArray;
}
@end

@implementation ContactsViewController

-(void)CallGetFollowers {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"getidfollow"];
    
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"search_all_user" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {}
     
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
          [dataArray removeAllObjects];
          [refreshControl endRefreshing];
          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          NSLog(@"JSON: %@", responseObject);
          if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
              
              dataArray  =[[[responseObject objectForKey:@"data"]valueForKey:@"result"] mutableCopy];
              
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
-(void)CallGetSearchPoll
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"user_name contains[cd] %@", _SearchABar.text];
    if([_SearchABar.text isEqualToString:@""]) {
        dataArray = [prevDataArray mutableCopy];
        [_searchTableView reloadData];
        return ;
    }else {
        dataArray = [[dataArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
        [_searchTableView reloadData];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.automaticallyAdjustsScrollViewInsets= NO;
    pollListArray=[[NSMutableArray alloc]init];
    dataArray=[[NSMutableArray alloc]init];
    [self CallGetFollowers];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_searchTableView  addSubview:refreshControl];
}

- (void)refresh:(id)sender {
    [self CallGetFollowers];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length >0) {
        [self CallGetSearchPoll];
    }else {
        [self CallGetFollowers];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID=@"inviteCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==Nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    ((UILabel*)[cell viewWithTag:2]).text =[[dataArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
    UIImageView *inviteImageView = ((UIImageView*)[cell viewWithTag:1]);
    inviteImageView.imageURL=[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
    inviteImageView.layer.cornerRadius = 25;
    inviteImageView.clipsToBounds = YES;
    
    UIButton *checkBtn = ((UIButton*)[cell viewWithTag:3]);
    [checkBtn setHidden:YES];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID=@"inviteCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    UIButton *checkBtn = ((UIButton*)[cell viewWithTag:3]);
    [checkBtn setHidden:NO];
}
- (IBAction)cancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
