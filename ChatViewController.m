//
//  ChatViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "ChatViewController.h"
#import "AsyncImageView.h"
#import "AFHTTPSessionManager.h"
@interface ChatViewController ()
{
    NSMutableArray*AllMessagesArray;
    NSMutableArray*UserDataArray;
    UIRefreshControl*  refreshControl;
}
@end

@implementation ChatViewController
-(void)CallSendMessage
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*reciever_id=[[NSUserDefaults standardUserDefaults]valueForKey:@"reciever_id"];

    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"reciever_id":reciever_id,@"message":_messageTxtField.text};
    
    [manager POST:@"send_message" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"JSON: %@", responseObject);
        if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
            _messageTxtField.text=@"";
            [self CallGetMessages];
            if (AllMessagesArray.count>5) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:[AllMessagesArray count]-1 inSection:0];
                [_chatDetailTbleView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
             }
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
-(void)CallGetMessages
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*reciever_id=[[NSUserDefaults standardUserDefaults]valueForKey:@"reciever_id"];

    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"reciever_id":reciever_id};
    
    [manager POST:@"one_to_one_chat_detail" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [refreshControl endRefreshing];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"JSON: %@", responseObject);
            if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
                 AllMessagesArray=[[responseObject valueForKey:@"data"] valueForKey:@"result"];
                 UserDataArray=[responseObject valueForKey:@"data"];
                 [_chatDetailTbleView reloadData];
                 NSIndexPath *ip = [NSIndexPath indexPathForRow:[AllMessagesArray count]-1 inSection:0];
                 [_chatDetailTbleView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self CallGetMessages];
    self.automaticallyAdjustsScrollViewInsets= NO;
    timeArray=[[NSMutableArray alloc] init];
    AllMessagesArray=[[NSMutableArray alloc]init];
    UserDataArray=[[NSMutableArray alloc]init];
    //calling Web Service
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor lightGrayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_chatDetailTbleView  addSubview:refreshControl];
}

- (void)refresh:(id)sender {
    [self CallGetMessages];
}
#pragma mark - TextField delegate starts

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Table View Delegate starts

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [AllMessagesArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier=@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
 
    if(cell== nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor=[UIColor clearColor];
        
        CGSize maximumSize = CGSizeMake(self.view.frame.size.width-130, CGFLOAT_MAX);
        NSString *currentMessage = [[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"message"];
        UIFont *myFont = [UIFont fontWithName:@"Helvetica Neue" size:14];
        CGRect myStringSize = [currentMessage boundingRectWithSize:maximumSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{ NSFontAttributeName:myFont }
                                                       context:nil];
    
        if([[[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"message_type"] isEqualToString:@"send"]) {
            AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-80, cell.frame.size.height/2-15+5, 60, 60)];
            [img1.layer setBorderWidth: 0.0];
            img1.layer.cornerRadius=30;
            [img1.layer setMasksToBounds:YES];
            img1.backgroundColor=[UIColor whiteColor];
            img1.imageURL=[NSURL URLWithString:[UserDataArray valueForKey:@"user_profile_pic"]];
            [cell addSubview:img1];
            
            UILabel *nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-myStringSize.size.width-125, 0, myStringSize.size.width+70, 12)];
            nameLbl.text=[UserDataArray valueForKey:@"user_name"];;
            nameLbl.textAlignment=NSTextAlignmentRight;
            nameLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
            nameLbl.font=FONTNAME_MONTSERRAT__BOLD_Size(13);
            [cell addSubview:nameLbl];
            
            UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-myStringSize.size.width-125, 15+5, myStringSize.size.width+40, myStringSize.size.height+25)];
            img.image=[UIImage imageNamed:@"white"];
            
            
            CGRect labelFrame = CGRectMake (10, 5, myStringSize.size.width+10, myStringSize.size.height);
            UILabel *labell = [[UILabel alloc] initWithFrame:labelFrame];
            
            labell.textColor=[UIColor blackColor];
            labell.lineBreakMode=NSLineBreakByWordWrapping;
            labell.numberOfLines=15;
            labell.backgroundColor=[UIColor clearColor];
            labell.font= FONTNAME_MONTSERRAT_REGULAR_Size(14);
            labell.text=[[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"message"];
            [img addSubview:labell];
            
            [cell addSubview:img];
            
            UILabel *timeLbl=[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-myStringSize.size.width-125, myStringSize.size.height+42+5, myStringSize.size.width+40, 12)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateFormat:@"hh:mma"];
            NSDate * dateFromString1 = [dateFormatter dateFromString:[[AllMessagesArray objectAtIndex:indexPath.row]valueForKey:@"sent_at"]];
            
            NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
            [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [localDateFormatter setDateFormat:@"hh:mma"];
            timeLbl.text  = [NSString stringWithFormat:@"%@", [localDateFormatter stringFromDate:dateFromString1]];
            timeLbl.textAlignment=NSTextAlignmentRight;
            timeLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
            timeLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(12);
            [cell addSubview:timeLbl];
        }
        else{
            AsyncImageView *img1=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, cell.frame.size.height/2-15+5, 60, 60)];
            [img1.layer setBorderWidth: 0.0];
            [img1.layer setMasksToBounds:YES];
            img1.backgroundColor=[UIColor whiteColor];
            img1.layer.cornerRadius=30;
            img1.imageURL=[NSURL URLWithString:[UserDataArray valueForKey:@"reciever_profile_pic"]];
            [cell addSubview:img1];
            
            
            UILabel *nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(85, 0, myStringSize.size.width+70, 12)];
            nameLbl.text=[UserDataArray valueForKey:@"reciever_name"];
            nameLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
            nameLbl.font=FONTNAME_MONTSERRAT__BOLD_Size(13);
            [cell addSubview:nameLbl];
            
            UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(85,  15+5, myStringSize.size.width+40, myStringSize.size.height+25)];
            img.image=[UIImage imageNamed:@"chat-box"];
            
            CGRect labelFrame;
            labelFrame = CGRectMake (15, 5, myStringSize.size.width+10, myStringSize.size.height);
            UILabel *labell = [[UILabel alloc] initWithFrame:labelFrame];
            labell.lineBreakMode=NSLineBreakByWordWrapping;
            labell.numberOfLines=15;
            labell.textColor=[UIColor blackColor];
            labell.font= FONTNAME_MONTSERRAT_REGULAR_Size(14);
            labell.text=[[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"message"];
            [img addSubview:labell];
            [cell addSubview:img];
            
            UILabel *timeLbl=[[UILabel alloc] initWithFrame:CGRectMake(85,  myStringSize.size.height+42+5, myStringSize.size.width+40, 12)];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateFormat:@"hh:mma"];
            NSDate * dateFromString1 = [dateFormatter dateFromString:[[AllMessagesArray objectAtIndex:indexPath.row]valueForKey:@"sent_at"]];
            
            NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
            [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [localDateFormatter setDateFormat:@"hh:mma"];
            timeLbl.text  = [NSString stringWithFormat:@"%@", [localDateFormatter stringFromDate:dateFromString1]];

            timeLbl.textColor=[UIColor colorWithRed:88/255.0 green:88/255.0 blue:88/255.0 alpha:1];
            timeLbl.font=FONTNAME_MONTSERRAT_REGULAR_Size(12);
            [cell addSubview:timeLbl];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize maximumSize = CGSizeMake(self.view.frame.size.width-130, CGFLOAT_MAX);
    NSString *myString = [[AllMessagesArray objectAtIndex:indexPath.row] valueForKey:@"message"];
    UIFont *myFont = [UIFont fontWithName:@"Helvetica Neue" size:14];
    CGRect myStringSize = [myString boundingRectWithSize:maximumSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{ NSFontAttributeName:myFont }
                                                 context:nil];
    if(myStringSize.size.height<20)
        return 95;
    else if (myStringSize.size.height<40)
        return 110;
    else if (myStringSize.size.height<60)
        return 135;
    else
        return myStringSize.size.height+80;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
#pragma mark - Button Action

- (IBAction)sendBtn_Tapped:(id)sender {
    if (_messageTxtField.text.length==0) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert!"
                                      message:@"Please Type message"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
    
    }
    else {
        [self CallSendMessage];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35];
        self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
        [UIView commitAnimations];
    }
}

- (IBAction)backBtn_Tapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
