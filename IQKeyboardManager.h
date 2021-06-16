

#import "IQKeyboardManagerConstants.h"

#import <CoreGraphics/CGBase.h>

#import <Foundation/NSObject.h>
#import <Foundation/NSObjCRuntime.h>

#import <UIKit/UITextInputTraits.h>
#import <UIKit/UIView.h>

@class UIFont;


extern NSInteger const kIQDoneButtonToolbarTag;


extern NSInteger const kIQPreviousNextButtonToolbarTag;




@interface IQKeyboardManager : NSObject


+ (nonnull instancetype)sharedManager;

@property(nonatomic, assign, getter = isEnabled) BOOL enable;


@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;


@property(nonatomic, assign) BOOL preventShowingBottomBlankSpace;


- (void)reloadLayoutIfNeeded;


@property(nonatomic, assign, getter = isEnableAutoToolbar) BOOL enableAutoToolbar;


@property(nonatomic, assign) IQAutoToolbarManageBehaviour toolbarManageBehaviour;


@property(nonatomic, assign) BOOL shouldToolbarUsesTextFieldTintColor;


@property(nullable, nonatomic, strong) UIColor *toolbarTintColor;


@property(nullable, nonatomic, strong) UIImage *toolbarDoneBarButtonItemImage;

@property(nullable, nonatomic, strong) NSString *toolbarDoneBarButtonItemText;

@property(nonatomic, assign) BOOL shouldShowTextFieldPlaceholder;

@property(nullable, nonatomic, strong) UIFont *placeholderFont;


- (void)reloadInputViews;


@property(nonatomic, assign) BOOL overrideKeyboardAppearance;


@property(nonatomic, assign) UIKeyboardAppearance keyboardAppearance;


@property(nonatomic, assign) BOOL shouldResignOnTouchOutside;


- (BOOL)resignFirstResponder;

@property (nonatomic, readonly) BOOL canGoPrevious;


@property (nonatomic, readonly) BOOL canGoNext;


- (BOOL)goPrevious;


- (BOOL)goNext;


@property(nonatomic, assign) BOOL shouldPlayInputClicks;


@property(nonatomic, assign) BOOL layoutIfNeededOnUpdate;


@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *disabledDistanceHandlingClasses;


@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *enabledDistanceHandlingClasses;

@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *disabledToolbarClasses;

@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *enabledToolbarClasses;


@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *toolbarPreviousNextAllowedClasses;


@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *disabledTouchResignedClasses;


@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *enabledTouchResignedClasses;



-(void)registerTextFieldViewClass:(nonnull Class)aClass
  didBeginEditingNotificationName:(nonnull NSString *)didBeginEditingNotificationName
    didEndEditingNotificationName:(nonnull NSString *)didEndEditingNotificationName;


@property(nonatomic, assign) BOOL enableDebugging;


-(nonnull instancetype)init NS_UNAVAILABLE;


+ (nonnull instancetype)new NS_UNAVAILABLE;

@end

@interface IQKeyboardManager(IQKeyboardManagerDeprecated)


@property(nonatomic, assign) BOOL canAdjustTextView __attribute__((deprecated("Now adjusting UITextView is automatically handled by adjusting contentInset property of UITextView(UIScrollView) internally, so there is no need of this property and will be removed in future releases.")));


@property(nonatomic, assign) BOOL shouldAdoptDefaultKeyboardAnimation  __attribute__((deprecated("Now there is no animation glitch with default animation style so this property no longer needed and will be removed in future releases.")));

@end

