//
//  SFTopBarBaseViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/16/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFMainViewController.h"
#import "CRTabBar.h"
#import "CRTabBarItem.h"
#import "CRModal.h"
#import "SFHomePageViewController.h"
#import "SFOriginViewController.h"
#import "SFQuestionnaireViewController.h"
#import "SFOrderViewController.h"
#import "SFMyselfViewController.h"
#import "SFOrderManager.h"
#import "SFDataManager.h"
#import "SFMember.h"
#import "SFDiningRecord.h"
#import "SFRecordDishItem.h"
#import "SFLoginView.h"
#import "SFQRCodeViewController.h"
#import "SFProjectorManager.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

#define kSFTabBarTitleFontSize         12
#define kSFOrderBadgeFontSize          13

typedef NS_ENUM(NSInteger, SFMainChildViewControllerIndex)
{
    SFMainChildViewControllerIndexHomepage,
    SFMainChildViewControllerIndexOrigin,
    SFMainChildViewControllerIndexQuestionnaire,
    SFMainChildViewControllerIndexOrder,
    SFMainChildViewControllerIndexMyself
};

@interface SFMainViewController () < CRTabBarDelegate, NSXMLParserDelegate, SFQRCodeViewControllerDelegate >

@property (nonatomic, strong) SFLoginView *loginView;

@property (nonatomic, strong) NSXMLParser *loginParser;
@property (nonatomic, strong) NSString *responseContent;

#ifdef SF_UI_TEST
- (NSData *)testMemberData;
#endif

@end

@implementation SFMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[SFOrderManager sharedInstance] addObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(totalCount))
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onMoveToHomepageNotification:)
                                                     name:kSFDidMoveToHomepageNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onConnectToProjectorNotification:)
                                                     name:kSFDidConnectToProjectorNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDisConnectToProjectorNotification:)
                                                     name:kSFDidDisconnectToProjectorNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SFOrderManager sharedInstance] removeObserver:self
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
          NSFontAttributeName: [UIFont systemFontOfSize:kSFTabBarTitleFontSize],
          NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.NormalTextColor"]
        };
        NSDictionary *selectedTextAttributes =
        @{
          NSFontAttributeName: [UIFont systemFontOfSize:kSFTabBarTitleFontSize],
          NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.SelectedTextColor"]
        };
        item.normalTitleAttributes = normalTextAttributes;
        item.selectedTitleAttributes = selectedTextAttributes;
        
        if (index == SFMainChildViewControllerIndexOrder)
        {
            item.badgeTextFont = [UIFont systemFontOfSize:kSFOrderBadgeFontSize];
            item.badgeTextColor = [[RNThemeManager sharedManager] colorForKey:@"Main.TabBar.BadgeTextFontColor"];
            item.badgeBackgroundImage = nil;
            item.badgePositionAdjustment = UIOffsetMake(6, 10);
        }
        
        [items addObject:item];
    }];
    self.tabBar.items = items;
    [self.view addSubview:self.tabBar];
    
    // Content View Controllers
    SFHomePageViewController *homepage = [[SFHomePageViewController alloc] init];
    SFOriginViewController *origin = [[SFOriginViewController alloc] init];
    SFQuestionnaireViewController *questionnaire = [[SFQuestionnaireViewController alloc] init];
    SFOrderViewController *order = [[SFOrderViewController alloc] init];
    SFMyselfViewController *myself = [[SFMyselfViewController alloc] init];
    
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
                                   CGRectGetHeight(self.view.bounds) - kSFTabBarHeight,
                                   CGRectGetWidth(self.view.bounds),
                                   kSFTabBarHeight);
    for (UIViewController *contentViewController in self.contentViewControllers)
    {
        contentViewController.view.frame =
        CGRectMake(0,
                   kSFNavigationBarHeight,
                   CGRectGetWidth(self.view.bounds),
                   CGRectGetHeight(self.view.bounds) - kSFNavigationBarHeight - kSFTabBarHeight);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
               kSFNavigationBarHeight,
               CGRectGetWidth(self.view.bounds),
               CGRectGetHeight(self.view.bounds) - kSFNavigationBarHeight - kSFTabBarHeight);
    [self.view addSubview:newSelectedViewController.view];
    self.selectedViewController = newSelectedViewController;
}

- (void)enterMyselfPage
{
    SFMyselfViewController *myself = [self.contentViewControllers objectAtIndex:SFMainChildViewControllerIndexMyself];
    myself.login = YES;
#ifdef SF_UI_TEST
    myself.member = [[SFMember alloc] initWithJSONData:[self testMemberData]];
#else
    myself.member = [[SFMember alloc] initWithJSONData:[self.responseContent dataUsingEncoding:NSUTF8StringEncoding]];
#endif
    [self.tabBar setItemSelectedAtIndex:SFMainChildViewControllerIndexMyself];
    [self moveToChildViewControllerAtIndex:SFMainChildViewControllerIndexMyself];
    SFHomePageViewController *homepage = [self.contentViewControllers objectAtIndex:SFMainChildViewControllerIndexHomepage];
    [homepage showAllDishClasses];
    
    [CRModal dismiss];
}

#pragma mark - Target-Action

- (IBAction)onQRCodeButtonClicked:(id)sender
{
    SFQRCodeViewController *qrController = [[SFQRCodeViewController alloc] init];
    qrController.delegate = self;
    [self presentViewController:qrController animated:NO completion:nil];
}

- (void)onLoginButtonClickedInLoginView:(SFLoginView *)loginView
{
    if ([loginView.userName.text isEqualToString:@""]
        || [loginView.password.text isEqualToString:@""])
    {
        self.loginView.loginFailedMessage.hidden = NO;
        self.loginView.loginFailedMessage.text = @"会员卡号/手机号码与密码不能为空";
    }
    else
    {
#ifdef SF_UI_TEST
        [self enterMyselfPage];
#else
        self.loginView.loginFailedMessage.hidden = YES;
        
        [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeClear];
        
        NSURL *baseURL = [NSURL URLWithString:kSFWebServiceBaseURL];
        AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        httpManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        NSDictionary *parameters = @{
                                     @"name": loginView.userName.text,
                                     @"passwd": loginView.password.text,
                                     @"open_id": [SFDataManager sharedInstance].openid
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
#endif
    }
}

#pragma mark - Notification

- (void)onMoveToHomepageNotification:(NSNotification *)notification
{
    [self.tabBar setItemSelectedAtIndex:SFMainChildViewControllerIndexHomepage];
    [self moveToChildViewControllerAtIndex:SFMainChildViewControllerIndexHomepage];
}

- (void)onConnectToProjectorNotification:(NSNotification *)notification
{
    NSLog(@"Connect Projector");
}

- (void)onDisConnectToProjectorNotification:(NSNotification *)notification
{
    NSLog(@"Disconnect Projector");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(totalCount))])
    {
        NSNumber *totalCount = [SFOrderManager sharedInstance].totalCount;
        CRTabBarItem *item = [self.tabBar.items objectAtIndex:SFMainChildViewControllerIndexOrder];
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

#pragma mark - SFQRCodeViewControllerDelegate

- (void)qrCodeDidScan:(NSString *)codeString
{
    NSString  *urlRegEx =@"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil)
    {
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:codeString
                                                             options:0
                                                               range:NSMakeRange(0, [codeString length])];
        if (firstMatch)
        {
            NSRange matchRange = [firstMatch rangeAtIndex:0];
            NSString *projectorAddress = [codeString substringWithRange:matchRange];
            
            [[SFProjectorManager sharedInstance] connectToHost:projectorAddress];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"无效的立体投影仪地址，请重新扫描"];
        }
    }
}

#pragma mark - CRTabBarDelegate

- (BOOL)tabBar:(CRTabBar *)tabBar shouldSelecteItemAtIndex:(NSInteger)index
{
    if (index == SFMainChildViewControllerIndexMyself)
    {
        SFMyselfViewController *myself = [self.contentViewControllers objectAtIndex:SFMainChildViewControllerIndexMyself];
        if (!myself.login)
        {
            NSString *nibName = NSStringFromClass([SFLoginView class]);
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
        [self enterMyselfPage];
    }
}

#ifdef SF_UI_TEST

- (NSData *)testMemberData
{
    SFMember *member = [[SFMember alloc] init];
    NSMutableArray *records = [NSMutableArray arrayWithCapacity:6];
    
    for (int i = 0; i < 6; i++)
    {
        SFDiningRecord *record = [[SFDiningRecord alloc] init];
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:i + 1];
        int totalPrice = 0;
        int totalCount = 0;
        
        for (int j = 0; j < i + 1; j++)
        {
            int price = 20 + arc4random() % 100;
            int count = arc4random() % 2 + 1;
            
            SFRecordDishItem *item = [[SFRecordDishItem alloc] init];
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
        formatter.dateFormat = @"YYYY-MM-dd'T'hh:mm:ss";
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
