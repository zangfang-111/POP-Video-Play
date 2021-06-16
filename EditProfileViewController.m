//
//  EditProfileViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "EditProfileViewController.h"
#import "AFHTTPSessionManager.h"
#import <MessageUI/MessageUI.h>
@interface EditProfileViewController ()
{
    NSData*  imagedata ;
    NSString *device_id,*privacy_Status;
    NSString *loginType;
    BOOL pop;
}
@end

@implementation EditProfileViewController
@synthesize swichbtn;
-(void)GetUserProfileInfo {
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
             
             _bgScrollView.contentSize=CGSizeMake(self.view.frame.size.width, 550);
             _profilePicBtn.layer.cornerRadius=_profilePicBtn.frame.size.width/2;
             _profilePicBtn.clipsToBounds=YES;
             
             _nameTxtField.text=[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"user_name"];
             NSString*profileimg=[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"profile_pic"];
             loginType =[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"login_type"];
             _userImageView.layer.cornerRadius = _userImageView.frame.size.width / 2;
             _userImageView.clipsToBounds = YES;
             NSURL *url = [NSURL URLWithString:profileimg];
             _userImageView.imageURL=url;
             imagedata = [NSData dataWithContentsOfURL:url];
             
             NSInteger status=[[[[responseObject valueForKey:@"data"]valueForKey:@"result"] valueForKey:@"privacy_status"] integerValue];
             
             if (status ==1) {
                 [swichbtn setOn:YES];
             }
             else {
                 [swichbtn setOn:NO];
             }
             
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
     }];
}
-(void)viewWillAppear:(BOOL)animated
{
    if (  pop==YES) {
        pop=NO;
    }
    else {
        [self GetUserProfileInfo];
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIBarButtonItem *refreshButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(Save_Action:)] ;
    self.navigationItem.rightBarButtonItem = refreshButton;
}
#pragma  mark -Button Actions

- (IBAction)Save_Action:(id)sender {
    if ([loginType isEqualToString:@""]) {
        
        if (_nameTxtField.text.length==0) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Please Enter Username."
                                          message:@"User Name field is empty."
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                        {
                                            
                                        }];
            [alert addAction:payAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else
            [self CallServiceEditProfile];
    }
    
    
}

- (IBAction)EditImage_Action:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Select Profile Photo"
                                                                   message:@"Choose Image From."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* GalleryAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                              picker.delegate = self;
                                                              picker.allowsEditing = YES;
                                                              picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                              [self presentViewController:picker animated:YES completion:nil];
                                                          }];
    
    [alert addAction:GalleryAction];
    
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                             picker.delegate = self;
                                                             picker.allowsEditing = YES;
                                                             picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                             [self presentViewController:picker animated:YES completion:nil];
                                                             
                                                         }];
    
    [alert addAction:cameraAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)profilePicBtnTapped:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - Image Picker Delegates

#pragma mark imagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
      didFinishPickingImage : (UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo
{
    _userImageView.layer.cornerRadius = _userImageView.frame.size.width / 2;
    _userImageView.clipsToBounds = YES;
    _userImageView .image=image;
    CGFloat compression = 0.5f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    
    imagedata = UIImageJPEGRepresentation(image, compression);
    
    while ([imagedata length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imagedata = UIImageJPEGRepresentation(image, compression);
    }
     pop=YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -Edit profile
-(void)CallServiceEditProfile
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSString *userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary * params = @{@"user_id":userid, @"user_name":_nameTxtField.text};
    
    
    [manager POST:@"edit_profile" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    
        [formData appendPartWithFileData:imagedata name:@"profile_pic" fileName:@"pop.jpg" mimeType:@"image/jpeg"];
    }
     
         progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
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
              
              
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
             NSLog(@"Error: %@", error);
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              UIAlertController * alert=   [UIAlertController
                                            alertControllerWithTitle:@""
                                            message:@"This user name is already exists !"
                                            preferredStyle:UIAlertControllerStyleAlert];
              
              UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                          {
                                              
                                              [self .navigationController popViewControllerAnimated:YES ];
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
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
           [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
             
             if ([privacy_Status isEqualToString:@"1"]) {
                 UIAlertController * alert=   [UIAlertController
                                               alertControllerWithTitle:@"Privacy is on!"
                                               message:@"Only your followers can see your stuff"
                                               preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                             {
                                                 
                                             }];
                 [alert addAction:payAction];
                 [self presentViewController:alert animated:YES completion:nil];
  
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
     }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
         [textView resignFirstResponder];
         return YES;
    }
    else
        return NO;
}

#pragma mark - TextField delegate starts
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
