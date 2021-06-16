//
//  InstantViewController.m
//  POP
//
//  Created by salentro on 12/20/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import "InstantViewController.h"
#import "InstantTableViewCell.h"
#import "HomeViewController.h"
#import "AFHTTPSessionManager.h"
#import "AsyncImageView.h"
#import "UIImageView+AFNetworking.h"
@interface InstantViewController ()
{
       
    BOOL slideViewBool;
    UIScrollView * imageScrollView;
    NSMutableArray*instantDataArray;
    UIRefreshControl*  refreshControl;
}
@end

@implementation InstantViewController
-(void)CallGetIntantPolls
{
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_instant_polls" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
              [refreshControl endRefreshing];
             [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:@"responseObject"];
             [instantDataArray removeAllObjects];
             instantDataArray=[[[responseObject valueForKey:@"data"] valueForKey:@"result"] mutableCopy];
             [_instantTableView reloadData];
         }
         else
         {
              [refreshControl endRefreshing];
                [instantDataArray removeAllObjects];
             [_instantTableView reloadData];

             
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
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [self CallGetIntantPolls];
[[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePoll" object:self];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    instantDataArray=[[NSMutableArray alloc]init];
    _instantTableView.delegate=self;
    _instantTableView.dataSource=self;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    self.automaticallyAdjustsScrollViewInsets= NO;
    UIImage *image = [UIImage imageNamed:@"popText.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];

    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_instantTableView  addSubview:refreshControl];
}
- (void)refresh:(id)sender
{
    [self CallGetIntantPolls];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // (1) user details, (2) credit card details
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //    if(nameArray.count>0)
    //        return nameArray.count;
    return instantDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellidentifier = @"cellId";
    
    InstantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if(cell== nil)
    {
        cell = [[InstantTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
        
    InstantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
    NSMutableArray *array=[[NSMutableArray alloc]init];
   array=  [[instantDataArray objectAtIndex:indexPath.row] valueForKey:@"media_files"];
   NSString*str=[NSString stringWithFormat:@"%lu",(unsigned long)[array count] ];
    
   [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath layoutChangeStr:str gridAndListType:GRIDVIEW];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    bottomBorder.frame = CGRectMake(0, cell.frame.size.height - 2, cell.frame.size.width, 2);
    [cell.layer addSublayer:bottomBorder];
    [cell.pollBtn addTarget:self action:@selector(openPoolBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(14, 10, 45, 45)];
    [img1.layer setBorderWidth: 0.0];
    img1.layer.cornerRadius=45/2;
    [img1.layer setMasksToBounds:YES];
    img1.backgroundColor=[UIColor whiteColor];
    //        img1.imageURL=[NSURL URLWithString:senderProfile_url];
    img1.imageURL=[NSURL URLWithString:[[instantDataArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
    [cell addSubview:img1];
    
    
    UILabel *nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(67, 10, 175, 30)];
    nameLbl.text=[[instantDataArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
    nameLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
    nameLbl.font=FONTNAME_MONTSERRAT__BOLD_Size(15);
    [cell addSubview:nameLbl];
    
    
    
    UILabel *DescLbl=[[UILabel alloc] initWithFrame:CGRectMake(14, 63, 215, 21)];
    DescLbl.text=[[instantDataArray objectAtIndex:indexPath.row] valueForKey:@"poll_description"];
    DescLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
    DescLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
    [cell addSubview:DescLbl];
    
    UILabel *TimeLbl=[[UILabel alloc] initWithFrame:CGRectMake(68, 34, 68, 21)];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * dateFromString1 = [dateFormatter dateFromString:[[instantDataArray objectAtIndex:indexPath.row]valueForKey:@"created_date"]];
        
        NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
        [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [localDateFormatter setDateFormat:@"hh:mm a"];
        // Popped on Thursday, 05 2017, 09:34 pm
       TimeLbl.text  = [NSString stringWithFormat:@"%@", [localDateFormatter stringFromDate:dateFromString1]];

    TimeLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
    TimeLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
    [cell addSubview:TimeLbl];
    
    cell.userNameLabel.text=[[instantDataArray objectAtIndex:indexPath.row] valueForKey:@"user_name"];
    cell.userImageView.layer.cornerRadius=cell.userImageView.frame.size.width/2;
    [cell.userImageView.layer setMasksToBounds:YES];
    cell.userImageView.imageURL=[NSURL URLWithString:[[instantDataArray objectAtIndex:indexPath.row] valueForKey:@"profile_pic"]];
        NSArray *collectionViewArray = [instantDataArray[indexPath.row]valueForKey:@"media_files"] ;

        if (collectionViewArray.count==1) {
             [cell. gridView setHidden:YES];
            [cell.slideView setHidden:YES];
        }
        else
        {
            [cell.gridView setHidden:NO];
            [cell.slideView setHidden:NO];
            
        }
    }
    return cell;
}


#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionViewArray = [instantDataArray[[(instantCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"] ;
    
    return collectionViewArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
       CGPoint center= collectionView.center;
    CGPoint rootViewPoint = [collectionView.superview convertPoint:center toView:self.instantTableView];
    NSIndexPath *indexPathinstant = [self.instantTableView indexPathForRowAtPoint:rootViewPoint];

    NSArray *collectionViewArray = [instantDataArray[[(instantCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"];
    
    UIImageView * imgeView = [[UIImageView alloc]initWithFrame:cell.frame];
    [cell.contentView addSubview:imgeView];

        if (collectionViewArray.count == 1) {
            cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height );
            imgeView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height );
        }
        else if (collectionViewArray.count == 2) {
            cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width , collectionView.frame.size.height / 2 );
           imgeView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.width / 2 );
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
    
    
    if ([[instantDataArray [indexPathinstant.row]valueForKey:@"media_type"] isEqualToString:@"Video"]) {
        
        NSURL *ratingUrl = [NSURL URLWithString:[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"video_thumbnail"]];
        [imgeView setImageWithURLRequest:[NSURLRequest requestWithURL:ratingUrl] placeholderImage:[UIImage imageNamed:@"likeWhite.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
        
             imgeView.image = image;
             
         }failure:nil];
        
        
    }
    else
    {

    NSURL *ratingUrl = [NSURL URLWithString:[[collectionViewArray objectAtIndex:indexPath.item]valueForKey:@"media_name"]];
    [imgeView setImageWithURLRequest:[NSURLRequest requestWithURL:ratingUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                                                                                                                            {
                                                         imgeView.image= image;
                                                                                                                            }failure:nil];

    }
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *mediaArray =  [NSMutableArray new];
    mediaArray = [instantDataArray[[(instantCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"];
    
    if (mediaArray.count == 1) {
        return   CGSizeMake(collectionView.frame.size.width , collectionView.frame.size.height  );  //1
        
    }
    else if (mediaArray.count == 2) {
        return    CGSizeMake(collectionView.frame.size.width / 2 , collectionView.frame.size.width/2 );//2
        
    }
    else if(mediaArray.count == 3) {
        
        if(indexPath.row == 1 || indexPath.row ==2)
        {
            return CGSizeMake(collectionView.frame.size.width/2, collectionView.frame.size.height/2);//3
        }
        else
        {
            return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height/2);//3
        }
    }
    else if(mediaArray.count == 4) {
        return    CGSizeMake(collectionView.frame.size.width / 2  , collectionView.frame.size.height / 2);//4
    }
    else
    {
        return   CGSizeMake(collectionView.frame.size.width  , collectionView.frame.size.height );
    }
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSArray *mediaArray =  [NSMutableArray new];
        mediaArray = [instantDataArray[[(instantCollectionView *)collectionView indexPath].row]valueForKey:@"media_files"];
    if (mediaArray.count == 2) {
        return UIEdgeInsetsMake(collectionView.bounds.size.height/4, 0, 0, 0);
    }
    else{
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}
#pragma mark - Events
-(void)openPoolBtnAction:(UIButton *)sender
{
    if (instantDataArray.count==0) {
        [_instantTableView reloadData];
    }
    else
    {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.instantTableView];
    NSIndexPath *indexPath = [self.instantTableView indexPathForRowAtPoint:buttonPosition];
//   InstantTableViewCell *cell = [self.instantTableView cellForRowAtIndexPath:indexPath];
    
    HomeViewController * homeView = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewId"];
    homeView.viewString= INSTANT_VIEW;
    homeView.instantDic = [instantDataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:homeView animated:NO];
        
    }
}
- (IBAction)backBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
