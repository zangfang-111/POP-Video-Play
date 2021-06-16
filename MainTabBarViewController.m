//
//  MainTabBarViewController.m
//  POP
//
//  Created by salentro on 11/10/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "AddPollViewController.h"
@interface MainTabBarViewController ()

{
    UIView * overlayView;
    BOOL  pollShowBool;
}
@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//     UIButton * popBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2-23, self.view.frame.size.height - self.tabBar.frame.size.height+1, 45, 45)];
//    
//    [popBtn setBackgroundImage:[UIImage imageNamed:@"like_circle.png"] forState:UIControlStateNormal];
//     [popBtn setTitle:@"POP" forState:UIControlStateNormal];
//    [popBtn addTarget:self action:@selector(showTabbar:) forControlEvents:UIControlEventTouchUpInside];
//    popBtn.layer.anchorPoint  = CGPointMake(0.5, 0.5);
//    //popBtn.layer.position = (CGPoint){CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)};
//    [self.view addSubview:popBtn];
//    self.tabBar.hidden = YES;
//    self.tabBarController.delegate = self;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
//    if(pollShowBool == YES)
//    {
//        [self showPoll];
//    }
//  
}
-(void)hidePool
{
    [overlayView removeFromSuperview];
    overlayView = nil;
}
-(void)showPoll
{
    [self hidePool];
  overlayView =  [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - self.tabBar.frame.size.height)];
    
  //  overlayView.backgroundColor = [UIColor redColor];

    overlayView.alpha = 0.8;
    UIView *   pollView = [[UIView alloc]initWithFrame:CGRectMake(0, overlayView.frame.size.height-110, overlayView.frame.size.width, 111)];
    pollView.backgroundColor = [UIColor whiteColor];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    bottomBorder.frame = CGRectMake(0, pollView.frame.size.height - 2, pollView.frame.size.width, 2);
    [pollView.layer addSublayer:bottomBorder];
    CALayer *topBorder = [CALayer layer];
    topBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    topBorder.frame = CGRectMake(0, 0, pollView.frame.size.width, 2);
    [pollView.layer addSublayer:topBorder];
    
    CALayer *ceneterBorder = [CALayer layer];
    ceneterBorder.backgroundColor = RGB(235.0, 235.0, 235.0).CGColor;
    ceneterBorder.frame = CGRectMake(0, 0, 2, pollView.frame.size.height);
    ceneterBorder.anchorPoint = CGPointMake(0.5, 0.5);
    ceneterBorder.position = (CGPoint){CGRectGetMidX(pollView.bounds), CGRectGetMidY(pollView.bounds)};
    [pollView.layer addSublayer:ceneterBorder];
    
    UIButton * photoBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, pollView.frame.size.width / 2, pollView.frame.size.height)];
    photoBtn.tag = 11;
    [photoBtn addTarget:self action:@selector(showPhotoAndVideoPoll:) forControlEvents:UIControlEventTouchUpInside];
    [pollView addSubview:photoBtn];
    
    UIImageView * photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(photoBtn.frame.size.width/2-20,  photoBtn.frame.size.height/2-30, 40, 40)];
    photoImage.image = [UIImage imageNamed:@"photo_icon"];
    [pollView addSubview:photoImage];
    
    UILabel * photoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,photoImage.frame.origin.y+photoImage.frame.size.height+5, photoBtn.frame.size.width , 20)];
    photoLabel.textColor = RGB(255.0, 176.0, 67.0);
    photoLabel.font = FONTNAME_MONTSERRAT__BOLD_Size(15);
    photoLabel.text = @"Start a Photo Poll";
    photoLabel.textAlignment = NSTextAlignmentCenter;
    [pollView addSubview:photoLabel];
    
    UIButton * videoBtn = [[UIButton alloc]initWithFrame:CGRectMake(photoBtn.frame.size.width +photoBtn.frame.origin.x, 0, pollView.frame.size.width / 2, pollView.frame.size.height)];
    videoBtn.tag = 12;
    [videoBtn addTarget:self action:@selector(showPhotoAndVideoPoll:) forControlEvents:UIControlEventTouchUpInside];
    [pollView addSubview:videoBtn];
    
    UIImageView * videoImage = [[UIImageView alloc]initWithFrame:CGRectMake(videoBtn.frame.size.width+videoBtn.frame.origin.x/2-20,  videoBtn.frame.size.height/2-30, 40, 40)];
    videoImage.image = [UIImage imageNamed:@"play_icon"];
    [pollView addSubview:videoImage];
    
    UILabel * videoLabel = [[UILabel alloc]initWithFrame:CGRectMake(videoBtn.frame.size.width,videoImage.frame.origin.y+videoImage.frame.size.height+5, videoBtn.frame.size.width , 20)];
    videoLabel.textColor = RGB(255.0, 176.0, 67.0);
    videoLabel.font = FONTNAME_MONTSERRAT__BOLD_Size(15);
    videoLabel.text = @"Start a Video Poll";
    videoLabel.textAlignment = NSTextAlignmentCenter;
    [pollView addSubview:videoLabel];
    [overlayView addSubview:pollView];
    [self.view addSubview:overlayView];

}

#pragma mark - Events

-(void)showTabbar:(UIButton *)sender
{
    [self hidePool];

    sender.selected  = ! sender.selected;
    
    if ([sender isSelected])
    {
        self.tabBar.hidden = NO;
    }
    else{
        self.tabBar.hidden = YES;
    }
}
-(void)showPhotoAndVideoPoll:(UIButton *)sender
{
    [self hidePool];
    sender.selected  = ! sender.selected;
    if(sender.tag == 11)
    {
        pollShowBool = YES;
        [self performSegueWithIdentifier:@"addPollViewID" sender:sender];
    }
    else{
        pollShowBool = YES;
        [self performSegueWithIdentifier:@"addPollViewID" sender:sender];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabBarController Delegate
- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController {
    NSUInteger indexOfTab = [theTabBarController.viewControllers indexOfObject:viewController];
    NSLog(@"Tab index = %d", (int)indexOfTab);
}

-(void)tabBar:(UITabBar *)theTabBar didSelectItem:(UIViewController *)viewController
{
   // NSLog(@"Tab index = %@ ", theTabBar.selectedItem);
//    if (theTabBar.selectedItem.tag == 13) {
//        [self showPoll];
//        pollShowBool = YES;
//    }
//    else
//    {
//        [self hidePool];
//        pollShowBool = NO;
//    }
    //NSlog(@"Items = %@", theTabBar.items[0]);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"addPollViewID"])
    {
        AddPollViewController * addpoolView = [segue destinationViewController];
        if(btn.tag == 11)
        {
            addpoolView.navTitleString= PHOTOPOLL;

        }
        else{
             addpoolView.navTitleString= VIDEOPOLL;
        }
    }
}


@end
