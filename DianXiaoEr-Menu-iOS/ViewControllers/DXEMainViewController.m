//
//  DXEMainViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/13/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEMainViewController.h"
#import "RNThemeManager.h"
#import "RDVTabBar.h"
#import "RDVTabBarItem.h"
#import "RDVTabBarController.h"
#import "DXEHomePageViewController.h"
#import "DXEOriginViewController.h"
#import "DXEQuestionnaireViewController.h"
#import "DXEOrderViewController.h"
#import "DXEMyselfViewController.h"

@interface DXEMainViewController ()

@end

@implementation DXEMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setupTabController];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"main view controller dealloc");
}

- (void)setupTabController
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
    
    [self setViewControllers:@[homepage,
                               origin,
                               questionnaire,
                               order,
                               myself]];
    
    NSArray *tabBarItemTitle = @[@"首页", @"起源", @"问卷", @"已点菜品", @"我"];
    NSArray *tabBarItemImageNamePrefix = @[@"homepage", @"origin", @"questionnaire", @"order", @"myself"];
    
    RDVTabBar *tabBar = [self tabBar];
    [tabBar setHeight:kDXETabBarHeight];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [tabBar items])
    {
        [item setBackgroundColor:[[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.BackgroundColor"]];
        
        NSDictionary *selectedTextAttributes =
        @{
          NSFontAttributeName: [UIFont systemFontOfSize:11],
          NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.ItemSelectedTextFontColor"]
        };
        NSDictionary *unselectedTextAttributes =
        @{
          NSFontAttributeName: [UIFont systemFontOfSize:11],
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *QRcodeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"qrcode_button.png"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onQRcodeButtonClicked:)];
    self.navigationItem.rightBarButtonItem = QRcodeButton;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Target-Action

- (void)onQRcodeButtonClicked:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
