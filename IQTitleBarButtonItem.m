

#import "IQTitleBarButtonItem.h"
#import "IQKeyboardManagerConstants.h"
#import "IQKeyboardManagerConstantsInternal.h"
#import <UIKit/UILabel.h>
#import <UIKIt/UIButton.h>

@implementation IQTitleBarButtonItem
{
    UIView *_titleView;
    UIButton *_titleButton;
}
@synthesize font = _font;


-(nonnull instancetype)initWithTitle:(nullable NSString *)title
{
    self = [super init];
    if (self)
    {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        _titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _titleButton.enabled = NO;
        _titleButton.titleLabel.numberOfLines = 3;
        [_titleButton setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [_titleButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_titleButton setBackgroundColor:[UIColor clearColor]];
        [_titleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        _titleButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self setTitle:title];
        [self setFont:[UIFont systemFontOfSize:13.0]];
        [_titleView addSubview:_titleButton];
        self.customView = _titleView;
    }
    return self;
}

-(void)setFont:(UIFont *)font
{
    _font = font;
    
    if (font)
    {
        _titleButton.titleLabel.font = font;
    }
    else
    {
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
}

-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    [_titleButton setTitle:title forState:UIControlStateNormal];
}

-(void)setSelectableTextColor:(UIColor*)selectableTextColor
{
    _selectableTextColor = selectableTextColor;
    [_titleButton setTitleColor:_selectableTextColor forState:UIControlStateNormal];
}

-(void)setTitleTarget:(nullable id)target action:(nullable SEL)action
{
    NSInvocation *invocation = nil;
    
    if (target && action)
    {
        invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        invocation.target = target;
        invocation.selector = action;
    }

    self.titleInvocation = invocation;
}

-(void)setTitleInvocation:(NSInvocation*)invocation
{
    _titleInvocation = invocation;
    
    if (_titleInvocation.target == nil || _titleInvocation.selector == NULL)
    {
        self.enabled = NO;
        _titleButton.enabled = NO;
        [_titleButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.enabled = YES;
        _titleButton.enabled = YES;
        [_titleButton addTarget:_titleInvocation.target action:_titleInvocation.selector forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
