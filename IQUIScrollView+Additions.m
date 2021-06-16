
#import "IQUIScrollView+Additions.h"
#import <objc/runtime.h>

@implementation UIScrollView (Additions)

-(void)setShouldRestoreScrollViewContentOffset:(BOOL)shouldRestoreScrollViewContentOffset
{
    objc_setAssociatedObject(self, @selector(shouldRestoreScrollViewContentOffset), @(shouldRestoreScrollViewContentOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)shouldRestoreScrollViewContentOffset
{
    NSNumber *shouldRestoreScrollViewContentOffset = objc_getAssociatedObject(self, @selector(shouldRestoreScrollViewContentOffset));
    
    return [shouldRestoreScrollViewContentOffset boolValue];
}

@end
