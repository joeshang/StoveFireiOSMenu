//
//  DXEOrderViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderViewController.h"
#import "RDVTabBarItem.h"
#import "RDVTabBarController.h"
#import "DXEOrderCartViewController.h"

#define kDXEOrderBadgeFontSize          13
#define kDXEOrderBadgePositionOffset    UIOffsetMake(0, 3);

@interface DXEOrderViewController ()

@end

@implementation DXEOrderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rdv_tabBarItem.badgeValue = @"";
    self.rdv_tabBarItem.badgeIsAtCenter = YES;
    self.rdv_tabBarItem.badgeBackgroundColor = nil;
    self.rdv_tabBarItem.badgeBackgroundImage = nil;
    self.rdv_tabBarItem.badgePositionAdjustment = kDXEOrderBadgePositionOffset;
    self.rdv_tabBarItem.badgeTextFont = [UIFont systemFontOfSize:kDXEOrderBadgeFontSize];
    self.rdv_tabBarItem.badgeTextColor = [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.BadgeTextFontColor"];
    
    DXEOrderCartViewController *cart = [[DXEOrderCartViewController alloc] init];
    CRScrollMenuItem *item = [[CRScrollMenuItem alloc] init];
    item.title = @"已点菜单";
    
    [self.scrollMenuController setViewControllers:@[cart] withItems:@[item]];
}

@end
