


#import <UIKit/UIView.h>

@class UIBarButtonItem;


@interface UIView (IQToolbarAddition)



@property (assign, nonatomic) BOOL shouldHideTitle;


@property (nullable, strong, nonatomic) NSString* placeholderText;

@property (nullable, strong, nonatomic, readonly) NSString* drawingPlaceholderText;


-(void)setTitleTarget:(nullable id)target action:(nullable SEL)action;


@property (nullable, strong, nonatomic) NSInvocation *titleInvocation;

-(void)setCustomPreviousTarget:(nullable id)target action:(nullable SEL)action;


-(void)setCustomNextTarget:(nullable id)target action:(nullable SEL)action;

-(void)setCustomDoneTarget:(nullable id)target action:(nullable SEL)action;


@property (nullable, strong, nonatomic) NSInvocation *previousInvocation;


@property (nullable, strong, nonatomic) NSInvocation *nextInvocation;


@property (nullable, strong, nonatomic) NSInvocation *doneInvocation;


- (void)addDoneOnKeyboardWithTarget:(nullable id)target action:(nullable SEL)action;


- (void)addDoneOnKeyboardWithTarget:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;

- (void)addDoneOnKeyboardWithTarget:(nullable id)target action:(nullable SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

- (void)addRightButtonOnKeyboardWithText:(nullable NSString*)text target:(nullable id)target action:(nullable SEL)action;


- (void)addRightButtonOnKeyboardWithText:(nullable NSString*)text target:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;


- (void)addRightButtonOnKeyboardWithText:(nullable NSString*)text target:(nullable id)target action:(nullable SEL)action shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;


- (void)addRightButtonOnKeyboardWithImage:(nullable UIImage*)image target:(nullable id)target action:(nullable SEL)action shouldShowPlaceholder:(BOOL)showPlaceholder;


- (void)addRightButtonOnKeyboardWithImage:(nullable UIImage*)image target:(nullable id)target action:(nullable SEL)action titleText:(nullable NSString*)titleText;


- (void)addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction;


- (void)addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction titleText:(nullable NSString*)titleText;


- (void)addCancelDoneOnKeyboardWithTarget:(nullable id)target cancelAction:(nullable SEL)cancelAction doneAction:(nullable SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

- (void)addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction;

- (void)addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;


- (void)addLeftRightOnKeyboardWithTarget:(nullable id)target leftButtonTitle:(nullable NSString*)leftButtonTitle rightButtonTitle:(nullable NSString*)rightButtonTitle leftButtonAction:(nullable SEL)leftButtonAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;


- (void)addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction;


- (void)addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction titleText:(nullable NSString*)titleText;


- (void)addPreviousNextDoneOnKeyboardWithTarget:(nullable id)target previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction doneAction:(nullable SEL)doneAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;

- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction;


- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;


- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonTitle:(nullable NSString*)rightButtonTitle previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;


- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction titleText:(nullable NSString*)titleText;


- (void)addPreviousNextRightOnKeyboardWithTarget:(nullable id)target rightButtonImage:(nullable UIImage*)rightButtonImage previousAction:(nullable SEL)previousAction nextAction:(nullable SEL)nextAction rightButtonAction:(nullable SEL)rightButtonAction shouldShowPlaceholder:(BOOL)shouldShowPlaceholder;



- (void)setEnablePrevious:(BOOL)isPreviousEnabled next:(BOOL)isNextEnabled;

@end


