//
//  LogInViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "LogInViewController.h"
#import "AFHTTPSessionManager.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import <bolts/bolts.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Twitter/Twitter.h>
#import "FHSTwitterEngine.h"

@interface LogInViewController () {
    NSString *password,*first_name,*gender,*country,*last_name,*device_id,*user_type,*email,*  birthDay,*emailText;
    NSData *myData;  NSString *userName; UIImage *image;NSString*authntication_idStr;  NSMutableArray *arrayNameData;
}
@end

@implementation LogInViewController
-(void)CallWebserviceLogin {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"email":_emailTxtFiled.text,@"device_id":device_id,@"password":_passwordTxtFiled.text};
    
    [manager POST:@"login" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
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
             UIAlertController * alert=   [UIAlertController
                                           alertControllerWithTitle:@"Your Email and Password is Incorrent!"
                                           message:@"Please Enter Valid Email and Password"
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

- (void)viewDidLoad {
      [super viewDidLoad];
      [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
      device_id=[[NSUserDefaults standardUserDefaults]valueForKey:@"token"];
        [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"l58WlIOnj4SyCgQul3fDOk6j1" andSecret:@"IKK8q6ZHvEIW8D13SpmeBo94KxJKgsQRHIJJWY700y65synHFB"];
        [[FHSTwitterEngine sharedEngine]setDelegate:self];
        [[FHSTwitterEngine sharedEngine]loadAccessToken];
}
-(IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginBtnAction:(id)sender{
    if (_emailTxtFiled.text.length==0||_passwordTxtFiled.text.length==0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert!"
                                      message:@"Please Enter Valid Email and Password"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self CallWebserviceLogin];
    }
}
-(IBAction)FbLogin_Action:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logOut];
    
    [login logInWithReadPermissions:@[@"email", @"user_friends",@"user_birthday",@"user_photos"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
     
     {
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
-(IBAction)Twitter_Action:(id)sender {
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

-(IBAction)forgotPswrd_action:(id)sender
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Forgot Password!"
                                  message:@"Please enter your email"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                       emailText = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
                                                       
                                                       NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                                                       NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                                                       if ([emailTest evaluateWithObject:emailText] == NO)
                                                       {
                                                           UIAlertController * alert=   [UIAlertController
                                                                                         alertControllerWithTitle:@"Alert!"
                                                                                         message:@"Please enter valid email"
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                                           
                                                           UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                                                       {
                                                                                           
                                                                                       }];
                                                           [alert addAction:payAction];
                                                           [self presentViewController:alert animated:YES completion:nil];
                                                       }
                                                       
                                                       else{
                                                           [self CallForgotPassword];
                                                       }
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Email";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark :forgot Password
-(void)CallForgotPassword
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary * params = @{@"email":emailText};
    
    [manager POST:@"forget_password" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"])
         {
             
             UIAlertController * alert=   [UIAlertController
                                           alertControllerWithTitle:@"Password sent to email!"
                                           message:@"Please check your email"
                                           preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                         {
                                             
                                         }];
             [alert addAction:payAction];
             [self presentViewController:alert animated:YES completion:nil];
                }
         else
         {
             UIAlertController * alert=   [UIAlertController
                                           alertControllerWithTitle:@"Alert!"
                                           message:@"Please enter valid email"
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
#pragma mark :fetchUserInfo from facebook
-(void)fetchUserInfo {
    if ([FBSDKAccessToken currentAccessToken])
    {
        NSString *fbAccessToken =  [FBSDKAccessToken currentAccessToken].tokenString;
        NSLog(@"Token is %@",fbAccessToken);
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"picture.type(large), email,first_name, last_name"}]
         
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
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
    
    [manager POST:@"facebook_sign_up" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    
    [formData appendPartWithFileData:myData
                                name:@"profile_pic"
                            fileName:@"pop.jpg"
                            mimeType:@"image/jpeg"];
    }
     
         progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
         else  {
             [self CallTwitterLogin];
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
#pragma mark - TextField delegate starts

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
