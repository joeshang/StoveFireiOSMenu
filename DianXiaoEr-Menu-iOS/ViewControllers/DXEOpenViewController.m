//
//  DXEOpenViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/12/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOpenViewController.h"
#import "RNThemeManager.h"
#import "RDVTabBar.h"
#import "RDVTabBarItem.h"
#import "RDVTabBarController.h"
#import "DXEHomePageViewController.h"
#import "DXEOriginViewController.h"
#import "DXEQuestionnaireViewController.h"
#import "DXEOrderViewController.h"
#import "DXEMyselfViewController.h"

#define kDXETabBarTitleFontSize         12

@interface DXEOpenViewController ()

@end

@implementation DXEOpenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View Related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Target-Action

- (IBAction)onLoginButtonClicked:(id)sender
{
    // 首页
    DXEHomePageViewController *homepage = [[DXEHomePageViewController alloc] init];
    // 起源
    DXEOriginViewController *origin = [[DXEOriginViewController alloc] init];
    // 问卷
    DXEQuestionnaireViewController *questionnaire = [[DXEQuestionnaireViewController alloc] init];
    // 已点菜品
    DXEOrderViewController *order = [[DXEOrderViewController alloc] init];
    // 我
    DXEMyselfViewController *myself = [[DXEMyselfViewController alloc] init];
    
    RDVTabBarController *mainViewController = [[RDVTabBarController alloc] init];
    [mainViewController setViewControllers:@[homepage,
                               origin,
                               questionnaire,
                               order,
                               myself]];
    
    NSArray *tabBarItemTitle = @[@"首 页", @"起 源", @"问 卷", @"已点菜品", @"我"];
    NSArray *tabBarItemImageNamePrefix = @[@"homepage", @"origin", @"questionnaire", @"order", @"myself"];
    
    RDVTabBar *tabBar = [mainViewController tabBar];
    [tabBar setHeight:kDXETabBarHeight];
    
    UIImage *tabBarBackgroundImage = [[RNThemeManager sharedManager] imageForName:@"tabbar_background.png"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [tabBar items])
    {
        [item setBackgroundSelectedImage:tabBarBackgroundImage
                     withUnselectedImage:tabBarBackgroundImage];
        
        NSDictionary *selectedTextAttributes =
        @{
          NSFontAttributeName: [UIFont systemFontOfSize:kDXETabBarTitleFontSize],
          NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.ItemSelectedTextFontColor"]
        };
        NSDictionary *unselectedTextAttributes =
        @{
          NSFontAttributeName: [UIFont systemFontOfSize:kDXETabBarTitleFontSize],
          NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.ItemUnselectedTextFontColor"]
        };
        [item setSelectedTitleAttributes:selectedTextAttributes];
        [item setUnselectedTitleAttributes:unselectedTextAttributes];
        [item setTitle:[tabBarItemTitle objectAtIndex:index]];
        
        UIImage *tabBarSelectedImage = [[RNThemeManager sharedManager] imageForName:
                                        [NSString stringWithFormat:@"%@_tabbar_selected.png", [tabBarItemImageNamePrefix objectAtIndex:index]]];
        UIImage *tabBarUnselectedImage = [[RNThemeManager sharedManager] imageForName:
                                          [NSString stringWithFormat:@"%@_tabbar_unselected.png", [tabBarItemImageNamePrefix objectAtIndex:index]]];
        [item setFinishedSelectedImage:tabBarSelectedImage
           withFinishedUnselectedImage:tabBarUnselectedImage];
        
        index++;
    }
    
    [[UIApplication sharedApplication] keyWindow].rootViewController = mainViewController;
}

@end
