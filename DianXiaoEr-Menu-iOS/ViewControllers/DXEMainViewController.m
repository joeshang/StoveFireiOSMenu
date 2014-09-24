//
//  DXETopBarBaseViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/16/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEMainViewController.h"
#import "CRTabBar.h"
#import "CRTabBarItem.h"
#import "CRModal.h"
#import "DXEHomePageViewController.h"
#import "DXEOriginViewController.h"
#import "DXEQuestionnaireViewController.h"
#import "DXEOrderViewController.h"
#import "DXEMyselfViewController.h"
#import "DXEOrderManager.h"
#import "DXEMember.h"
#import "DXEDiningRecord.h"
#import "DXERecordDishItem.h"
#import "DXEMemberLoginView.h"

#define DXE_TEST_MEMBER

#define kDXEQrCodeButtonOriginX         660
#define kDXEQrCodeButtonOriginY         25
#define kDXETabBarTitleFontSize         12
#define kDXEOrderBadgeFontSize          13

typedef NS_ENUM(NSInteger, DXEMainChildViewControllerIndex)
{
    DXEMainChildViewControllerIndexHomepage,
    DXEMainChildViewControllerIndexOrigin,
    DXEMainChildViewControllerIndexQuestionnaire,
    DXEMainChildViewControllerIndexOrder,
    DXEMainChildViewControllerIndexMyself
};

@interface DXEMainViewController () < CRTabBarDelegate >

@end

@implementation DXEMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[DXEOrderManager sharedInstance] addObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(totalCount))
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onMoveToHomepage:)
                                                     name:@"MoveToHomepage"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DXEOrderManager sharedInstance] removeObserver:self
                                          forKeyPath:NSStringFromSelector(@selector(totalCount))];
}

#pragma mark - view related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TopBar
    self.topBarBackgroundView = [[UIImageView alloc] init];
    self.topBarBackgroundView.userInteractionEnabled = YES;
    self.topBarBackgroundView.contentMode = UIViewContentModeScaleToFill;
    self.topBarBackgroundView.image = [[RNThemeManager sharedManager] imageForName:@"navigationbar_background.png"];
    [self.view addSubview:self.topBarBackgroundView];
    
    UIImage *image = [UIImage imageNamed:@"qrcode_button"];
    CGSize imageSize = [image size];
    self.qrCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(kDXEQrCodeButtonOriginX,
                                                                   kDXEQrCodeButtonOriginY,
                                                                   imageSize.width,
                                                                   imageSize.height)];
    [self.qrCodeButton setImage:image forState:UIControlStateNormal];
    [self.qrCodeButton addTarget:self
                          action:@selector(onQRcodeButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.qrCodeButton];
    
    // TabBar
    self.tabBar = [[CRTabBar alloc] init];
    self.tabBar.delegate = self;
    self.tabBar.backgroundImage = [[RNThemeManager sharedManager] imageForName:@"tabbar_background.png"];
    NSArray *titles = @[@"首 页", @"起 源", @"问 卷", @"已点菜品", @"我"];
    NSArray *prefix = @[@"homepage", @"origin", @"questionnaire", @"order", @"myself"];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[titles count]];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop){
        UIImage *selectedImage = [[RNThemeManager sharedManager] imageForName:
            [NSString stringWithFormat:@"%@_tabbar_selected.png", [prefix objectAtIndex:index]]];
        UIImage *normalImage = [[RNThemeManager sharedManager] imageForName:
            [NSString stringWithFormat:@"%@_tabbar_normal.png", [prefix objectAtIndex:index]]];
        CRTabBarItem *item = [[CRTabBarItem alloc] initWithTitle:title
                                                     normalImage:normalImage
                                                   selectedImage:selectedImage];
        NSDictionary *normalTextAttributes =
        @{
          NSFontAttributeName: [UIFont systemFontOfSize:kDXETabBarTitleFontSize],
          NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.NormalTextColor"]
        };
        NSDictionary *selectedTextAttributes =
        @{
          NSFontAttributeName: [UIFont systemFontOfSize:kDXETabBarTitleFontSize],
          NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.SelectedTextColor"]
        };
        item.normalTitleAttributes = normalTextAttributes;
        item.selectedTitleAttributes = selectedTextAttributes;
        
        if (index == DXEMainChildViewControllerIndexOrder)
        {
            item.badgeTextFont = [UIFont systemFontOfSize:kDXEOrderBadgeFontSize];
            item.badgeTextColor = [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.BadgeTextFontColor"];
            item.badgeBackgroundImage = nil;
            item.badgeBackgroundColor = nil;
            CGSize imageSize = [normalImage size];
            item.badgePositionAdjustment = UIOffsetMake(-imageSize.width / 2,
                                                        imageSize.height / 2 + 3);
        }
        
        [items addObject:item];
    }];
    self.tabBar.items = items;
    [self.view addSubview:self.tabBar];
    
    // Content View Controllers
    DXEHomePageViewController *homepage = [[DXEHomePageViewController alloc] init];
    DXEOriginViewController *origin = [[DXEOriginViewController alloc] init];
    DXEQuestionnaireViewController *questionnaire = [[DXEQuestionnaireViewController alloc] init];
    DXEOrderViewController *order = [[DXEOrderViewController alloc] init];
    DXEMyselfViewController *myself = [[DXEMyselfViewController alloc] init];
    
    self.contentViewControllers = @[homepage, origin, questionnaire, order, myself];
    for (UIViewController *childController in self.contentViewControllers)
    {
        [self addChildViewController:childController];
        [childController willMoveToParentViewController:self];
    }
    self.selectedViewController = homepage;
    [self.view addSubview:homepage.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topBarBackgroundView.frame = CGRectMake(0,
                                                 0,
                                                 CGRectGetWidth(self.view.bounds),
                                                 kDXENavigationBarHeight);
    self.tabBar.frame = CGRectMake(0,
                                   CGRectGetHeight(self.view.bounds) - kDXETabBarHeight,
                                   CGRectGetWidth(self.view.bounds),
                                   kDXETabBarHeight);
    for (UIViewController *contentViewController in self.contentViewControllers)
    {
        contentViewController.view.frame =
        CGRectMake(0,
                   kDXENavigationBarHeight,
                   CGRectGetWidth(self.view.bounds),
                   CGRectGetHeight(self.view.bounds) - kDXENavigationBarHeight - kDXETabBarHeight);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CRTabBarDelegate

- (BOOL)tabBar:(CRTabBar *)tabBar shouldSelecteItemAtIndex:(NSInteger)index
{
    if (index == DXEMainChildViewControllerIndexMyself)
    {
        DXEMyselfViewController *myself = [self.contentViewControllers objectAtIndex:DXEMainChildViewControllerIndexMyself];
        if (!myself.login)
        {
            NSString *nibName = NSStringFromClass([DXEMemberLoginView class]);
            DXEMemberLoginView *loginView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                                          owner:self
                                                                         options:nil] firstObject];
            [CRModal showModalView:loginView
                       coverOption:CRModalOptionCoverDark
               tapOutsideToDismiss:NO
                          animated:YES
                        completion:nil];
            
            return NO;
        }
    }
    return YES;
}

- (void)tabBar:(CRTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index
{
    [self moveToChildViewControllerAtIndex:index];
}

- (void)moveToChildViewControllerAtIndex:(NSInteger)index
{
    UIViewController *newSelectedViewController = [self.contentViewControllers objectAtIndex:index];
    if (newSelectedViewController == self.selectedViewController)
    {
        return;
    }
    
    [self.selectedViewController.view removeFromSuperview];
    newSelectedViewController.view.frame =
    CGRectMake(0,
               kDXENavigationBarHeight,
               CGRectGetWidth(self.view.bounds),
               CGRectGetHeight(self.view.bounds) - kDXENavigationBarHeight - kDXETabBarHeight);
    [self.view addSubview:newSelectedViewController.view];
    self.selectedViewController = newSelectedViewController;
}

#pragma mark - notification

- (void)onQRcodeButtonClicked:(id)sender
{
    
}

- (IBAction)onMemberLoginViewCloseButtonClicked:(id)sender
{
    [CRModal dismiss];
}

- (IBAction)onMemberLoginViewLoginButtonClicked:(id)sender
{
    DXEMyselfViewController *myself = [self.contentViewControllers objectAtIndex:DXEMainChildViewControllerIndexMyself];
    myself.member = [[DXEMember alloc] initWithJSONData:[self testMemberData]];
    myself.login = YES;
    [CRModal dismiss];
}

- (void)onMoveToHomepage:(NSNotification *)notification
{
    [self.tabBar setItemSelectedAtIndex:DXEMainChildViewControllerIndexHomepage];
    [self moveToChildViewControllerAtIndex:DXEMainChildViewControllerIndexHomepage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(totalCount))])
    {
        NSNumber *totalCount = [DXEOrderManager sharedInstance].totalCount;
        CRTabBarItem *item = [self.tabBar.items objectAtIndex:DXEMainChildViewControllerIndexOrder];
        if ([totalCount integerValue] == 0)
        {
            item.badgeValue = @"";
        }
        else
        {
            item.badgeValue = [totalCount stringValue];
        }
    }
}

#ifdef DXE_TEST_MEMBER

- (NSData *)testMemberData
{
    DXEMember *member = [[DXEMember alloc] init];
    NSMutableArray *records = [NSMutableArray arrayWithCapacity:6];
    
    for (int i = 0; i < 6; i++)
    {
        DXEDiningRecord *record = [[DXEDiningRecord alloc] init];
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:i + 1];
        int totalPrice = 0;
        int totalCount = 0;
        
        for (int j = 0; j < i + 1; j++)
        {
            int price = 20 + arc4random() % 100;
            int count = arc4random() % 2 + 1;
            
            DXERecordDishItem *item = [[DXERecordDishItem alloc] init];
            item.name = @"菜品名称";
            item.englishName = @"DISH ENGLISH NAME";
            item.price = [NSNumber numberWithFloat:price];
            item.count = [NSNumber numberWithInt:count];
            
            totalPrice += price;
            totalCount += count;
            [items addObject:item];
        }
        
        record.dishCount = [NSNumber numberWithInt:totalCount];
        record.totalPrice = [NSNumber numberWithFloat:totalPrice];
        record.dishes = [items copy];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"YYYY.MM.dd   hh:mm";
        record.date = [formatter stringFromDate:[NSDate date]];
        
        [records addObject:record];
    }
    
    member.memberid = [NSNumber numberWithInt:0];
    member.memberName = @"Joe Shang";
    member.memberPhone = @"157****0922";
    member.memberAccount = [NSNumber numberWithFloat:arc4random() % 20000];
    member.records = records;
    
    return [member JSONData];
}

#endif

@end
