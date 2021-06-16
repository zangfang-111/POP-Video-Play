//
//  AppDelegate.m
//  POP
//
//  Created by salentro on 11/9/16.
//  Copyright © 2016 salentro. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarViewController.h"
#import "AppEntryViewViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "AsyncImageView.h"
#import "ChatViewController.h"
#import "CommentViewController.h"
#import "VotesViewController.h"
#import "AFHTTPSessionManager.h"
#import "MyAndCurrentPollViewController.h"
#import "SearchViewController.h"
#import "HomeViewController.h"
#import <Branch/Branch.h>
#import "BranchWelcomeViewController.h"
UIStoryboard *strorBoard ;
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface AppDelegate ()
{
    UIView* vi;
    NSString*userid;
    NSString*req_userid;
    NSString*follow_status;
    NSString*pollIdStr;
    NSString*timelineStatusStr;
    NSString*followAlert;
    NSString*profilepic;
    NSString*str;NSString  * pushTypeString ;
    NSString*followStatusStr;UIAlertController * alert; UNUserNotificationCenter *center;
    NSString*userName;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error) {
        }
        
        if ([BranchWelcomeViewController shouldShowWelcome:params]) {
            BranchWelcomeViewController *welcomeController = [BranchWelcomeViewController branchWelcomeViewControllerWithDelegate:self branchOpts:params];
            
            [self.window.rootViewController presentViewController:welcomeController animated:YES completion:NULL];
        }
    }];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    if([[UIDevice currentDevice] systemVersion].floatValue >= 8.0)
    {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                 NSLog( @"Push registration success." );
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeRoot:) name:@"TabBarViewkey" object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *  strorBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.backgroundColor = [UIColor whiteColor];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LogInKey"]== NO)
    {
        AppEntryViewViewController * appEntryView = [strorBoard instantiateViewControllerWithIdentifier:@"appEntryId"];
        self.window.rootViewController=appEntryView;
    }
    else
    {
        [self homeViewAsRoot];
    }
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}
- (void)makeRoot:(NSNotification *)notification
{
    [self homeViewAsRoot];
}
-(void)homeViewAsRoot
{
    
    _tabBarController =
    [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainTabControllerID"];
    UITabBar *tabBar = _tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];
    tabBarItem1.tag = 11;
    tabBarItem2.tag = 12;
    tabBarItem3.tag = 13;
    tabBarItem4.tag = 14;
    tabBarItem5.tag = 15;
    
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"select_home_icon.png"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem1.image = [[UIImage imageNamed:@"home_icon.png"]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"select_search_icon.png"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem2.image = [[UIImage imageNamed:@"search_icon.png"]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"pop_tabicon.png"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem3.image = [[UIImage imageNamed:@"pop_tabicon.png"]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    tabBarItem4.selectedImage = [[UIImage imageNamed:@"select_setting_icon.png"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem4.image = [[UIImage imageNamed:@"setting_icon_orange.png"]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem5.selectedImage = [[UIImage imageNamed:@"select_user_icon.png"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem5.image = [[UIImage imageNamed:@"user_icon.png"]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.window.rootViewController=_tabBarController;
    
    self.tabBarController.delegate = self;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken

{
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"------- my device token ------ %@", newToken);
    [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:@"token"];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error");
    if(error.code == 3010)
        [[NSUserDefaults standardUserDefaults] setObject:@"0f50a0b694e1f55c79003fb7658dbb4218d5010e36ca45b974ddbcf02fd1ea8m" forKey:@"token"];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
    NSLog(@"didRegisterUser");
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
     if (![[Branch getInstance] handleDeepLink:url]) {
         [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
     }
    
    return YES;
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    _notification_typeStr=[[userInfo objectForKey:@"aps"] objectForKey:@"type"];
    [[NSUserDefaults standardUserDefaults]setObject:_notification_typeStr forKey:@"notification_typeStr"];
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        if ([_notification_typeStr isEqualToString:@"chat"]) {
            NSString*reciever_id=[[userInfo objectForKey:@"aps"] objectForKey:@"reciever_id"];
            userid=[[userInfo objectForKey:@"aps"] objectForKey:@"user_id"];
            [[NSUserDefaults standardUserDefaults]setObject:reciever_id forKey:@"reciever_id"];
            [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
            
            [self homeViewAsRoot];
        }
        
        else if ([_notification_typeStr isEqualToString:@"Winning_poll"])
        {
            str=@"win";
            pollIdStr=[[userInfo objectForKey:@"aps"] objectForKey:@"poll_id"];
            profilepic=[[userInfo objectForKey:@"aps"] objectForKey:@"media_wining_pic"];
            userName=[[userInfo objectForKey:@"aps"] objectForKey:@"user_name"];
            
        }
        else if ([_notification_typeStr isEqualToString:@"like_dislike"])
        {
            NSString*SelectedPollIdStr=[[userInfo objectForKey:@"aps"] objectForKey:@"poll_id"];
            [[NSUserDefaults standardUserDefaults]setObject:SelectedPollIdStr forKey:@"poll_id"];
            [self homeViewAsRoot];
            
        }
        else if ([_notification_typeStr isEqualToString:@"comment"])
        {
            
            NSString*SelectedPollIdStr=[[userInfo objectForKey:@"aps"] objectForKey:@"poll_id"];
            [[NSUserDefaults standardUserDefaults]setObject:SelectedPollIdStr forKey:@"poll_id"];
            
            [self homeViewAsRoot];
            
        }
        
        else if ([_notification_typeStr isEqualToString:@"follower_request"])
        {
            req_userid=[[userInfo objectForKey:@"aps"] objectForKey:@"requester_id"];
            userid=[[userInfo objectForKey:@"aps"] objectForKey:@"user_id"];
            str=@"Follow";
            NSString*followingStatus=[[userInfo objectForKey:@"aps"] objectForKey:@"following_status"];
            followAlert=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            
            [[NSUserDefaults standardUserDefaults]setObject:followingStatus forKey:@"following_status"];
            
            profilepic=[[userInfo objectForKey:@"aps"] objectForKey:@"profile_pic"];
            [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"clickedUserid"];
            
            [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Fromnoti"];
            [self showFollowRequestPopUp];
        }
        else if ([_notification_typeStr isEqualToString:@"follower"])
        {
            userid=[[userInfo objectForKey:@"aps"] objectForKey:@"requester_id"];
            [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
            [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"clickedUserid"];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Fromnoti"];
            NSString*followingStatus=[[userInfo objectForKey:@"aps"] objectForKey:@"following_status"];
            
            [[NSUserDefaults standardUserDefaults]setObject:followingStatus forKey:@"following_status"];
            
            [self homeViewAsRoot];
        }
    }
}

#pragma mark - Push Notification Delegate for Ios 10


-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
        [alert dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"Userinfo %@",notification.request.content.userInfo);
        NSDictionary * userInfo  = notification.request.content.userInfo;
        pushTypeString =[[userInfo objectForKey:@"aps"] objectForKey:@"type"];
    
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        if(pushTypeString)
        {
            
            if ([pushTypeString isEqualToString:@"chat"]) {
                NSString*reciever_id=[[userInfo objectForKey:@"aps"] objectForKey:@"reciever_id"];
                userid=[[userInfo objectForKey:@"aps"] objectForKey:@"user_id"];
                [[NSUserDefaults standardUserDefaults]setObject:reciever_id forKey:@"reciever_id"];
                [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
                
                [self homeViewAsRoot];
            }
            
            else if ([pushTypeString isEqualToString:@"Winning_poll"])
            {
                str=@"win";
                pollIdStr=[[userInfo objectForKey:@"aps"] objectForKey:@"poll_id"];
                profilepic=[[userInfo objectForKey:@"aps"] objectForKey:@"media_wining_pic"];
            }
            else if ([pushTypeString isEqualToString:@"like_dislike"])
            {
                NSString*SelectedPollIdStr=[[userInfo objectForKey:@"aps"] objectForKey:@"poll_id"];
                [[NSUserDefaults standardUserDefaults]setObject:SelectedPollIdStr forKey:@"poll_id"];
                [self homeViewAsRoot];
                
            }
            else if ([pushTypeString isEqualToString:@"comment"])
            {
                
                NSString*SelectedPollIdStr=[[userInfo objectForKey:@"aps"] objectForKey:@"poll_id"];
                [[NSUserDefaults standardUserDefaults]setObject:SelectedPollIdStr forKey:@"poll_id"];
                
                [self homeViewAsRoot];
            }
            
            else if ([pushTypeString isEqualToString:@"follower_request"])
            {
                req_userid=[[userInfo objectForKey:@"aps"] objectForKey:@"requester_id"];
                userid=[[userInfo objectForKey:@"aps"] objectForKey:@"user_id"];
                str=@"Follow";
                NSString*followingStatus=[[userInfo objectForKey:@"aps"] objectForKey:@"following_status"];
                followAlert=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
                
                [[NSUserDefaults standardUserDefaults]setObject:followingStatus forKey:@"following_status"];
                
                profilepic=[[userInfo objectForKey:@"aps"] objectForKey:@"profile_pic"];
                [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"clickedUserid"];
                
                [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Fromnoti"];
                [self showFollowRequestPopUp];
            }
            else if ([pushTypeString isEqualToString:@"follower"])
            {
                userid=[[userInfo objectForKey:@"aps"] objectForKey:@"requester_id"];
                [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
                [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"clickedUserid"];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Fromnoti"];
                NSString*followingStatus=[[userInfo objectForKey:@"aps"] objectForKey:@"following_status"];
                
                [[NSUserDefaults standardUserDefaults]setObject:followingStatus forKey:@"following_status"];
                
                [self homeViewAsRoot];
            }
        }
    }
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    [alert dismissViewControllerAnimated:YES completion:nil];
    NSDictionary * userInfo  = response.notification.request.content.userInfo;
    
    
    pushTypeString =[[userInfo objectForKey:@"aps"] objectForKey:@"type"];
    if(pushTypeString)
    {
        [self pushToScreenWhenClickOnNotificationInForeground:userInfo];
        
    }
}
-(void)pushToScreenWhenClickOnNotificationInForeground:(NSDictionary *)userInfo
{
    _notification_typeStr=[[userInfo objectForKey:@"aps"] objectForKey:@"type"];
    
    if ([_notification_typeStr isEqualToString:@"Winning_poll"])
    {
        str=@"win";
        pollIdStr=[[userInfo objectForKey:@"aps"] objectForKey:@"poll_id"];
        profilepic=[[userInfo objectForKey:@"aps"] objectForKey:@"media_wining_pic"];
    }
    
    else if ([_notification_typeStr isEqualToString:@"follower_request"])
    {
        req_userid=[[userInfo objectForKey:@"aps"] objectForKey:@"requester_id"];
        userid=[[userInfo objectForKey:@"aps"] objectForKey:@"user_id"];
        str=@"Follow";
        NSString*followingStatus=[[userInfo objectForKey:@"aps"] objectForKey:@"following_status"];
        followAlert=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        
        [[NSUserDefaults standardUserDefaults]setObject:followingStatus forKey:@"following_status"];
        
        profilepic=[[userInfo objectForKey:@"aps"] objectForKey:@"profile_pic"];
        [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"clickedUserid"];
        
        [[NSUserDefaults standardUserDefaults]setObject:userid forKey:@"userid"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Fromnoti"];
        [self showFollowRequestPopUp];
    }
    
}

-(void)showFollowRequestPopUp
{
    //    Show the Popup with information
    if (IS_IPHONE_4)
    {
        vi=[[UIView alloc] initWithFrame:CGRectMake(30, 100, self.window.frame.size.width-60, self.window.frame.size.height-280)];
        
    }
    if (IS_IPHONE_5) {
        vi=[[UIView alloc] initWithFrame:CGRectMake(30, 100, self.window.frame.size.width-60, self.window.frame.size.height-320)];
        
    }
    else if (IS_IPHONE_6)
    {
        vi=[[UIView alloc] initWithFrame:CGRectMake(30, 100, self.window.frame.size.width-60, self.window.frame.size.height-400)];
        
    }
    else
    {
        vi=[[UIView alloc] initWithFrame:CGRectMake(30, 100, self.window.frame.size.width-60, self.window.frame.size.height-480)];
    }

    vi.backgroundColor=[UIColor whiteColor];
    vi.layer.cornerRadius = 10;
    vi.layer.borderWidth = 1;
    vi.layer.borderColor = [UIColor orangeColor].CGColor;
    vi.clipsToBounds = YES;
    
    
    
    AsyncImageView *ProfileImg=[[AsyncImageView alloc] initWithFrame:CGRectMake((vi.frame.size.width/2)-43, 25, 85, 85)];
    ProfileImg.imageURL=[NSURL URLWithString:profilepic];
    ProfileImg.layer.cornerRadius = ProfileImg.frame.size.width / 2;
    ProfileImg.layer.borderWidth = 2.5;
    ProfileImg.layer.borderColor = [UIColor orangeColor].CGColor;
    ProfileImg.clipsToBounds = YES;
    [vi addSubview:ProfileImg];
    
    UILabel *nameCus=[[UILabel alloc] initWithFrame:CGRectMake(10, 110, vi.frame.size.width-20, 21)];
    nameCus.text=userName;
    nameCus.textColor=[UIColor grayColor];
    nameCus.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
    nameCus.textAlignment=NSTextAlignmentCenter;
    [vi addSubview:nameCus];
    
    
    
    UILabel *AddressOfCus=[[UILabel alloc] initWithFrame:CGRectMake(10, 130, vi.frame.size.width-20, 45)];
    AddressOfCus.numberOfLines=0;
    AddressOfCus.textColor=[UIColor lightGrayColor];
    AddressOfCus.font=FONTNAME_MONTSERRAT_REGULAR_Size(14);
    AddressOfCus.textAlignment=NSTextAlignmentCenter;
    AddressOfCus.text=followAlert;
    [vi addSubview:AddressOfCus];
    
    
    UIButton *donepopup=[[UIButton alloc] initWithFrame:CGRectMake( (vi.frame.size.width/2)-100, vi.frame.size.height-60, 70, 30)];
    
    [donepopup setTitle: @"Reject" forState: UIControlStateNormal];
    [donepopup setBackgroundColor:[UIColor orangeColor]];
    donepopup.titleLabel.font =  FONTNAME_MONTSERRAT_REGULAR_Size(14);
    [donepopup addTarget:self
                  action:@selector(noBtn:)
        forControlEvents:UIControlEventTouchUpInside];
    [donepopup setTitleColor: [UIColor whiteColor] forState:
     UIControlStateNormal];
    [vi addSubview:donepopup];
    
    UIButton *cancelpopup=[[UIButton alloc] initWithFrame:CGRectMake((vi.frame.size.width/2)+20, vi.frame.size.height-60, 70,30)];
    [cancelpopup setBackgroundColor:[UIColor orangeColor]];
    [cancelpopup setTitle: @"Accept" forState: UIControlStateNormal];
    cancelpopup.titleLabel.font =  FONTNAME_MONTSERRAT_REGULAR_Size(14);
    [cancelpopup addTarget:self
                    action:@selector(yesBtn:)
          forControlEvents:UIControlEventTouchUpInside];
    [cancelpopup setTitleColor: [UIColor whiteColor] forState:
     UIControlStateNormal];
    [vi addSubview:cancelpopup];
    vi.userInteractionEnabled = YES;
    
    self.window.userInteractionEnabled = YES;
    [self.window addSubview:vi];
    
}
-(void)winningPollRequest
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary * params = @{@"poll_id":pollIdStr,@"timeline_status":timelineStatusStr};
    
    [manager POST:@"post_on_timeline_status" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
             
         }
         else
         {
             
         }
         
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         
     }];
}
-(void)Accept_followRequest
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager manager]initWithBaseURL:[NSURL URLWithString:BASEURL]];
    [manager.requestSerializer setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"content"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary * params = @{@"user_id":userid,@"requester_id":req_userid,@"follow_status":followStatusStr};
    
    [manager POST:@"accept_reject_follower_request" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         NSLog(@"JSON: %@", responseObject);
         if ([[[responseObject valueForKey:@"data"] valueForKey:@"status"] isEqualToString:@"true"]) {
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"Error: %@", error);
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         
     }];
}
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    
    [center removeAllDeliveredNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UINavigationController* navController = (UINavigationController*)viewController;
    UIViewController* subViewController = navController.viewControllers[0];
    
    if ([subViewController isKindOfClass:[MyAndCurrentPollViewController class]] && self.tabBarController.selectedIndex == 4){
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromSearch"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FromHome"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
       
    }
    if([subViewController isKindOfClass:[SearchViewController class]]&& self.tabBarController.selectedIndex ==1) {
        [((SearchViewController*)subViewController).navigationController popViewControllerAnimated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FromSearch"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromHome"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    if ([subViewController isKindOfClass:[HomeViewController class]] && self.tabBarController.selectedIndex == 0){
        [((HomeViewController*)subViewController).navigationController popViewControllerAnimated:YES];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FromSearch"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FromHome"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

@end
