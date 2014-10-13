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
#import "DXELoginView.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

#define DXE_TEST_MEMBER

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

@interface DXEMainViewController () < CRTabBarDelegate, NSXMLParserDelegate >

@property (nonatomic, strong) DXELoginView *loginView;

@property (nonatomic, strong) NSXMLParser *loginParser;
@property (nonatomic, strong) NSString *responseContent;

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
                                                 selector:@selector(onMoveToHomepageNotification:)
                                                     name:kDXEDidMoveToHomepageNotification
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
    
    // TabBar
    self.tabBar = [[CRTabBar alloc] init];
    self.tabBar.delegate = self;
    self.tabBar.backgroundImage = [[RNThemeManager sharedManager] imageForKey:@"tabbar_background.png"];
    NSArray *titles = @[@"首 页", @"起 源", @"问 卷", @"已点菜品", @"我"];
    NSArray *prefix = @[@"homepage", @"origin", @"questionnaire", @"order", @"myself"];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[titles count]];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, BOOL *stop){
        UIImage *selectedImage = [[RNThemeManager sharedManager] imageForKey:
            [NSString stringWithFormat:@"%@_tabbar_selected.png", [prefix objectAtIndex:index]]];
        UIImage *normalImage = [[RNThemeManager sharedManager] imageForKey:
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
            item.badgePositionAdjustment = UIOffsetMake(6, 10);
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
            NSString *nibName = NSStringFromClass([DXELoginView class]);
            self.loginView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                            owner:self
                                                          options:nil] firstObject];
            self.loginView.controller = self;
            self.loginView.userNamePlaceholder = @"会员卡号/手机号码";
            [CRModal showModalView:self.loginView
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

#pragma mark - Target-Action

- (IBAction)onQRcodeButtonClicked:(id)sender
{
    DXEQRCodeViewController *scanning = [[DXEQRCodeViewController alloc] init];
    scanning.delegate = self;
    [self presentViewController:scanning animated:NO completion:nil];
}

- (void)onLoginButtonClickedInLoginView:(DXELoginView *)loginView
{
    if ([loginView.userName.text isEqualToString:@""]
        || [loginView.password.text isEqualToString:@""])
    {
        self.loginView.loginFailedMessage.hidden = NO;
        self.loginView.loginFailedMessage.text = @"会员卡号/手机号码与密码不能为空";
    }
    else
    {
        self.loginView.loginFailedMessage.hidden = YES;
        
        [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeClear];
        
        NSURL *baseURL = [NSURL URLWithString:kDXEWebServiceBaseURL];
        AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        httpManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        NSDictionary *parameters = @{
                                     @"name": loginView.userName.text,
                                     @"passwd": loginView.password.text
                                     };
        [httpManager POST:@"VipLogin" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
            [SVProgressHUD dismiss];
            self.loginParser = (NSXMLParser *)responseObject;
            self.loginParser.delegate = self;
            [self.loginParser parse];
        } failure:^(NSURLSessionDataTask *task, NSError *error){
            [SVProgressHUD dismiss];
            self.loginView.loginFailedMessage.hidden = NO;
            self.loginView.loginFailedMessage.text = @"网络连接错误，请检查网络";
            NSLog(@"%@", error);
        }];
    }
}

#pragma mark - Notification

- (void)onMoveToHomepageNotification:(NSNotification *)notification
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

#pragma mark - DXEQRCodeViewControllerDelegate

- (void)qrCodeDidScan:(NSString *)codeString
{
    NSLog(@"%@", codeString);
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.responseContent = [NSString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.responseContent = [self.responseContent stringByAppendingString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if ([self.responseContent isEqualToString:@""])
    {
        self.loginView.loginFailedMessage.text = @"用户名或密码输入错误，请重新输入！";
        self.loginView.loginFailedMessage.hidden = NO;
    }
    else
    {
        DXEMyselfViewController *myself = [self.contentViewControllers objectAtIndex:DXEMainChildViewControllerIndexMyself];
        myself.member = [[DXEMember alloc] initWithJSONData:[self.responseContent dataUsingEncoding:NSUTF8StringEncoding]];
        myself.login = YES;
        [self.tabBar setItemSelectedAtIndex:DXEMainChildViewControllerIndexMyself];
        [self moveToChildViewControllerAtIndex:DXEMainChildViewControllerIndexMyself];
        DXEHomePageViewController *homepage = [self.contentViewControllers objectAtIndex:DXEMainChildViewControllerIndexHomepage];
        [homepage showAllDishClasses];
        
        [CRModal dismiss];
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
