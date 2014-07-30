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
    self.rdv_tabBarItem.badgeTextFont = [[RNThemeManager sharedManager] fontForKey:@"Main.TabBar.BadgeTextFont"];
    self.rdv_tabBarItem.badgeTextColor = [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.BadgeTextFontColor"];
}

@end
