
//  SignUpViewController.m
//  POP
//
//  Created by salentro on 11/9/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import "SignUpViewController.h"
#import "ProfileSettingViewController.h"
#import "AFHTTPSessionManager.h"
#import <bolts/bolts.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Twitter/Twitter.h>
#import "FHSTwitterEngine.h"
#import "LogInViewController.h"
@interface SignUpViewController ()
{
    NSString *password,*first_name,*gender,*country,*last_name,*device_id,*user_type,*email,*  birthDay,*emailText;
    NSData *myData;  NSString *userName; UIImage *image;NSString*authntication_idStr;  NSMutableArray *arrayNameData;
}
@end

@implementation SignUpViewController

-(void)ApiCallUserSignup {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"email":_emailTxtFiled.text,@"device_id":device_id,@"password":_passwordTxtFiled.text,@"user_name":@""};
    
    [manager POST:@"sign_up"
       parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
       }
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              NSLog(@"JSON: %@", responseObject);
              [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"LogInKey"];
              
              if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
                  NSString*email=[[responseObject valueForKey:@"data"] valueForKey:@"email"];
                  [[NSUserDefaults standardUserDefaults ]setObject:email forKey:@"email"];
                  
                  [[NSUserDefaults standardUserDefaults ]setObject:_passwordTxtFiled.text forKey:@"Password"];
                  
                  NSString*userid=[[responseObject valueForKey:@"data"] valueForKey:@"user_id"];
                  [[NSUserDefaults standardUserDefaults ]setObject:userid forKey:@"userid"];
                  [self performSegueWithIdentifier: @"ProfileSettingViewController" sender: self];
              }
              else {
                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                  UIAlertController * alert=   [UIAlertController
                                                alertControllerWithTitle:@"This email is already exist!"
                                                message:@"Please enter another"
                                                preferredStyle:UIAlertControllerStyleAlert];
                  
                  UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                              {
                                                  
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

- (void)viewDidLoad {
    [super viewDidLoad];
    device_id=[[NSUserDefaults standardUserDefaults]valueForKey:@"token"];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark :ButtonActions
-(IBAction)done_Action:(id)sender
{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if ([emailTest evaluateWithObject:_emailTxtFiled.text] == NO)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Your Email and Password is Incorrect!"
                                      message:@"Please valid email and password !"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    else  if (_emailTxtFiled.text.length==0||_passwordTxtFiled.text.length==0) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert!"
                                      message:@"Please Add Email & Password First"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    else
    {
        [self ApiCallUserSignup];
        
    }
}
-(IBAction)FbLogin_Action:(id)sender
{
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logOut];
    
    [login logInWithReadPermissions:@[@"email", @"user_friends",@"user_birthday",@"user_photos"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error)
         {
             NSLog(@"error is :%@",error);
         }
         else if (result.isCancelled)
         {
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             NSLog(@"error is :%@",error);
         }
         else
         {
             if ([result.grantedPermissions containsObject:@"email"])
             {
                 NSLog(@"Login successfull");
                 [self fetchUserInfo];
             }
         }
     }];
    
    
}
-(IBAction)Twitter_Action:(id)sender
{
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        NSLog(success?@"success":@"O noes!!! Loggen faylur!!!");
        
        if (success) {
            NSLog(@"%@", FHSTwitterEngine.sharedEngine.authenticatedID);
            NSLog(@"%@", FHSTwitterEngine.sharedEngine.authenticatedUsername);
            authntication_idStr= FHSTwitterEngine.sharedEngine.authenticatedID;
            userName=FHSTwitterEngine.sharedEngine.authenticatedUsername;
            [self CallTwitterLogin];
        }
    }];
    
    [self presentViewController:loginController animated:YES completion:nil];
    [[FHSTwitterEngine sharedEngine]loadAccessToken];

}
#pragma mark :fetchUserInfo from facebook
-(void)fetchUserInfo
{
    
    if ([FBSDKAccessToken currentAccessToken])
    {
        NSString *fbAccessToken =  [FBSDKAccessToken currentAccessToken].tokenString;
        
        NSLog(@"Token is %@",fbAccessToken);
        
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture.type(large), email,first_name, last_name"}]
         
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error)
             {
                 NSLog(@"result : %@",result);
                 
                 
                 NSDictionary *dic = [NSDictionary dictionaryWithObject:[result objectForKey:@"id"] forKey:@"name"];
                 
                 
                 NSLog(@"data in dict is %@",dic);
                 email=[result objectForKey:@"email"];
               
                 NSString *imagestr=[[[result objectForKey:@"picture"]objectForKey:@"data"] valueForKey:@"url"];
                 
                 NSURL *url = [NSURL URLWithString:imagestr];
                 myData = [NSData dataWithContentsOfURL:url];
                 image = [[UIImage alloc] initWithData:myData];
                 
                 [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"profile_pic"];
                 
                 [[NSUserDefaults standardUserDefaults]setValue:email forKey:@"email"];
                 //[[NSUserDefaults standardUserDefaults]setValue:id1 forKey:@"faceID"];
                 [[NSUserDefaults standardUserDefaults]setValue:userName forKey:@"myname"];
                 
                 NSLog(@"%@",gender);
                 NSLog(@"%@,%@",userName,email);
                 
                 
                 NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                 [dateFormat setDateFormat:@"yyyy"];
                 password=@"NA";
                 first_name=[result objectForKey:@"first_name"];
                 country=[result objectForKey:@"no"];
                 last_name=[result objectForKey:@"last_name"];
                 userName=[NSString stringWithFormat:@"%@ %@",first_name,last_name];
                 
                 [self CallFacebookLogin];
             }
         }];
    }
}
#pragma mark : CallLoginService AfterFetching Data
-(void)CallFacebookLogin
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"email":email,@"device_id":device_id};
    
    [manager POST:@"facebook_login" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
             NSString *userid=[[responseObject valueForKey:@"data"] valueForKey:@"user_id"];
             [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"TabBarViewkey" object:self];
             
         }
         else
         {
             [self CallFacebookDataRegiater];
             [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"loginKey"];
             
         }
         
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
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


-(void)CallFacebookDataRegiater
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"email":email,@"device_id":device_id,@"user_name":userName};
    
    [manager POST:@"facebook_sign_up"
       parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           
           [formData appendPartWithFileData:myData
                                       name:@"profile_pic"
                                   fileName:@"pop.jpg"
                                   mimeType:@"image/jpeg"];
       }
     
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              NSLog(@"JSON: %@", responseObject);
              if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
                  NSString *userid=[[responseObject valueForKey:@"data"] valueForKey:@"user_id"];
                  [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"TabBarViewkey" object:self];
                  
              }
              else
              {
                  UIAlertController * alert=   [UIAlertController
                                                alertControllerWithTitle:@"Error!"
                                                message:@"Please try again later"
                                                preferredStyle:UIAlertControllerStyleAlert];
                  
                  UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                              {
                                                  
                                              }];
                  [alert addAction:payAction];
                  [self presentViewController:alert animated:YES completion:nil];
                  
              }
              
              
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
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
-(void)CallTwitterLogin
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"authentication_id":authntication_idStr,@"device_id":device_id};
    
    [manager POST:@"twitter_login" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
             NSString *userid=[[responseObject valueForKey:@"data"] valueForKey:@"user_id"];
             [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"TabBarViewkey" object:self];
             
         }
         else
         {
             [self CallTwitterSignup];
             [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"loginKey"];
             
         }
         
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
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
-(void)CallTwitterSignup
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"authentication_id":authntication_idStr,@"device_id":device_id,@"user_name":userName};
    
    [manager POST:@"twitter_sign_up" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
             NSString *userid=[[responseObject valueForKey:@"data"] valueForKey:@"user_id"];
             [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"TabBarViewkey" object:self];
             
         }
         else
         {
             [self CallTwitterLogin];
             [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"loginKey"];
             
         }
         
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
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

-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark - TextField delegate starts

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    return YES;
}
-(IBAction)login:(id)sender {
    [self performSegueWithIdentifier:@"LogInViewController" sender:nil];
}
@end
