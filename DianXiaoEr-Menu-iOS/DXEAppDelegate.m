//
//  DXEAppDelegate.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/13/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEAppDelegate.h"
#import "RDVTabBar.h"
#import "RDVTabBarItem.h"
#import "RDVTabBarController.h"
#import "DXEHomePageViewController.h"
#import "DXEOriginViewController.h"
#import "DXEQuestionnaireViewController.h"
#import "DXEOrderViewController.h"
#import "DXEMyselfViewController.h"

#define kTabBarHeight           72

@implementation DXEAppDelegate

#pragma mark - app delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [self setupViewControllers];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - setup methods

- (void)setupViewControllers
{
    // 首页
    DXEHomePageViewController *homepage = [[DXEHomePageViewController alloc] init];
    UINavigationController *homepageNav = [[UINavigationController alloc] initWithRootViewController:homepage];
    
    // 起源
    DXEOriginViewController *origin = [[DXEOriginViewController alloc] init];
    UINavigationController *originNav = [[UINavigationController alloc] initWithRootViewController:origin];
    
    // 问卷
    DXEQuestionnaireViewController *questionnaire = [[DXEQuestionnaireViewController alloc] init];
    UINavigationController *questionnaireNav = [[UINavigationController alloc] initWithRootViewController:questionnaire];
    
    // 已点菜品
    DXEOrderViewController *order = [[DXEOrderViewController alloc] init];
    UINavigationController *orderNav = [[UINavigationController alloc] initWithRootViewController:order];
    
    // 我
    DXEMyselfViewController *myself = [[DXEMyselfViewController alloc] init];
    UINavigationController *myselfNav = [[UINavigationController alloc] initWithRootViewController:myself];
    
    // 上面的界面加入TabBarController，并且对TabBar进行自定义
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[homepageNav,
                                           originNav,
                                           questionnaireNav,
                                           orderNav,
                                           myselfNav]];
    [self customizeTabBarForController:tabBarController];
    
    self.window.rootViewController = tabBarController;
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController
{
    NSArray *tabBarItemTitle = @[@"首页", @"起源", @"问卷", @"已点菜品", @"我"];
    NSArray *tabBarItemImageNamePrefix = @[@"homepage", @"origin", @"questionnaire", @"order", @"myself"];
    
    RDVTabBar *tabBar = [tabBarController tabBar];
    [tabBar setHeight:kTabBarHeight];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [tabBar items])
    {
        [item setBackgroundColor:[UIColor colorWithHexString:@"222A2D"]];
        
        NSDictionary *selectedTextAttributes = @{
                                                 NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                 NSForegroundColorAttributeName: [UIColor colorWithHexString:@"E1B554"]
                                                 };
        NSDictionary *unselectedTextAttributes = @{
                                                   NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                   NSForegroundColorAttributeName: [UIColor colorWithHexString:@"717171"]
                                                   };
        [item setSelectedTitleAttributes:selectedTextAttributes];
        [item setUnselectedTitleAttributes:unselectedTextAttributes];
        [item setTitle:[tabBarItemTitle objectAtIndex:index]];
        
        UIImage *tabBarSelectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_tabbar_selected",
                                                            [tabBarItemImageNamePrefix objectAtIndex:index]]];
        UIImage *tabBarUnselectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_tabbar_unselected",
                                                              [tabBarItemImageNamePrefix objectAtIndex:index]]];
        [item setBackgroundSelectedImage:tabBarSelectedImage
                     withUnselectedImage:tabBarUnselectedImage];
        
        index++;
    }
}

- (void)customizeNavigationBar
{
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    
    [[UINavigationBar appearance] setBackgroundImage:backgroundImage
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
}

@end