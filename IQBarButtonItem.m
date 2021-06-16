

#import "IQBarButtonItem.h"
#import "IQKeyboardManagerConstantsInternal.h"

@implementation IQBarButtonItem

+(void)load
{
    //Tint color
    [[self appearance] setTintColor:nil];

    //Title
    [[self appearance] setTitlePositionAdjustment:UIOffsetZero forBarMetrics:UIBarMetricsDefault];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateNormal];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateHighlighted];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateDisabled];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateSelected];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateApplication];
    [[self appearance] setTitleTextAttributes:nil forState:UIControlStateReserved];
    
    //Background Image
    [[self appearance] setBackgroundImage:nil forState:UIControlStateNormal         barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateHighlighted    barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateDisabled       barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateSelected       barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateApplication    barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateReserved       barMetrics:UIBarMetricsDefault];

    [[self appearance] setBackgroundImage:nil forState:UIControlStateNormal         style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateHighlighted    style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateDisabled       style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateSelected       style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateApplication    style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateReserved       style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    
    [[self appearance] setBackgroundImage:nil forState:UIControlStateNormal         style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateHighlighted    style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateDisabled       style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateSelected       style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateApplication    style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackgroundImage:nil forState:UIControlStateReserved       style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];

    [[self appearance] setBackgroundVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
    
    //Back Button
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateNormal       barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted  barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateDisabled     barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateSelected     barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateApplication  barMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundImage:nil forState:UIControlStateReserved     barMetrics:UIBarMetricsDefault];
    
    [[self appearance] setBackButtonTitlePositionAdjustment:UIOffsetZero forBarMetrics:UIBarMetricsDefault];
    [[self appearance] setBackButtonBackgroundVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
}

@end
