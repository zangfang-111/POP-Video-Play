//
//  VotesViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "VotesViewController.h"
#import "AFHTTPSessionManager.h"
#import "AsyncImageView.h"
@interface VotesViewController () {
    NSMutableArray*voteDataArray;
    UIRefreshControl*  refreshControl ;
}
@end

@implementation VotesViewController
-(void)CallGetPolls {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString*SelectedPollIdStr=[[NSUserDefaults standardUserDefaults]valueForKey:@"poll_id"];
    NSDictionary * params = @{@"poll_id":SelectedPollIdStr};
    [manager POST:@"get_votes_on_poll" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [refreshControl endRefreshing];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             voteDataArray=[[responseObject valueForKey:@"data"] valueForKey:@"result"];
             [_votesTbleview reloadData];
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
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    voteDataArray=[[NSMutableArray alloc]init];

    self.automaticallyAdjustsScrollViewInsets= NO;
    [self CallGetPolls];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_votesTbleview  addSubview:refreshControl];
}
- (void)refresh:(id)sender {
    [self CallGetPolls];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return voteDataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81;
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
        
        AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(14, 15, 45, 45)];
        [img1.layer setBorderWidth: 0.0];
        img1.layer.cornerRadius=45/2;
        [img1.layer setMasksToBounds:YES];
        img1.backgroundColor=[UIColor whiteColor];
        img1.imageURL=[NSURL URLWithString:[[voteDataArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
        [cell addSubview:img1];
    
        UILabel *nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(67, 24, 300, 21)];
        nameLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        
        NSString *name=[[voteDataArray objectAtIndex:indexPath.row] valueForKey:@"voter_name"];
        NSString*nameAdd=@" Voted on your poll";
        NSString*nameStr=[NSString stringWithFormat:@"%@ Voted on your poll",[[voteDataArray objectAtIndex:indexPath.row] valueForKey:@"voter_name"]];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:nameStr];
        
        [attString addAttribute: NSFontAttributeName value:FONTNAME_MONTSERRAT__BOLD_Size(15) range: NSMakeRange(0,[name length])];
        [attString addAttribute: NSFontAttributeName value:FONTNAME_MONTSERRAT_REGULAR_Size(14) range: NSMakeRange([name length],[nameAdd length])];
        nameLbl.attributedText=attString;
        [cell addSubview:nameLbl];
        
        UILabel *DescLbl=[[UILabel alloc] initWithFrame:CGRectMake(67, 30, self.view.frame.size.width-70, 21)];
        DescLbl.text=[[voteDataArray objectAtIndex:indexPath.row] valueForKey:@"comment"];
        DescLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        DescLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
        [cell addSubview:DescLbl];
        UILabel *TimeLbl=[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 49,80, 21)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * dateFromString1 = [dateFormatter dateFromString:[[voteDataArray objectAtIndex:indexPath.row]valueForKey:@"created_date"]];
        
        NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
        [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [localDateFormatter setDateFormat:@"hh:mma"]; 
        TimeLbl.text  = [NSString stringWithFormat:@"%@", [localDateFormatter stringFromDate:dateFromString1]];
        TimeLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
        TimeLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
        [cell addSubview:TimeLbl];
    }
    return cell;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
