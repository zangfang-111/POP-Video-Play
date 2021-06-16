

#import <UIKit/UIToolbar.h>


@interface IQToolbar : UIToolbar <UIInputViewAudioFeedback>


@property(nullable, nonatomic, strong) UIFont *titleFont;


@property(nullable, nonatomic, strong) NSString *doneTitle;


@property(nullable, nonatomic, strong) UIImage *doneImage;


@property(nullable, nonatomic, strong) NSString *title;


-(void)setTitleTarget:(nullable id)target action:(nullable SEL)action;


@property (nullable, strong, nonatomic) NSInvocation *titleInvocation;

@end

