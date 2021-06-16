//
//  AddPollViewController.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "AddPollViewController.h"
#import "AFHTTPSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PollCollectionViewCell.h"
#import "IGAssetsPicker.h"
#import "IGAssetsPickerViewController.h"
#import "Utility.h"
#import "TWPhotoPickerController.h"

@interface AddPollViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, IGAssetsPickerDelegate>
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
{
    NSArray * choicesArray, * mintArray,* hoursArray, * duratioArray ;
    NSMutableArray * imageArray,* imagePicArray;
    UIImagePickerController *ipc;
    NSInteger numberOfRow , selectedCell;
    NSString*timeSeletedStr;
    NSString*MediaCountStr;
    NSData *imagedata;
    NSString*postTypeStr;
    NSMutableArray*pollImagesArray;
    NSString*time;
    NSString*duration;
    NSString *media_type; NSString *moviePathStr;
    NSMutableArray*videopathArray;
    UIView *descriptionView;
}
@end

@implementation AddPollViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    videopathArray=[[NSMutableArray alloc]init];
    duration = @"MIN";
    MediaCountStr = @"1";
    time = @"0";
    pollImagesArray=[[NSMutableArray alloc]init];
    hoursArray = [[NSArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24", nil];
    choicesArray = [[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4", nil];
    mintArray = [[NSArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"30", nil];
    duratioArray = [[NSArray alloc]initWithObjects:@"MIN",@"HR", nil];
    imageArray = [[NSMutableArray alloc]init];
    imagePicArray = [[NSMutableArray alloc]init];
    [imageArray addObject:[UIImage imageNamed:@"add_box"]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if([_navTitleString isEqualToString:PHOTOPOLL]) {
        _voteLabel.text = @"Choose your photos for the vote";
        _titleLbl.text = @"Photo Poll";
    }
    else{
        _voteLabel.text = @"Choose you videos for the vote";
        _titleLbl.text = @"Video Poll";
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [_PostBtn setUserInteractionEnabled:YES];
}
#pragma mark-postPollWebService
-(void)CallPostPoll {
   
    [[Utility sharedObject] showMBProgress:self.view message:@""];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *userid=[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    if ([time isEqualToString:@"0"]||[time isEqualToString:@"0"]) {
        timeSeletedStr=time;
    }
    else {        timeSeletedStr=[NSString stringWithFormat:@"%@ %@",time,duration];
    }
    NSDictionary * params = @{@"poll_description":_DescriptionFld.text,@"media_type":media_type,@"poll_duration":timeSeletedStr,@"post_type":postTypeStr,@"user_id":userid,@"media_count":MediaCountStr, @"question": _question.text};
    [manager POST:@"add_poll_post" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if ([media_type isEqualToString:@"Image"]) {
            for(int i=0;i<[pollImagesArray count];i++) {
                UIImage*image=[pollImagesArray objectAtIndex:i];
                CGFloat compression = 0.5f;
                imagedata = UIImageJPEGRepresentation(image, compression);
                [formData appendPartWithFileData:imagedata name:@"media_name[]" fileName:[NSString stringWithFormat:@"pop%d.jpg",i ] mimeType:@"image/jpeg"];
            }
        }
        else {
            for(int i=0;i<[videopathArray count];i++) {
                NSData *videoData = videopathArray [i];
                [formData appendPartWithFileData:videoData name:@"media_name[]" fileName:[NSString stringWithFormat:@"pop%d.3gp",i ] mimeType:@"videoRecording.3gp"];
            }
        }
        for(int i=0;i<[pollImagesArray count];i++)
        {
            UIImage*image=[pollImagesArray objectAtIndex:i];
            CGFloat compression = 0.5f;
            imagedata = UIImageJPEGRepresentation(image, compression);
            [formData appendPartWithFileData:imagedata name:@"video_thumbnail[]" fileName:[NSString stringWithFormat:@"pop%d.jpg",i ] mimeType:@"thumbNail/jpeg"];
        }
    }
         progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             NSLog(@"JSON: %@", responseObject);
             if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
                  [[Utility sharedObject] hideMBProgress];
                  UIAlertController * alert=   [UIAlertController
                                                alertControllerWithTitle:@""
                                                message:@"Your poll has loaded successfully"
                                                preferredStyle:UIAlertControllerStyleAlert];
                  
                  UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"TabBarViewkey" object:self];
                  }];
                  [alert addAction:payAction];
                  [self presentViewController:alert animated:YES completion:nil];
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 NSLog(@"Error: %@", error);
                 [_PostBtn setUserInteractionEnabled:YES];
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Picker View Data source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(pickerView == _choicesPickerView) {
        return [choicesArray count];
    }
    else  if(pickerView == _optionsPickerView) {
        if([duration isEqualToString:@"MIN"])
          return [mintArray count];
        else
            return [hoursArray count];
    }
    else{
        return [duratioArray count];
    }
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow: (NSInteger)row forComponent:(NSInteger)component {
    if(pickerView == _choicesPickerView) {
        return choicesArray[row];
    }
    else if(pickerView == _optionsPickerView) {
        if([duration isEqualToString:@"MIN"])
        return mintArray[row];
        else
            return hoursArray[row];
    }
    else {
        return duratioArray[row];
    }
}

#pragma mark- Picker View Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(pickerView == _choicesPickerView) {
        for (UIView * vw in [_pollCollectionView subviews] ) {
          if([vw isKindOfClass:[UIView class]]) {
              [vw removeFromSuperview];
          }
        }
        [imageArray removeAllObjects];
        numberOfRow = row+1;
    
        switch (numberOfRow) {
            case 1:
                  [imageArray addObject:[UIImage imageNamed:@"add_box"]];
                break;
            case 2:
                for (int i = 0; i<= 1; i++) {
                    [imageArray addObject:[UIImage imageNamed:@"add_box"]];
                }
                break;
            case 3:
                for (int i = 0; i<= 2; i++) {
                    [imageArray addObject:[UIImage imageNamed:@"add_box"]];
                }
                break;
            case 4:
                for (int i = 0; i<= 3; i++) {
                    [imageArray addObject:[UIImage imageNamed:@"add_box"]];
                }
                break;
            default:
                break;
        }
          [_pollCollectionView reloadData];
          MediaCountStr=choicesArray[row];
    }
    else if(pickerView == _optionsPickerView){
            if([duration isEqualToString:@"MIN"])
                time=mintArray[row];
            else
                time=hoursArray[row];
    }
    else {
        duration=duratioArray[row];
        [_optionsPickerView reloadAllComponents];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 20;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (id)view;
    if (!label) {
        label= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        if(pickerView == _choicesPickerView) {
            label.text =choicesArray[row];
            label.backgroundColor = [UIColor colorWithRed:126/255.0 green:132/255.0 blue:157/255.0 alpha:0.5];
            label.font=FONTNAME_MONTSERRAT__BOLD_Size(16);
        }
        else if(pickerView == _optionsPickerView) {
             if([duration isEqualToString:@"MIN"]) {
                 label.text =  mintArray[row];
                 if([label.text isEqualToString:@"30"]) {
                     label.backgroundColor = [UIColor whiteColor];
                 }
                 else{
                    label.backgroundColor = [UIColor colorWithRed:126/255.0 green:132/255.0 blue:157/255.0 alpha:0.5];
                 }
                 label.font=FONTNAME_MONTSERRAT__BOLD_Size(16);
             }
             else {
                label.text =  hoursArray[row];
                label.font=FONTNAME_MONTSERRAT__BOLD_Size(14);
             }
         } else {
              label.text =  duratioArray[row];
              label.font=FONTNAME_MONTSERRAT__BOLD_Size(14);
              if([pickerView selectedRowInComponent:component] == row) {
                  if([label.text isEqualToString:@"MIN"])
                    label.backgroundColor = [UIColor colorWithRed:126/255.0 green:132/255.0 blue:157/255.0 alpha:0.5];
                  else
                      label.backgroundColor = [UIColor whiteColor];
              }
          }
       }
        return label;
}
#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return imageArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView * imgView =(UIImageView *) [cell viewWithTag:11];
    if(imagePicArray.count>0) {
     if(imagePicArray.count> indexPath.row) {
        if([[imagePicArray[indexPath.item]valueForKey:@"CellIndex"] isEqualToNumber:[NSNumber numberWithInteger:indexPath.row]]) {
            imgView.image = [imagePicArray[indexPath.item]valueForKey:@"ImageAndVideo"];
        }
        else{
            imgView.image = imageArray[indexPath.item];
        }
     }
     else{
             imgView.image = imageArray[indexPath.item];
         }
    }
    else {
        imgView.image = imageArray[indexPath.item];
    }
    switch (numberOfRow) {
        case 1:
             imgView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height );
            cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height );
            break;
        case 2:
            imgView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.width / 2);
            cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.width / 2 );

            break;
        case 3:
            if(indexPath.row == 1 || indexPath.row ==2) {
                imgView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.height / 2);
                cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.height / 2);
            }
            else {
                imgView.frame= CGRectMake(0, 0, collectionView.frame.size.width / 2 , collectionView.frame.size.height / 2);
                imgView.center = cell.center;
                cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width  , collectionView.frame.size.height /2);
            }
            break;
        case 4:
             imgView.frame= CGRectMake(0, 0,collectionView.frame.size.width / 2, collectionView.frame.size.height / 2);
             cell.contentView.frame= CGRectMake(0, 0,collectionView.frame.size.width / 2, collectionView.frame.size.height / 2);
            break;
        default:
            imgView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height );
            cell.contentView.frame= CGRectMake(0, 0, collectionView.frame.size.width, collectionView.frame.size.height );
            break;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (numberOfRow) {
        case 1:
            return CGSizeMake(collectionView.frame.size.width , collectionView.frame.size.height  );
            break;
        case 2:
            return CGSizeMake(collectionView.frame.size.width / 2 , collectionView.frame.size.width / 2 );
            break;
        case 3:
            if(indexPath.row == 1 || indexPath.row ==2)
            return CGSizeMake(collectionView.frame.size.width/2 , collectionView.frame.size.height/2);
            else
                return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height/2);
            break;
        case 4:
            return CGSizeMake(collectionView.frame.size.width / 2  , collectionView.frame.size.height / 2);
            break;
        default:
            return CGSizeMake(collectionView.frame.size.width , collectionView.frame.size.height  );
            break;
    }
 }
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedCell = indexPath.row;
    UIAlertController *actionSheet ;
    if([_navTitleString isEqualToString:PHOTOPOLL]) {
        actionSheet = [UIAlertController alertControllerWithTitle:@"Choose Image" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self takePhoto];
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }]];
    
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
             [self choosePhoto];
        }]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else {
        actionSheet = [UIAlertController alertControllerWithTitle:@"Choose Video" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Record Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *videoScreen = [[UIImagePickerController alloc] init];
            videoScreen.sourceType = UIImagePickerControllerSourceTypeCamera;
            videoScreen.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            videoScreen.allowsEditing = NO;
            videoScreen.delegate = self;
            
            [self presentViewController:videoScreen animated: YES completion:nil];
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self chooseVideo];
        }]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}
-(void)choosePhoto
{
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
    photoPicker.cropBlock = ^(UIImage *image) {
        media_type=@"Image";
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:image forKey:@"ImageAndVideo"];
        [dic setObject:[NSNumber numberWithInteger:selectedCell] forKey:@"CellIndex"];
        if(imagePicArray.count>0) {
            for (int i= 0; i<imagePicArray.count; i++) {
                if ([[imagePicArray[i]valueForKey:@"CellIndex"] isEqualToNumber:[NSNumber numberWithInteger:selectedCell]]) {
                    [pollImagesArray removeObjectAtIndex:i];
                    [imagePicArray removeObjectAtIndex:i];
                }
            }
        }
        [pollImagesArray insertObject:image atIndex:selectedCell];
        [imagePicArray insertObject:dic atIndex:selectedCell];
        
        [_pollCollectionView reloadData];
    };
    [self presentViewController:photoPicker animated:YES completion:NULL];
    /*
    IGAssetsPickerViewController *picker = [[IGAssetsPickerViewController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
     */
    
}
#pragma mark - choose Video
-(void)chooseVideo {
    ipc= [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    ipc.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    [self presentViewController:ipc animated:YES completion:nil];
    
    /*
     IGAssetsPickerViewController *picker = [[IGAssetsPickerViewController alloc] init];
     picker.delegate = self;
     dispatch_async(dispatch_get_main_queue(), ^{
         [self presentViewController:picker animated:YES completion:NULL];
     });
     */
}
#pragma mark - Take Photo From Camera

-(void)takePhoto {
    /*
    ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ipc animated:YES completion:NULL];
    }
     */
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
//    IGAssetsPickerViewController *picker = [[IGAssetsPickerViewController alloc] init];
//    picker.delegate = self;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        photoPicker.cropBlock = ^(UIImage *image) {
            media_type=@"Image";
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:image forKey:@"ImageAndVideo"];
            [dic setObject:[NSNumber numberWithInteger:selectedCell] forKey:@"CellIndex"];
            if(imagePicArray.count>0) {
                for (int i= 0; i<imagePicArray.count; i++) {
                    if ([[imagePicArray[i]valueForKey:@"CellIndex"] isEqualToNumber:[NSNumber numberWithInteger:selectedCell]]) {
                        [pollImagesArray removeObjectAtIndex:i];
                        [imagePicArray removeObjectAtIndex:i];
                    }
                }
            }
            [pollImagesArray insertObject:image atIndex:selectedCell];
            [imagePicArray insertObject:dic atIndex:selectedCell];
            
            [_pollCollectionView reloadData];
        };
        [self presentViewController:photoPicker animated:YES completion:NULL];
    }
    else {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:nil
                                      message:@"No Camera Available."
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
             [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    double ratio;
    double delta;
    CGPoint offset;
    CGSize sz = CGSizeMake(newSize.width, newSize.width);

    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }

    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   
    return newImage;
}
+ (UIImage *)imageToSquare:(UIImage *)image byWidth:(float)width {
    UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
    [view setImage:image];
    view.contentMode = UIViewContentModeScaleAspectFit;
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
#pragma mark - ImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    picker.videoQuality = UIImagePickerControllerQualityTypeLow;
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];

    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"movie"];
        moviePathStr = [[info objectForKey: UIImagePickerControllerMediaURL] path];
        NSData *videoData;
        videoData = [NSData dataWithContentsOfFile:  moviePathStr ];
        [picker dismissViewControllerAnimated:YES completion:nil];
    
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:moviePathStr] options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generateImg. appliesPreferredTrackTransform=YES;
        NSError *error = NULL;
        CMTime time1 = CMTimeMake(1, 65);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time1 actualTime:NULL error:&error];
        NSLog(@"error==%@, Refimage==%@", error, refImg);
        
        UIImage *ThumbImage= [[UIImage alloc] initWithCGImage:refImg];

        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:ThumbImage forKey:@"ImageAndVideo"];
        [dic setObject:[NSNumber numberWithInteger:selectedCell] forKey:@"CellIndex"];

        if(imagePicArray.count>0) {
            for (int i= 0; i<imagePicArray.count; i++) {
                if ([[imagePicArray[i]valueForKey:@"CellIndex"] isEqualToNumber:[NSNumber numberWithInteger:selectedCell]]) {
                    [imagePicArray removeObjectAtIndex:i];
                    [videopathArray removeObjectAtIndex:i];
                    
                }
            }
        }
        [videopathArray insertObject:videoData atIndex:selectedCell];

        [pollImagesArray insertObject:ThumbImage atIndex:selectedCell];
        [imagePicArray insertObject:dic atIndex:selectedCell];

        [_pollCollectionView reloadData];
        media_type=@"Video";
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        media_type=@"Image";
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:[info objectForKey:UIImagePickerControllerOriginalImage] forKey:@"ImageAndVideo"];
        [dic setObject:[NSNumber numberWithInteger:selectedCell] forKey:@"CellIndex"];
        UIImage*image=[info objectForKey:UIImagePickerControllerOriginalImage];
        
        
        if(imagePicArray.count>0) {
            for (int i= 0; i<imagePicArray.count; i++) {
                if ([[imagePicArray[i]valueForKey:@"CellIndex"] isEqualToNumber:[NSNumber numberWithInteger:selectedCell]]) {
                    [pollImagesArray removeObjectAtIndex:i];
                    [imagePicArray removeObjectAtIndex:i];
                }
            }
        }
        [pollImagesArray insertObject:image atIndex:selectedCell];
        [imagePicArray insertObject:dic atIndex:selectedCell];

        [_pollCollectionView reloadData];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }

}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark-button Actions
- (IBAction)post_Action:(id)sender {
    postTypeStr=@"Raguler";
    if ([media_type isEqualToString: @"Video"]) {
        if ( videopathArray.count==[MediaCountStr integerValue]) {
            [_PostBtn setUserInteractionEnabled:NO];
            [self CallPostPoll];
        }
    }
    else if ([media_type isEqualToString: @"Image"]) {
         if ( pollImagesArray.count==[MediaCountStr integerValue]) {
             [_PostBtn setUserInteractionEnabled:NO];
             [self CallPostPoll];
         }
    }
    if (_DescriptionFld.text.length >= 45) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Please Entry Again!"
                                      message:@"The length of the text must not exceed 44 characters"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (IBAction)backBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TextField delegate starts
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL shouldChange = YES;
    if(_DescriptionFld.text.length == 44){
        if(range.length + range.location > _DescriptionFld.text.length) {
            return NO;
        }
        NSUInteger newLength = [_DescriptionFld.text length] + [string length] - range.length;
        shouldChange = (newLength > 5) ? NO : YES;
        if(!shouldChange){
            return shouldChange;
        }
    }
    if(_question.text.length == 6000){
        if(range.length + range.location > _question.text.length) {
            return NO;
        }
        NSUInteger newLength = [_question.text length] + [string length] - range.length;
        shouldChange = (newLength > 5) ? NO : YES;
        if(!shouldChange){
            return shouldChange;
        }
    }
    return shouldChange;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - IGAssetsPickerDelegate

- (void)IGAssetsPickerFinishCroppingToAsset:(id)asset
{
     if ([asset isKindOfClass:[UIImage class]]) {
        media_type=@"Image";
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:(UIImage *)asset forKey:@"ImageAndVideo"];
        [dic setObject:[NSNumber numberWithInteger:selectedCell] forKey:@"CellIndex"];

        if(imagePicArray.count>0) {
            for (int i= 0; i<imagePicArray.count; i++) {
                if ([[imagePicArray[i]valueForKey:@"CellIndex"] isEqualToNumber:[NSNumber numberWithInteger:selectedCell]]) {
                    [pollImagesArray removeObjectAtIndex:i];
                    [imagePicArray removeObjectAtIndex:i];
                }
            }
        }
        [pollImagesArray insertObject:(UIImage *)asset atIndex:selectedCell];
        [imagePicArray insertObject:dic atIndex:selectedCell];

        [_pollCollectionView reloadData];

    }else {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@""
                                      message:@"Please check the photo"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *payAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self choosePhoto];
        }];
        [alert addAction:payAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
 
    else if ([asset isKindOfClass:[NSURL class]]) {
       
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"movie"];
            moviePathStr = [((NSURL *) asset) path];
            NSData *videoData;
            videoData = [NSData dataWithContentsOfFile:  moviePathStr ];
           
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:moviePathStr] options:nil];
            AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generateImg. appliesPreferredTrackTransform=YES;
            NSError *error = NULL;
            CMTime time1 = CMTimeMake(1, 65);
            CGImageRef refImg = [generateImg copyCGImageAtTime:time1 actualTime:NULL error:&error];
            NSLog(@"error==%@, Refimage==%@", error, refImg);
           
            UIImage *ThumbImage= [[UIImage alloc] initWithCGImage:refImg];
           
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:ThumbImage forKey:@"ImageAndVideo"];
            [dic setObject:[NSNumber numberWithInteger:selectedCell] forKey:@"CellIndex"];
           
            if(imagePicArray.count>0) {
                for (int i= 0; i<imagePicArray.count; i++) {
                    if ([[imagePicArray[i]valueForKey:@"CellIndex"] isEqualToNumber:[NSNumber numberWithInteger:selectedCell]]) {
                        [imagePicArray removeObjectAtIndex:i];
                        [videopathArray removeObjectAtIndex:i];
                        
                    }
                }
            }
            [videopathArray insertObject:videoData atIndex:selectedCell];
           
            [pollImagesArray insertObject:ThumbImage atIndex:selectedCell];
            [imagePicArray insertObject:dic atIndex:selectedCell];
           
            [_pollCollectionView reloadData];
            media_type=@"Video";
      
    }
 
}
  */

@end
