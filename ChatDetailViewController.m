//
//  ChatDetailViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "ChatDetailViewController.h"
#import "AFHTTPSessionManager.h"
#import "AsyncImageView.h"
#import "ChatViewController.h"
#import "ChatTableViewCell.h"
@interface ChatDetailViewController ()
{
    NSMutableArray*AllMessagesArray;
    NSString*receiver_idStr;
   UIRefreshControl*  refreshControl;
    ChatTableViewCell *cell;
    UIView*bgView;
    UIView*deleteView;
    UIButton*replyBtn;
    UILabel *TimeLbl;
    UIButton*deleteBtn;
    BOOL hideTime;
    
}
@end

@implementation ChatDetailViewController
-(void)CallGetSearchPoll
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"search_name":_SearchABar.text,@"user_id":userid};
    
    [manager POST:@"search_user" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [refreshControl endRefreshing];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             hideTime=YES;
             [AllMessagesArray removeAllObjects];
             AllMessagesArray=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] mutableCopy];
             [_chatTableview reloadData];
         }
         else {
             [self showAllChat];
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
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }];
}

-(void)DeleteChat
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"reciever_id":receiver_idStr};
    
    [manager POST:@"delete_chat" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [refreshControl endRefreshing];
         [AllMessagesArray removeAllObjects];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             [self  showAllChat];
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


-(void)showAllChat
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_all_messages" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [refreshControl endRefreshing];
         [AllMessagesArray removeAllObjects];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             hideTime=NO;
             AllMessagesArray=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] mutableCopy];
             [_chatTableview reloadData];
         }
         else {
             [_chatTableview reloadData];
         }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
#pragma mark-searchBar delegates
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self CallGetSearchPoll];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    [self CallGetSearchPoll];
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
-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePoll" object:self];

}
- (void)viewDidLoad {
     [super viewDidLoad];
     [self showAllChat];
     [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
     refreshControl = [[UIRefreshControl alloc] init];
     refreshControl.backgroundColor = [UIColor lightGrayColor];
     refreshControl.tintColor = [UIColor whiteColor];
     [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
     [_chatTableview  addSubview:refreshControl];
     self.automaticallyAdjustsScrollViewInsets= NO;
     AllMessagesArray=[[NSMutableArray alloc]init];
     [self showAllChat];
     _SearchABar.delegate = self;
     _SearchABar.showsSearchResultsButton=YES;
     _SearchABar.showsCancelButton=YES;
     _chatTableview.delegate = self;
     _chatTableview.dataSource = self;

}
- (void)refresh:(id)sender{
    [self showAllChat];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // (1) user details, (2) credit card details
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return AllMessagesArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellidentifier = @"cellId";
    cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if(cell== nil) {
        cell = [[ChatTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
        CGFloat heigth =[self tableView:tableView heightForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
        bottomBorder.frame = CGRectMake(0, heigth - 2, self.view.frame.size.width, 2);
        [cell.layer addSublayer:bottomBorder];
        cell.bgView=[[UIView alloc]initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y,self.view.frame.size.width, heigth)];
        cell.deleteView=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width+cell.frame.origin.x, cell.frame.origin.y,100, heigth)];
        deleteBtn=[[UIButton alloc]init];

        deleteBtn.frame = CGRectMake( 50, 0, 50, heigth);
        [deleteBtn addTarget:self action:@selector(deletePush:) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn setTitle:nil forState:UIControlStateNormal];
        deleteBtn.hidden = NO;
        [deleteBtn setImage:[UIImage imageNamed:@"Deleteicon.png"] forState:UIControlStateNormal];
        deleteBtn.tag = indexPath.row+100;
        deleteBtn.layer.borderColor =RGB(219.0, 219.0,219.0).CGColor;
        deleteBtn.layer.borderWidth =0.5f;
       
        replyBtn=[[UIButton alloc]init];
        replyBtn.frame = CGRectMake( 0, 0, 50, heigth);
        [replyBtn addTarget:self action:@selector(ReplyPush:) forControlEvents:UIControlEventTouchUpInside];
        [replyBtn setTitle:nil forState:UIControlStateNormal];
        replyBtn.hidden = NO;
        [replyBtn setImage:[UIImage imageNamed:@"ReplyIcon.png"] forState:UIControlStateNormal];
        replyBtn.tag = indexPath.row+100;
        replyBtn.layer.borderColor =RGB(219.0, 219.0,219.0).CGColor;
        replyBtn.layer.borderWidth =0.5f;
        [cell.deleteView addSubview:deleteBtn];
        [cell.deleteView addSubview:replyBtn];


        AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(14, 10, 45, 45)];
        [img1.layer setBorderWidth: 0.0];
        img1.layer.cornerRadius=45/2;
        [img1.layer setMasksToBounds:YES];
        img1.backgroundColor=[UIColor whiteColor];
        img1.imageURL=[NSURL URLWithString:[[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
        [cell.bgView addSubview:img1];
        
        UILabel *nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(67, 14, 265, 21)];
        nameLbl.text=[[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
        nameLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        nameLbl.font=FONTNAME_MONTSERRAT__BOLD_Size(15);
        [cell.bgView addSubview:nameLbl];
        UILabel *MsgLbl=[[UILabel alloc] initWithFrame:CGRectMake(67, 30, 175, 21)];
        MsgLbl.text=[[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"message"];
        MsgLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        MsgLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
        [cell.bgView addSubview:MsgLbl];
        if (hideTime==YES) {
        }
        else
        {

            TimeLbl=[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 50, 60, 30)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate * dateFromString1 = [dateFormatter dateFromString:[[AllMessagesArray objectAtIndex:indexPath.row]valueForKey:@"sent_date"]];
            
            NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
            [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [localDateFormatter setDateFormat:@"hh:mma"];
            TimeLbl.text  = [NSString stringWithFormat:@"%@", [localDateFormatter stringFromDate:dateFromString1]];
        
            TimeLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
            TimeLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
            [cell.bgView addSubview:TimeLbl];
        }
        UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
        [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [cell addGestureRecognizer:leftRecognizer];
        
        UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
        [rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [cell addGestureRecognizer:rightRecognizer];
        
        [cell addSubview:cell.bgView];
        [cell addSubview:cell.deleteView];
       
        NSString* chatStatus=[[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"chat_s"];
        if ([chatStatus isEqualToString:@"0"]) {
            [deleteBtn setHidden:NO];
            [replyBtn setHidden:NO];
        }
        else if ([chatStatus isEqualToString:@"1"]) {
            [deleteBtn setHidden:YES];
            [replyBtn setHidden:NO];
        }
        else if ([chatStatus isEqualToString:@""]) {
            [deleteBtn setHidden:YES];
            [replyBtn setHidden:NO];
        }
    }
    return cell;
}
#pragma mark - Events
- (void)ReplyPush:(UIButton *) sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_chatTableview];
    NSIndexPath *indexPath = [_chatTableview indexPathForRowAtPoint:buttonPosition];
    NSString*reciverId=[[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"user_id"];
    
    [[NSUserDefaults standardUserDefaults]setObject:reciverId forKey:@"reciever_id"];
    
    ChatViewController * ProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    [self.navigationController pushViewController:ProfileView animated:NO];
  }

- (void)deletePush:(UIButton *) sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_chatTableview];
    NSIndexPath *indexPath = [_chatTableview indexPathForRowAtPoint:buttonPosition];
    receiver_idStr= [[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"user_id"];
    NSString*username   = [[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
    NSString*text=[NSString stringWithFormat:@"Delete chat with '%@'?",username];

     UIAlertController * alert=   [UIAlertController
                                   alertControllerWithTitle:text
                                   message:@""
                                   preferredStyle:UIAlertControllerStyleAlert];

     UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self DeleteChat];
     }];
     [alert addAction:payAction];
    
    UIAlertAction *payAction1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:payAction1];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)leftSwipe:(UISwipeGestureRecognizer *) sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint tapLocation1 = [sender locationInView:_chatTableview];

    NSIndexPath *idp = [_chatTableview indexPathForRowAtPoint:tapLocation1];
    NSIndexPath*   leftSwipeCellIndex;

    if(leftSwipeCellIndex.row != idp.row) {
        ChatTableViewCell *cell1 = (ChatTableViewCell *)[_chatTableview cellForRowAtIndexPath:idp];
        ChatTableViewCell *lastCell = (ChatTableViewCell *)[_chatTableview cellForRowAtIndexPath:leftSwipeCellIndex];
        
        [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionAutoreverse animations:^{
                             
             CGRect frame = cell1.bgView.frame;
             frame.origin.x = -100;
             cell1.bgView.frame = frame;
            
             CGRect frame1 =cell1.deleteView.frame;
             frame1.origin.x = cell1.bgView.frame.size.width-100;
             cell1.deleteView.frame = frame1;
        }completion:^(BOOL finished){
             CGRect lastFrame = lastCell.bgView.frame;
             lastFrame.origin.x = 0;
             lastCell.bgView.frame = lastFrame;
            
             CGRect frame1 = lastCell.deleteView.frame;
             frame1.origin.x = lastCell.bgView.frame.size.width;
             lastCell.deleteView.frame = frame1;
         }];
    }
    else {
        ChatTableViewCell *cell1 = (ChatTableViewCell *)[_chatTableview cellForRowAtIndexPath:idp];
        
        [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionAutoreverse animations:^{
             CGRect frame = cell1.bgView.frame;
             frame.origin.x = -100;
             cell1.bgView.frame = frame;
            
             CGRect frame1 = cell1.deleteView.frame;
             frame1.origin.x =  cell1.bgView.frame.size.width-100;
            cell1.deleteView.frame = frame1;
            
        }completion:nil];
    }
    leftSwipeCellIndex = idp;
}
- (void)rightSwipe:(UISwipeGestureRecognizer *) sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint tapLocation1 = [sender locationInView:_chatTableview];
    NSIndexPath *idp = [_chatTableview indexPathForRowAtPoint:tapLocation1];
    ChatTableViewCell *cell2 = (ChatTableViewCell *)[_chatTableview cellForRowAtIndexPath:idp];
    
    [UIView animateWithDuration:0.3f animations:^{
         CGRect frame = cell2.bgView.frame;
         frame.origin.x = 0;
         cell2.bgView.frame = frame;
        
         CGRect frame1 = cell2.deleteView.frame;
         frame1.origin.x = cell2.bgView.frame.size.width+100;
         cell2.deleteView.frame = frame1;
     }
     completion:nil];
}
- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
