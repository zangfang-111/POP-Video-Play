//
//  Utility.m
//  POP
//
//  Created by KingTon on 9/5/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "Utility.h"

@implementation Utility

-(id) init {
    if((self = [super init])) {
    }
    return self;
}
+ (Utility *)sharedObject {
    static Utility *objUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objUtility = [[Utility alloc] init];
    });
    return objUtility;
}

+ (NSDictionary*) getHeightOfText:(NSString *)strText fontSize:(float) fFontSize width:(float) fWidth {
    NSDictionary* result = nil;
    CGFloat height = 0.0;
    CGRect rect = [strText boundingRectWithSize:(CGSize){fWidth, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fFontSize]}
                                        context:nil];
    
    if (strText.length <= 600) {
        height = rect.size.height + 10.f;
        result = @{
                   @"scroll": @"1",//no scroll
                   @"height": [NSString stringWithFormat:@"%f", height]
                   };
    }else {
        height = 100;
        result = @{
                   @"scroll": @"0",//no scroll
                   @"height": [NSString stringWithFormat:@"%f", height]
                   };
    }
    return result;
}
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) showMBProgress:(UIView *)view message:(NSString *)message {
    mbProgress = [[MBProgressHUD alloc] initWithView:view];
    mbProgress.detailsLabel.text = message;
    [view addSubview:mbProgress];
    [mbProgress showAnimated:YES];
}
- (void) hideMBProgress {
    if(mbProgress)
        [mbProgress hideAnimated:YES];
}
@end
