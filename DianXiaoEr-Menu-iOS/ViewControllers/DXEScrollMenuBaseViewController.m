//
//  DXEScrollMenuBaseViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEScrollMenuBaseViewController.h"

#define kDXEScrollMenuHeight                        53
#define kDXEScrollMenuButtonPadding                 18
#define kDXEScrollMenuIndicatorHeight               2
#define kDXEScrollMenuTitleFontSize                 20
#define kDXEScrollMenuSubtitleFontSize              9

@interface DXEScrollMenuBaseViewController ()

@end

@implementation DXEScrollMenuBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollMenuController = [[CRScrollMenuController alloc] init];
    self.scrollMenuController.scrollMenuHeight = kDXEScrollMenuHeight;
    self.scrollMenuController.scrollMenuBackgroundImage = [[RNThemeManager sharedManager] imageForName:@"scrollmenu_background"];
    self.scrollMenuController.scrollMenuIndicatorColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemSelectedTextColor"];
    self.scrollMenuController.scrollMenuIndicatorHeight = kDXEScrollMenuIndicatorHeight;
    self.scrollMenuController.scrollMenuButtonPadding = kDXEScrollMenuButtonPadding;
    self.scrollMenuController.normalTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:kDXEScrollMenuTitleFontSize],
                                                        NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemUnselectedTextColor"]};
    self.scrollMenuController.selectedTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:kDXEScrollMenuTitleFontSize],
                                                          NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemSelectedTextColor"]};
    self.scrollMenuController.normalSubtitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:kDXEScrollMenuSubtitleFontSize],
                                                           NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemUnselectedTextColor"]};
    self.scrollMenuController.selectedSubtitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:kDXEScrollMenuSubtitleFontSize],
                                                             NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemSelectedTextColor"]};
    
    [self addChildViewController:self.scrollMenuController];
    [self.view addSubview:self.scrollMenuController.view];
    [self.scrollMenuController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollMenuController.view.frame = CGRectMake(0,
                                                      kDXENavigationBarHeight,
                                                      CGRectGetWidth(self.view.bounds),
                                                      CGRectGetHeight(self.view.bounds) - kDXENavigationBarHeight);
}

@end
