//
//  CurrentUserModel.h
//  POP
//
//  Created by KingTon on 10/20/17.
//  Copyright © 2017 salentro. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface CurrentUserModel : NSObject

+ (CurrentUserModel *)sharedModel;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userImageUrl;
@property (strong, nonatomic) NSString *userFullname;
@property (strong, nonatomic) NSString *userShortName;

@end
