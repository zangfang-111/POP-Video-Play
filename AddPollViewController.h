//
//  AddPollViewController.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
@interface AddPollViewController : UIViewController<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic, assign) NSNumber* maxLength;
@property (strong, nonatomic) IBOutlet UIView *pollView;
@property (strong, nonatomic) IBOutlet UIPickerView *choicesPickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *timePickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *optionsPickerView;
@property (strong, nonatomic) IBOutlet UICollectionView *pollCollectionView;
@property (strong, nonatomic) NSString *navTitleString;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *voteLabel;
@property (weak, nonatomic) IBOutlet UIView *postView;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet UIView *questionView;
@property (weak, nonatomic) IBOutlet UITextField *DescriptionFld;
@property (weak, nonatomic) IBOutlet UIButton *PostBtn;
@property (weak, nonatomic) IBOutlet UITextField * question;
@property (weak, nonatomic) IBOutlet UIImageView *choicesImgView;
@property (weak, nonatomic) IBOutlet UIImageView *TimerImgView;
@property (weak, nonatomic) IBOutlet UIImageView *optionsView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)backBtnAction:(id)sender;

@end
