//
//  AppFlowViewController.m
//  Glamr Crew
//
//  Created by salentro on 5/24/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import "AppFlowViewController.h"
#import "AsyncImageView.h"
#import "AppEntryViewViewController.h"
@interface AppFlowViewController ()

{
    NSArray * imageArray;
}
@end

@implementation AppFlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _scrollView.layer.borderWidth = 0;
    _scrollView.layer.borderColor = [[UIColor clearColor] CGColor];
    imageArray=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"Picture1.png"],[UIImage imageNamed:@"Picture2.png"],[UIImage imageNamed:@"Picture3.png"],[UIImage imageNamed:@"Picture4.png"],[UIImage imageNamed:@"Picture5.png"],[UIImage imageNamed:@"Picture6.png"],[UIImage imageNamed:@"Picture7.png"],[UIImage imageNamed:@"Picture8.png"],[UIImage imageNamed:@"Picture9.png"],[UIImage imageNamed:@"Picture10.png"], nil];
        
    
        for (int i = 0; i < [imageArray count]; i++) {
            //We'll create an imageView object in every 'page' of our scrollView.
            CGRect frame;
            frame.origin.x = _scrollView.frame.size.width * i;
            frame.origin.y = 0;
            frame.size = _scrollView.frame.size;
            
            AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:frame];
            imageView.image = [imageArray objectAtIndex:i];
            [imageView setUserInteractionEnabled:YES];
            [self.scrollView  setUserInteractionEnabled:YES];
            [self.scrollView addSubview:imageView];
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * [imageArray count],0);

    
    }
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - StatusBarHidden

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Events

- (IBAction)changePage:(id)sender {
    CGFloat x = _pageControl.currentPage * _scrollView.frame.size.width;
    [_scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

#pragma mark - UIScrollView Delegates

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
    NSInteger pageNumber = roundf(scrollView.contentOffset.x / (scrollView.frame.size.width));
    _pageControl.currentPage = pageNumber;
}
- (IBAction)crossBtnAction:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppEntryViewViewController*initView =  (AppEntryViewViewController*)[storyboard instantiateViewControllerWithIdentifier:@"appEntryId"];
    [initView setModalPresentationStyle:UIModalPresentationFullScreen];
    [self.navigationController pushViewController:initView animated:YES];
}
@end
