//
//  SettingsViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "SettingsViewController.h"
#import "EditProfileViewController.h"
#import "ResetPasswordViewController.h"
#import "AFHTTPSessionManager.h"
#import <MessageUI/MessageUI.h>
#import "termsViewController.h"
#import "BranchInviteViewController.h"
#import "BranchInviteTextContactProvider.h"
#import "BranchInviteEmailContactProvider.h"
#import "BranchActivityItemProvider.h"
#import "BranchSharing.h"
#import "UIViewController+BranchShare.h"
#import "BranchReferralController.h"
#import "CurrentUserModel.h"

@interface SettingsViewController () {
    NSString *device_id,*privacy_Status, *notification_Status, *comment_Status, *inviteName;
}
@end

@implementation SettingsViewController {
    int selected_item;
}
@synthesize swichbtn;
@synthesize swichbtn1;
@synthesize swichbtn2;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self GetUserProfileInfo];
    _table_view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
}
- (void)inviteControllerDidFinish {
    [self dismissViewControllerAnimated:YES completion:^{
        [[[UIAlertView alloc] initWithTitle:@"Hooray!" message:@"Your invites have been sent!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)inviteControllerDidCancel {
    [self dismissViewControllerAnimated:YES completion:^{
        //[[[UIAlertView alloc] initWithTitle:@"Awe :(" message:@"Your invites were canceled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}
- (NSDictionary *)inviteUrlCustomData {
    return @{ };
}

- (NSString *)invitingUserId {
    return [CurrentUserModel sharedModel].userId;
}

- (NSString *)invitingUserFullname {
    return [CurrentUserModel sharedModel].userFullname;
}

- (NSString *)finvitingUserShortName {
    return [CurrentUserModel sharedModel].userShortName;
}

- (NSString *)invitingUserImageUrl {
    return [CurrentUserModel sharedModel].userImageUrl;
}

- (NSArray *)inviteContactProviders {
    
    return @[
             [BranchInviteTextContactProvider textContactProviderWithInviteMessageFormat:[NSString stringWithFormat:@"Hi,\n\nDownload POP and follow me so you\ncan vote on my photos and videos.\nMy user name is %@,\n\n Here's the link: https://itunes.apple.com/us/app/p-o-p/id1200362716?ls=1&mt=8", inviteName]],
             ];
}
#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self shiftKeyboardIfNecessary];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userFullnameField) {
        [self.userShortNameField becomeFirstResponder];
    }
    else if (textField == self.userShortNameField) {
        [self.userImageUrlField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.userFullnameField) {
        [CurrentUserModel sharedModel].userFullname = textField.text;
    }
    else if (textField == self.userShortNameField) {
        [CurrentUserModel sharedModel].userShortName = textField.text;
    }
    else {
        [CurrentUserModel sharedModel].userImageUrl = textField.text;
    }
}


#pragma mark - BranchReferralScore delegate

- (NSString *)referringUserId {
    return [CurrentUserModel sharedModel].userId;
}

- (void)branchReferralControllerCompleted {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Keyboard Management methods

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.keyboardFrame = keyboardFrame;
    
    [self shiftKeyboardIfNecessary];
}

- (void)keyboardWillHide:(NSNotification *)notification  {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = 0;
    self.view.frame = viewFrame;
}


#pragma mark - Internal methods

- (void)setUpCurrentUserIfNecessary {
    CurrentUserModel *sharedModel = [CurrentUserModel sharedModel];
    if (!sharedModel.userId) {
        sharedModel.userId = [NSUUID UUID].UUIDString;
        sharedModel.userFullname = @"Graham Mueller";
        sharedModel.userShortName = @"Graham";
        sharedModel.userImageUrl = @"https://www.gravatar.com/avatar/28ed70ee3c8275f1d307d1c5b6eddfa5";
    }
    
    self.userIdLabel.text = sharedModel.userId;
    self.userFullnameField.text = sharedModel.userFullname;
    self.userShortNameField.text = sharedModel.userShortName;
    self.userImageUrlField.text = sharedModel.userImageUrl;
}

- (void)shiftKeyboardIfNecessary {
    CGRect viewFrame = self.view.frame;
    CGRect activeTextFieldFrame = self.activeTextField.frame;
    CGFloat bottomPadding = 4;
    CGFloat lowestPointCoveredByKeyboard = -viewFrame.origin.y + viewFrame.size.height - self.keyboardFrame.size.height;
    CGFloat distanceActiveTextFieldIsUnderFrame = activeTextFieldFrame.origin.y + activeTextFieldFrame.size.height - lowestPointCoveredByKeyboard;
    
    if (distanceActiveTextFieldIsUnderFrame > 0) {
        viewFrame.origin.y -= distanceActiveTextFieldIsUnderFrame + bottomPadding;
        
        self.view.frame = viewFrame;
    }
}
-(void)GetUserProfileInfo
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid};
    
    [manager POST:@"get_user_profile" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             inviteName = [[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"];
             NSInteger act_status=(int)[[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"privacy_status"] integerValue];
             NSInteger notification_status=(int)[[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"is_notification"] integerValue];
             NSInteger comment_status=(int)[[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"is_comment"] integerValue];
             
             if (act_status == 1) {
                 [swichbtn setOn:YES];
             }
             else {
                 [swichbtn setOn:NO];
             }
             if(notification_status ==1) {
                 [swichbtn1 setOn:YES];
             }else {
                 [swichbtn1 setOn:NO];
             }
             if (comment_status ==1) {
                 [swichbtn2 setOn:YES];
             }else {
                 [swichbtn2 setOn:NO];
             }
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
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                     {
                                         
                                     }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }];
}

#pragma mark -Change Privacy
-(void)CallServiceChangePrivacy
{
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"privacy_status":privacy_Status};
    
    [manager POST:@"change_privacy_settings" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
         }
         else {
             UIAlertController * alert=   [UIAlertController
                                           alertControllerWithTitle:@"Alert!"
                                           message:@"Please Enter Valid Email and Password"
                                           preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
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
         
         UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
         }];
         [alert addAction:payAction];
         [self presentViewController:alert animated:YES completion:nil];
     }];
}
-(void)CallServiceChangeNotification {
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"notification_status":notification_Status};
    
    [manager POST:@"change_notification_settings" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
         }
         else {
             UIAlertController * alert=   [UIAlertController
                                           alertControllerWithTitle:@"Alert!"
                                           message:@"Please Enter Valid Email and Password"
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
-(void)CallServiceChangeComment
{
    NSString*userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"user_id":userid,@"comment_status":comment_Status};
    
    [manager POST:@"change_comment_settings" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
             
         }
         else {
             UIAlertController * alert=   [UIAlertController
                                           alertControllerWithTitle:@"Alert!"
                                           message:@"Please Enter Valid Email and Password"
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
-(void)viewWillDisappear:(BOOL)animated {
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section ==0) {
        return 3;
    }else if (section ==1) {
        return 3;
    }else if (section ==2) {
        return 3;
    }
    else if (section ==3) {
        return 0;
    }
    return 0;
}
#pragma mark- switchAction

- (IBAction)flip:(id)sender {
    if (swichbtn.on) {
        privacy_Status=@"1";
    }
    else {
        privacy_Status=@"0";
    }
    [self CallServiceChangePrivacy];
}
-(IBAction)notification:(id)sender {
    if (swichbtn1.on) {
        notification_Status = @"1";
    }else {
        notification_Status = @"0";
    }
    [self CallServiceChangeNotification];
}
-(IBAction)comment:(id)sender {
    if (swichbtn2.on) {
        comment_Status = @"1";
    }else {
        comment_Status =@"0";
    }
    [self CallServiceChangeComment];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = (int)indexPath.row;
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if(row == 0) {
                cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting1"];
                UIImageView *view = (UIImageView *)[cell viewWithTag:3];
                view.image = [UIImage imageNamed:@"editprofile.png"];
                ((UILabel*)[cell viewWithTag:4]).text = @"Edit Profile";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if(row == 1) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting2"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:5];
            view.image = [UIImage imageNamed:@"resetpassword.png"];
            ((UILabel*)[cell viewWithTag:6]).text = @"Reset Password";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if(row == 2) {
            
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting3"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:7];
            view.image = [UIImage imageNamed:@"privateaccount.png"];
            ((UILabel*)[cell viewWithTag:8]).text = @"Private Account";
            swichbtn = (UISwitch*)[cell viewWithTag: 17];
        }
    }else if (indexPath.section == 1) {
        if(row ==0) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:1];
            view.image = [UIImage imageNamed:@"invite.png"];
            ((UILabel*)[cell viewWithTag:2]).text = @"Invite Contacts to use POP";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if(row == 1) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting4"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:9];
            view.image = [UIImage imageNamed:@"turnoffnotification.png"];
            ((UILabel*)[cell viewWithTag:10]).text = @"Turn on/off notifications";
            swichbtn1 = (UISwitch*)[cell viewWithTag: 11];
        }
        if(row == 2) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting5"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:12];
            view.image = [UIImage imageNamed:@"turnoffcomment.png"];
            ((UILabel*)[cell viewWithTag:13]).text = @"Turn on/off Comments";
            swichbtn2 = (UISwitch*)[cell viewWithTag: 14];
        }
        
    }if (indexPath.section ==2){
        if(row ==0) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting6"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:18];
            view.image = [UIImage imageNamed:@"contact_icon.png"];
            ((UILabel*)[cell viewWithTag:19]).text = @"Contact Us";
        }
        if(row ==1) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting7"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:20];
            view.image = [UIImage imageNamed:@"terms_icon.png"];
            ((UILabel*)[cell viewWithTag:21]).text = @"Terms & Conditions";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if(row ==2) {
            cell =(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell_setting8"];
            UIImageView *view = (UIImageView *)[cell viewWithTag:15];
            view.image = [UIImage imageNamed:@"logout.png"];
            ((UILabel*)[cell viewWithTag:16]).text = @"Log Out";
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.table_view deselectRowAtIndexPath:indexPath animated:NO];
    selected_item = (int)indexPath.row;
    if (indexPath.section ==0){
        if (indexPath.row ==0) {
            EditProfileViewController *edit = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
            [self.navigationController pushViewController:edit animated:NO];
        }else if (indexPath.row ==1) {
            ResetPasswordViewController *password = [self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordViewController"];
            [self.navigationController pushViewController:password animated:NO];
        }
    }else if (indexPath.section ==1) {
       if (indexPath.row == 0) {
           id branchInviteViewController = [BranchInviteViewController branchInviteViewControllerWithDelegate:self];
           [self presentViewController:branchInviteViewController animated:YES completion:NULL];
       }
    }else if (indexPath.section ==2) {
        if (indexPath.row == 0) {
            NSString *emailTitle = @"Contact Mail";
            NSString *messageBody = @"Type your message";
            NSArray *toRecipents = [NSArray arrayWithObject:@"info@PopTheWorld.com"];
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:YES];
            [mc setToRecipients:toRecipents];
            [self presentViewController:mc animated:YES completion:nil];
        }else if (indexPath.row ==1) {
            termsViewController *term = [self.storyboard instantiateViewControllerWithIdentifier:@"termsViewController"];
            [self.navigationController pushViewController:term animated:NO];
        }else if (indexPath.row ==2) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Are you sure!"
                                          message:@"Do you want to logout?"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [alert addAction:payAction];
            UIAlertAction *payAction1 = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                 [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"LogInKey"];
                 [self performSegueWithIdentifier:@"logout" sender:nil];
                 [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            [alert addAction:payAction1];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"";
    if (section == 1)
        return @"";
    if (section == 2)
        return @"";
    if (section == 3)
        return @"";
    return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}
#pragma mark - MFMailComposerViewControllerDelegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
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
@end
