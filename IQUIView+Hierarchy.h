

#import <UIKit/UIView.h>
#import "IQKeyboardManagerConstants.h"

@class UICollectionView, UIScrollView, UITableView, NSArray;


@interface UIView (IQ_UIView_Hierarchy)


@property (nonatomic, readonly) BOOL isAskingCanBecomeFirstResponder;


@property (nullable, nonatomic, readonly, strong) UIViewController *viewController;


@property (nullable, nonatomic, readonly, strong) UIViewController *topMostController;


-(nullable UIView*)superviewOfClassType:(nonnull Class)classType;


@property (nonnull, nonatomic, readonly, copy) NSArray *responderSiblings;


@property (nonnull, nonatomic, readonly, copy) NSArray *deepResponderViews;


@property (nonatomic, getter=isSearchBarTextField, readonly) BOOL searchBarTextField;


@property (nonatomic, getter=isAlertViewTextField, readonly) BOOL alertViewTextField;


-(CGAffineTransform)convertTransformToView:(nullable UIView*)toView;


@property (nonnull, nonatomic, readonly, copy) NSString *subHierarchy;


@property (nonnull, nonatomic, readonly, copy) NSString *superHierarchy;


@property (nonnull, nonatomic, readonly, copy) NSString *debugHierarchy;

@end



@interface NSObject (IQ_Logging)


@property (nonnull, nonatomic, readonly, copy) NSString *_IQDescription;

@end
