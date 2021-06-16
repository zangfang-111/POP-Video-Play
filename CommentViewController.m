//
//  CommentViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "CommentViewController.h"
#import "AFHTTPSessionManager.h"
#import "AsyncImageView.h"
@interface CommentViewController ()
{
    NSMutableArray*CommentdataArray;
    UIRefreshControl*  refreshControl;
}
@end

@implementation CommentViewController

-(void)CallSendCommentOnPoll
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    NSString*SelectedPollIdStr=[[NSUserDefaults standardUserDefaults]valueForKey:@"poll_id"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"poll_id":SelectedPollIdStr,@"comment":_CommentFld.text};
    
    [manager POST:@"comment_on_poll" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             _CommentFld.text=@"";
             [self CallGetCommentOnPoll];
             
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
     }];
}
-(void)CallGetCommentOnPoll
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString*SelectedPollIdStr=[[NSUserDefaults standardUserDefaults]valueForKey:@"poll_id"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"poll_id":SelectedPollIdStr};
    
    [manager POST:@"get_comments_on_poll" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
           [refreshControl endRefreshing];
           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
           NSLog(@"JSON: %@", responseObject);
           if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
            CommentdataArray  =[[responseObject objectForKey:@"data"]valueForKey:@"result"];
             
             [_commentTabelView reloadData];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
     }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePoll" object:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    CommentdataArray=[[NSMutableArray alloc]init];
    [self CallGetCommentOnPoll];
    
    self.automaticallyAdjustsScrollViewInsets= NO;

    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_commentTabelView  addSubview:refreshControl];
}
- (void)refresh:(id)sender
{
    [self CallGetCommentOnPoll];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 81;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [CommentdataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellidentifier = @"cellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if(cell== nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
        
        CGFloat heigth =[self tableView:tableView heightForRowAtIndexPath:indexPath];
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
        bottomBorder.frame = CGRectMake(0, heigth - 2, self.view.frame.size.width, 2);
        [cell.layer addSublayer:bottomBorder];
        
        AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(14, 10, 45, 45)];
        [img1.layer setBorderWidth: 0.0];
        img1.layer.cornerRadius=45/2;
        [img1.layer setMasksToBounds:YES];
        img1.backgroundColor=[UIColor whiteColor];
        img1.imageURL=[NSURL URLWithString:[[CommentdataArray objectAtIndex:indexPath.row] valueForKey:@"commenter_profile_pic"]];
        [cell addSubview:img1];
        
        
        UILabel *nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(67, 14, 265, 21)];
        nameLbl.text=[[CommentdataArray objectAtIndex:indexPath.row] valueForKey:@"commenter_name"];
        nameLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        nameLbl.font= FONTNAME_MONTSERRAT__BOLD_Size(15);

        [cell addSubview:nameLbl];
        
        UILabel *DescLbl=[[UILabel alloc] initWithFrame:CGRectMake(67, 24, self.view.frame.size.width-70,45)];
        DescLbl.text=[[CommentdataArray objectAtIndex:indexPath.row] valueForKey:@"comment"];
        DescLbl.numberOfLines=2;
        DescLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        DescLbl.font= FONTNAME_MONTSERRAT_REGULAR_Size(13);
        [cell addSubview:DescLbl];
        
        UILabel *TimeLbl=[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 60, 66, 21)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * dateFromString1 = [dateFormatter dateFromString:[[CommentdataArray objectAtIndex:indexPath.row]valueForKey:@"created_date"]];
        
        NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
        [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [localDateFormatter setDateFormat:@"hh:mma"];
        TimeLbl.text  = [NSString stringWithFormat:@"%@", [localDateFormatter stringFromDate:dateFromString1]];
        TimeLbl.font= FONTNAME_MONTSERRAT_REGULAR_Size(13);
        TimeLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        [cell addSubview:TimeLbl];
        
    }
    return cell;
}

#pragma mark - Events
- (IBAction)Send_Action:(id)sender {
    
        if (_CommentFld.text.length==0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert!"
                                      message:@"Please Type message"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self CallSendCommentOnPoll];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - TextField delegate starts

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [textField resignFirstResponder];
    return YES;
}

@end
