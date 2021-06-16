//
//  AppDelegate.h
//  POP
//
//  Created by salentro on 11/9/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTabBarViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate, UITabBarControllerDelegate,  UITabBarDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) NSString *notification_typeStr;

@end

