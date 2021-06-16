

#import <Foundation/NSObjCRuntime.h>
#import "IQKeyboardManagerConstants.h"
#import "IQBarButtonItem.h"


@interface IQTitleBarButtonItem : IQBarButtonItem


@property(nullable, nonatomic, strong) UIFont *font;


@property(nullable, nonatomic, strong) UIColor *selectableTextColor;


-(nonnull instancetype)initWithTitle:(nullable NSString *)title NS_DESIGNATED_INITIALIZER;


-(void)setTitleTarget:(nullable id)target action:(nullable SEL)action;

@property (nullable, strong, nonatomic) NSInvocation *titleInvocation;


-(nonnull instancetype)init NS_UNAVAILABLE;


-(nonnull instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;


+ (nonnull instancetype)new NS_UNAVAILABLE;

@end
