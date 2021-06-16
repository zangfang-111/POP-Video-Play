

#import "IQUITextFieldView+Additions.h"
#import <objc/runtime.h>

@implementation UIView (Additions)

-(void)setKeyboardDistanceFromTextField:(CGFloat)keyboardDistanceFromTextField
{
    //Can't be less than zero. Minimum is zero.
    keyboardDistanceFromTextField = MAX(keyboardDistanceFromTextField, 0);
    
    objc_setAssociatedObject(self, @selector(keyboardDistanceFromTextField), [NSNumber numberWithFloat:keyboardDistanceFromTextField], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGFloat)keyboardDistanceFromTextField
{
    NSNumber *keyboardDistanceFromTextField = objc_getAssociatedObject(self, @selector(keyboardDistanceFromTextField));
    
    return (keyboardDistanceFromTextField)?[keyboardDistanceFromTextField floatValue]:kIQUseDefaultKeyboardDistance;
}

@end


CGFloat const kIQUseDefaultKeyboardDistance = CGFLOAT_MAX;

