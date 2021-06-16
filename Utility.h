//
//  Utility.h
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface Utility : NSObject {
     MBProgressHUD *mbProgress;
}
- (id) init;
+ (Utility*) sharedObject;
+ (NSDictionary*) getHeightOfText:(NSString *)strText fontSize:(float) fFontSize width:(float) fWidth;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (void) showMBProgress:(UIView *)view message:(NSString *)message;
- (void) hideMBProgress;
@end
