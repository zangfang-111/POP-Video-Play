

#import "IQNSArray+Sort.h"
#import "IQUIView+Hierarchy.h"

#import <UIKit/UIView.h>

@implementation NSArray (IQ_NSArray_Sort)

- (NSArray*)sortedArrayByTag
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        
        if ([view1 respondsToSelector:@selector(tag)] && [view2 respondsToSelector:@selector(tag)])
        {
            if ([view1 tag] < [view2 tag])	return NSOrderedAscending;
            
            else if ([view1 tag] > [view2 tag])	return NSOrderedDescending;
            
            else	return NSOrderedSame;
        }
        else
            return NSOrderedSame;
    }];
}

- (NSArray*)sortedArrayByPosition
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        
        CGFloat x1 = CGRectGetMinX(view1.frame);
        CGFloat y1 = CGRectGetMinY(view1.frame);
        CGFloat x2 = CGRectGetMinX(view2.frame);
        CGFloat y2 = CGRectGetMinY(view2.frame);
        
        if (y1 < y2)  return NSOrderedAscending;
        
        else if (y1 > y2) return NSOrderedDescending;
        
        //Else both y are same so checking for x positions
        else if (x1 < x2)  return NSOrderedAscending;
        
        else if (x1 > x2) return NSOrderedDescending;
        
        else    return NSOrderedSame;
    }];
}


@end
