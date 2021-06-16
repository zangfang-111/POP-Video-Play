//
//  checkbox.m
//  POP
//
//  Created by KingTon on 10/13/17.
//  Copyright © 2017 salentro. All rights reserved.
//

#import "checkbox.h"

IB_DESIGNABLE
@implementation checkbox{
    UILabel *label;
    BOOL textIsSet;
}
@synthesize text = _text;
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self initInternals];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initInternals];
    }
    return self;
}
- (void) initInternals{
    _boxFillColor = [UIColor colorWithRed:0 green:.478 blue:1 alpha:1];
    _boxBorderColor = [UIColor colorWithRed:0 green:.478 blue:1 alpha:1];
    _checkColor = [UIColor whiteColor];
    _isChecked = YES;
    _isEnabled = YES;
    _showTextLabel = NO;
    textIsSet = NO;
    self.backgroundColor = [UIColor clearColor];
}
-(CGSize)intrinsicContentSize{
    if (_showTextLabel) {
        return CGSizeMake(160, 40);
    }
    else{
        return CGSizeMake(40, 40);
    }
}

@end
