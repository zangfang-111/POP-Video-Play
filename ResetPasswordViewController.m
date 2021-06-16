//
//  ResetPasswordViewController.m
//  POP
//
//  Created by KingTon on 9/4/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "AFHTTPSessionManager.h"
#import <MessageUI/MessageUI.h>
@interface ResetPasswordViewController () {
    NSString *loginType;
    NSString *oldPassword;
}

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _descriptionlbl.frame = CGRectMake(self.view.frame.origin.x + self.view.frame.size.width/2 - _descriptionlbl.frame.size.width/2, 160, self.view.frame.size.width, _descriptionlbl.frame.size.height);
    _passwordview.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height);
    _oldpassword.frame = CGRectMake(_passwordview.frame.origin.x + 60, _passwordview.frame.origin.y +8 , _passwordview.frame.size.width - 120, _oldpassword.frame.size.height);
    _newpassword.frame = CGRectMake(_passwordview.frame.origin.x + 60, _oldpassword.frame.origin.y + _oldpassword.frame.size.height +30 , _passwordview.frame.size.width - 120, _newpassword.frame.size.height);
    _confirmpassword.frame = CGRectMake(_passwordview.frame.origin.x + 60, _newpassword.frame.origin.y +  _newpassword.frame.size.height +30 , _passwordview.frame.size.width - 120, _newpassword.frame.size.height);
    _submit.frame = CGRectMake(_passwordview.frame.origin.x + self.view.frame.size.width - _submit.frame.size.width -60, _confirmpassword.frame.origin.y + _confirmpassword.frame.size.height +20, _submit.frame.size.width, _submit.frame.size.height);
    
    
    
}
-(void)CallServiceEditProfile
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
	 NSString *userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary * params = @{ @"user_id":userid, @"new_password":_newpassword.text, @"old_password":_oldpassword.text};
    
    
    [manager POST:@"edit_profile" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    
    }
     
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
              
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              NSLog(@"JSON: %@", responseObject);
              if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
                  UIAlertController * alert=   [UIAlertController
                                                alertControllerWithTitle:@""
                                                message:@"Your profile has been successfully updated."
                                                preferredStyle:UIAlertControllerStyleAlert];
                  
                  UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                              {
                                                  
                                                  [self .navigationController popViewControllerAnimated:YES ];
                                              }];
                  [alert addAction:payAction];
                  [self presentViewController:alert animated:YES completion:nil];
                  
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
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"]isEqualToString:@"true"] ) {
             
             oldPassword=[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"password"];
             
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)submit:(id)sender {
    if ([loginType isEqualToString:@""] ) {
        
        if (_oldpassword.text.length==0 || _oldpassword.text != oldPassword) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Please Correct Enter Old Password."
                                          message:@"Your password is incorrect."
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                        {
                                            
                                        }];
            [alert addAction:payAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            
        }
        else
        {
            if (_newpassword.text.length==0) {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Please Enter New Password."
                                              message:@"New Password field is empty."
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                            {
                                                
                                            }];
                [alert addAction:payAction];
                [self presentViewController:alert animated:YES completion:nil];
                
            }
            else
                
                [self CallServiceEditProfile];
            
        }
        if (_newpassword.text != _confirmpassword.text){
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Please Correct Enter Confirm Password."
                                          message:@"Your password is incorrect."
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                        {
                                            
                                        }];
            [alert addAction:payAction];
            [self presentViewController:alert animated:YES completion:nil];

        }
        
    }
    else
    {
        
        [self CallServiceEditProfile];
    }

}

@end
