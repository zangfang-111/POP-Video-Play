//
//  AppFlowViewController.h
//  Glamr Crew
//
//  Created by salentro on 5/24/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppFlowViewController : UIViewController<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)crossBtnAction:(id)sender;

@end
