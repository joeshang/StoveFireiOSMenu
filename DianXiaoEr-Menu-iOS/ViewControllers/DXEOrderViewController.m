//
//  DXEOrderViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderViewController.h"
#import "DXEOrderManager.h"
#import "DXEOrderCartViewController.h"
#import "CRScrollMenu.h"

#define kDXEOrderScrollMenuHeight                    53
#define kDXEOrderScrollMenuButtonPadding             63
#define kDXEOrderScrollMenuIndicatorHeight           2
#define kDXEOrderScrollMenuTitleFontSize             20

@interface DXEOrderViewController ()
< CRScrollMenuDelegate >

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) DXEOrderCartViewController *cartViewController;
@property (nonatomic, strong) CRScrollMenu *scrollMenu;

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
    
    self.view.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"Order.BackgroundColor"];
    
    UIColor *normalColor =[[RNThemeManager sharedManager] colorForKey:@"ScrollMenu.NormalTextColor"];
    UIColor *selectedColor =[[RNThemeManager sharedManager] colorForKey:@"ScrollMenu.SelectedTextColor"];
    self.scrollMenu = [[CRScrollMenu alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     CGRectGetWidth(self.view.bounds),
                                                                     kDXEOrderScrollMenuHeight)];
    self.scrollMenu.delegate = self;
    self.scrollMenu.backgroundImage = [[RNThemeManager sharedManager] imageForName:@"scrollmenu_background"];
    self.scrollMenu.indicatorColor = selectedColor;
    self.scrollMenu.indicatorHeight = kDXEOrderScrollMenuIndicatorHeight;
    self.scrollMenu.buttonPadding = kDXEOrderScrollMenuButtonPadding;
    self.scrollMenu.normalTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kDXEOrderScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: normalColor
      };
    self.scrollMenu.selectedTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kDXEOrderScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: selectedColor
      };
    [self.view addSubview:self.scrollMenu];
    
    NSArray *titles = @[@"已点菜品", @"已下单", @"制作中", @"已完成"];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[titles count]];
    for (NSString *title in titles)
    {
        CRScrollMenuItem *item = [[CRScrollMenuItem alloc] init];
        item.title = title;
        [items addObject:item];
    }
    [self.scrollMenu setButtonsByItems:items];
    
    self.cartViewController = [[DXEOrderCartViewController alloc] init];
    [self addChildViewController:self.cartViewController];
    [self.view addSubview:self.cartViewController.view];
    self.currentViewController = self.cartViewController;
    [self.cartViewController willMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.currentViewController.view.frame = CGRectMake(0,
                                                       kDXEOrderScrollMenuHeight,
                                                       CGRectGetWidth(self.view.bounds),
                                                       CGRectGetHeight(self.view.bounds) - kDXEOrderScrollMenuHeight);
}

- (void)scrollMenu:(CRScrollMenu *)scrollMenu didSelectedAtIndex:(NSUInteger)index
{
    
}

@end
