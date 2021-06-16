//
//  ProfileSettingViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "ProfileSettingViewController.h"
#import "AFHTTPSessionManager.h"
@interface ProfileSettingViewController ()
{
    NSData*  imagedata ;
}
@end

@implementation ProfileSettingViewController

-(void)CallServiceEditProfile {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString *userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    
        NSString *emailStr=[[NSUserDefaults standardUserDefaults]valueForKey:@"email"];
        NSString*Password=[[NSUserDefaults standardUserDefaults]valueForKey:@"Password"];

        AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
        [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSDictionary * params = @{@"email":emailStr,@"description":@"",@"user_name":_UserNameFld.text,@"website":@"",@"user_id":userid,@"password":Password};
    
        [manager POST:@"edit_profile" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imagedata name:@"profile_pic" fileName:@"pop.jpg" mimeType:@"image/jpeg"];
    
    }progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              NSLog(@"JSON: %@", responseObject);
              if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"TabBarViewkey" object:self];
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
          }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)PhotoBtn_Action:(id)sender {
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
#pragma mark imagePickerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage : (UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    _imageBtn.layer.cornerRadius = _imageBtn.frame.size.width / 2;
    _imageBtn.clipsToBounds = YES;
    [_imageBtn setBackgroundImage: image forState:UIControlStateNormal];
    
    CGFloat compression = 0.5f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    
    imagedata = UIImageJPEGRepresentation(image, compression);
    
    while ([imagedata length] > maxFileSize && compression > maxCompression){
        compression -= 0.1;
        imagedata = UIImageJPEGRepresentation(image, compression);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)doneAction:(id)sender {
    
    if (_UserNameFld.text.length==0||imagedata.length==0) {
      
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert!"
                                      message:@"Please select image and User Name"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                        
                                    }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"loginKey"];
        [self  CallServiceEditProfile];
    }
}
#pragma mark - TextField delegate starts

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
