
#import "IQKeyboardReturnKeyHandler.h"
#import "IQKeyboardManager.h"
#import "IQUIView+Hierarchy.h"
#import "IQNSArray+Sort.h"

#import <Foundation/NSSet.h>

#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIViewController.h>

NSString *const kIQTextField                =   @"kIQTextField";
NSString *const kIQTextFieldDelegate        =   @"kIQTextFieldDelegate";
NSString *const kIQTextFieldReturnKeyType   =   @"kIQTextFieldReturnKeyType";


@interface IQKeyboardReturnKeyHandler ()<UITextFieldDelegate,UITextViewDelegate>

-(void)updateReturnKeyTypeOnTextField:(UIView*)textField;

@end

@implementation IQKeyboardReturnKeyHandler
{
    NSMutableSet *textFieldInfoCache;
}

@synthesize lastTextFieldReturnKeyType = _lastTextFieldReturnKeyType;
@synthesize delegate = _delegate;

- (instancetype)init
{
    self = [self initWithViewController:nil];
    return self;
}

-(instancetype)initWithViewController:(UIViewController*)controller
{
    self = [super init];
    
    if (self)
    {
        textFieldInfoCache = [[NSMutableSet alloc] init];
        [self addResponderFromView:controller.view];
    }
    
    return self;
}

-(NSDictionary*)textFieldCachedInfo:(UITextField*)textField
{
    for (NSDictionary *infoDict in textFieldInfoCache)
        if (infoDict[kIQTextField] == textField)  return infoDict;
    
    return nil;
}

#pragma mark - Add/Remove TextFields
-(void)addResponderFromView:(UIView*)view
{
    NSArray *textFields = [view deepResponderViews];
    
    for (UITextField *textField in textFields)  [self addTextFieldView:textField];
}

-(void)removeResponderFromView:(UIView*)view
{
    NSArray *textFields = [view deepResponderViews];
    
    for (UITextField *textField in textFields)  [self removeTextFieldView:textField];
}

-(void)removeTextFieldView:(UITextField*)textField
{
    NSDictionary *dict = [self textFieldCachedInfo:textField];
    
    if (dict)
    {
        textField.keyboardType = [dict[kIQTextFieldReturnKeyType] integerValue];
        textField.delegate = dict[kIQTextFieldDelegate];
        [textFieldInfoCache removeObject:dict];
    }
}

-(void)addTextFieldView:(UITextField*)textField
{
    NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc] init];
    
    dictInfo[kIQTextField] = textField;
    dictInfo[kIQTextFieldReturnKeyType] = @(textField.returnKeyType);
    
    if (textField.delegate) dictInfo[kIQTextFieldDelegate] = textField.delegate;

    [textField setDelegate:self];

    [textFieldInfoCache addObject:dictInfo];
}

-(void)updateReturnKeyTypeOnTextField:(UIView*)textField
{
    UIView *superConsideredView;
    
    //If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
    for (Class consideredClass in [[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses])
    {
        superConsideredView = [textField superviewOfClassType:consideredClass];
        
        if (superConsideredView != nil)
            break;
    }

    NSArray *textFields = nil;

    //If there is a tableView in view's hierarchy, then fetching all it's subview that responds. No sorting for tableView, it's by subView position.
    if (superConsideredView)  //     //   (Enhancement ID: #22)
    {
        textFields = [superConsideredView deepResponderViews];
    }
    //Otherwise fetching all the siblings
    else
    {
        textFields = [textField responderSiblings];
        
        //Sorting textFields according to behaviour
        switch ([[IQKeyboardManager sharedManager] toolbarManageBehaviour])
        {
                //If needs to sort it by tag
            case IQAutoToolbarByTag:
                textFields = [textFields sortedArrayByTag];
                break;
                
                //If needs to sort it by Position
            case IQAutoToolbarByPosition:
                textFields = [textFields sortedArrayByPosition];
                break;
                
            default:
                break;
        }
    }
    
    //If it's the last textField in responder view, else next
    [(UITextField*)textField setReturnKeyType:(([textFields lastObject] == textField)    ?   self.lastTextFieldReturnKeyType :   UIReturnKeyNext)];
}

#pragma mark - Goto next or Resign.

-(void)goToNextResponderOrResign:(UIView*)textField
{
    UIView *superConsideredView;
    
    //If find any consider responderView in it's upper hierarchy then will get deepResponderView. (Bug ID: #347)
    for (Class consideredClass in [[IQKeyboardManager sharedManager] toolbarPreviousNextAllowedClasses])
    {
        superConsideredView = [textField superviewOfClassType:consideredClass];
        
        if (superConsideredView != nil)
            break;
    }
    
    NSArray *textFields = nil;
    
    //If there is a tableView in view's hierarchy, then fetching all it's subview that responds. No sorting for tableView, it's by subView position.
    if (superConsideredView)  //     //   (Enhancement ID: #22)
    {
        textFields = [superConsideredView deepResponderViews];
    }
    //Otherwise fetching all the siblings
    else
    {
        textFields = [textField responderSiblings];
        
        //Sorting textFields according to behaviour
        switch ([[IQKeyboardManager sharedManager] toolbarManageBehaviour])
        {
                //If needs to sort it by tag
            case IQAutoToolbarByTag:
                textFields = [textFields sortedArrayByTag];
                break;
                
                //If needs to sort it by Position
            case IQAutoToolbarByPosition:
                textFields = [textFields sortedArrayByPosition];
                break;
                
            default:
                break;
        }
    }
        
    //Getting index of current textField.
    NSUInteger index = [textFields indexOfObject:textField];
    
    //If it is not last textField. then it's next object becomeFirstResponder.
    (index != NSNotFound && index < textFields.count-1) ?   [textFields[index+1] becomeFirstResponder]  :   [textField resignFirstResponder];
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        return [self.delegate textFieldShouldBeginEditing:textField];
    else
        return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self updateReturnKeyTypeOnTextField:textField];

    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [self.delegate textFieldDidBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
        return [self.delegate textFieldShouldEndEditing:textField];
    else
        return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [self.delegate textFieldDidEndEditing:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    else
        return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)])
        return [self.delegate textFieldShouldClear:textField];
    else
        return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL shouldReturn = YES;

    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)])
        shouldReturn = [self.delegate textFieldShouldReturn:textField];

    if (shouldReturn)
    {
        [self goToNextResponderOrResign:textField];
    }
    
    return shouldReturn;
}


#pragma mark - TextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
        return [self.delegate textViewShouldBeginEditing:textView];
    else
        return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(textViewShouldEndEditing:)])
        return [self.delegate textViewShouldEndEditing:textView];
    else
        return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self updateReturnKeyTypeOnTextField:textView];

    if ([self.delegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [self.delegate textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(textViewDidEndEditing:)])
        [self.delegate textViewDidEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL shouldReturn = YES;
    
    if ([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
        shouldReturn = [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    
    if (shouldReturn && [text isEqualToString:@"\n"])
    {
        [self goToNextResponderOrResign:textView];
    }
    
    return shouldReturn;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(textViewDidChangeSelection:)])
        [self.delegate textViewDidChangeSelection:textView];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([self.delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
        return [self.delegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
    else
        return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    if ([self.delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)])
        return [self.delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    else
        return YES;
}

-(void)dealloc
{
    for (NSDictionary *dict in textFieldInfoCache)
    {
        UITextField *textField  = dict[kIQTextField];
        textField.keyboardType  = [dict[kIQTextFieldReturnKeyType] integerValue];
        textField.delegate      = dict[kIQTextFieldDelegate];
    }

    [textFieldInfoCache removeAllObjects];
}

@end
