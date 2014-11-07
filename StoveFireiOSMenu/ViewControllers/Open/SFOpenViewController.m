//
//  SFOpenViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 8/12/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOpenViewController.h"
#import "SFMainViewController.h"
#import "SFLoginView.h"
#import "SFOrderItem.h"
#import "SFDataManager.h"
#import "SFOrderManager.h"
#import "CRModal.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface SFOpenViewController () < NSXMLParserDelegate >

@property (nonatomic, strong) SFLoginView *loginView;

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) NSString *responseContent;
@property (nonatomic, strong) NSXMLParser *loginParser;
@property (nonatomic, strong) NSXMLParser *openParser;

@end

@implementation SFOpenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onLoadingProgressNotication:)
                                                     name:kSFDidLoadingProgressNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onFinishLoadingNotication:)
                                                     name:kSFDidFinishLoadingNotification
                                                   object:nil];
        
        NSURL *baseURL = [NSURL URLWithString:kSFWebServiceBaseURL];
        _httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        _httpManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

#ifdef SF_UI_TEST
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [self onFinishLoadingNotication:nil];
    });
#endif
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

- (void)enterMainPage
{
    [UIView animateWithDuration:0.3
                          delay:0.3
                        options:0
                     animations:^{
                         self.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self willMoveToParentViewController:nil];
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                     }];
}

#pragma mark - SFQRCodeViewControllerDelegate

- (void)qrCodeDidScan:(NSString *)qrCode
{
    BOOL valid = NO;
    NSString *tableNumber = nil;
    for (NSDictionary *table in [SFDataManager sharedInstance].tables)
    {
        NSNumber *tableid = [table objectForKey:@"id"];
        if ([qrCode intValue] == [tableid intValue])
        {
            valid = YES;
            [SFDataManager sharedInstance].tableid = tableid;
            tableNumber = [table objectForKey:@"name"];
            break;
        }
    }
    
    if (valid)
    {
        self.tableNumber.text = tableNumber;
    }
    else
    {
        self.tableNumber.text = @"非桌号二维码 请再次扫描";
        [SFDataManager sharedInstance].tableid = nil;
    }
}

#pragma mark - Target-Action

- (IBAction)onEnterButtonClicked:(id)sender
{
#ifdef SF_UI_TEST
    [self enterMainPage];
#else
    NSNumber *tableId = [SFDataManager sharedInstance].tableid;
    if (tableId == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"请选择桌号"];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeClear];
        
        NSDictionary *parameters = @{
                                     @"tableId": tableId
                                     };
        [self.httpManager POST:@"GetOpenId" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
            self.openParser = (NSXMLParser *)responseObject;
            self.openParser.delegate = self;
            [self.openParser parse];
        } failure:^(NSURLSessionDataTask *task, NSError *error){
            [SVProgressHUD showErrorWithStatus:@"网络错误"];
        }];
    }
#endif
}

- (IBAction)onChoosingTableButtonClicked:(id)sender
{
    SFQRCodeViewController *scanning = [[SFQRCodeViewController alloc] init];
    scanning.delegate = self;
    [self presentViewController:scanning animated:NO completion:nil];
}

- (void)onLoginButtonClickedInLoginView:(SFLoginView *)loginView
{
    if ([loginView.userName.text isEqualToString:@""]
        || [loginView.password.text isEqualToString:@""])
    {
        self.loginView.loginFailedMessage.hidden = NO;
        self.loginView.loginFailedMessage.text = @"工号与密码不能为空";
    }
    else
    {
        self.loginView.loginFailedMessage.hidden = YES;
        
        [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeClear];
        
        NSDictionary *parameters = @{
                                     @"name": loginView.userName.text,
                                     @"passwd": loginView.password.text
                                     };
        [self.httpManager POST:@"WaiterLogin" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
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

#pragma mark - Notfication

- (void)onLoadingProgressNotication:(NSNotification *)notification
{
    NSString *error = [notification.userInfo objectForKey:@"error"];
    if (error)
    {
        [self.loadingIndicator stopAnimating];
        self.loadingLabel.text = error;
        self.loadingErrorIcon.hidden = NO;
    }
    else
    {
        NSString *message = [notification.userInfo objectForKey:@"message"];
        self.loadingLabel.text = message;
    }
}

- (void)onFinishLoadingNotication:(NSNotification *)notification
{
    [self.loadingIndicator stopAnimating];
    self.loadingLabel.hidden = YES;
    
    self.tableTitle.hidden = NO;
    self.tableSeperator.hidden = NO;
    self.tableNumber.hidden = NO;
    self.tableButton.hidden = NO;
    self.enterButton.hidden = NO;
    
    SFMainViewController *main = [[SFMainViewController alloc] init];
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    [root addChildViewController:main];
    [root.view insertSubview:main.view belowSubview:self.view];
    [main didMoveToParentViewController:root];
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
    if (parser == self.openParser)
    {
        if ([self.responseContent isEqualToString:@""])
        {
            [SVProgressHUD showErrorWithStatus:@"此桌号未开台"];
        }
        else
        {
            [SVProgressHUD dismiss];
            
            NSDictionary *content = [NSJSONSerialization JSONObjectWithData:[self.responseContent dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            [SFDataManager sharedInstance].openid = [content objectForKey:@"open_id"];
            NSArray *order_list = [content objectForKey:@"order_list"];
            for (NSDictionary *order in order_list)
            {
                if ([[order objectForKey:@"status"] intValue] != -1)
                {
                    SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:[order objectForKey:@"dish_id"]];
                    if (dish)
                    {
                        SFOrderItem *item = [[SFOrderItem alloc] initWithItemid:dish.itemid];
                        item.count = [order objectForKey:@"count"];
                        item.tradeid = [order objectForKey:@"trade_id"];
                        item.progress = [order objectForKey:@"status"];
                        [[SFOrderManager sharedInstance].order addObject:item];
                    }
                }
            }
            
            NSString *nibName = NSStringFromClass([SFLoginView class]);
            self.loginView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                    owner:self
                                                  options:nil] firstObject];
            self.loginView.controller = self;
            self.loginView.userNamePlaceholder = @"工号";
            [CRModal showModalView:self.loginView
                       coverOption:CRModalOptionCoverDark
               tapOutsideToDismiss:NO
                          animated:YES
                        completion:nil];
        }
    }
    else if (parser == self.loginParser)
    {
        int result = [self.responseContent intValue];
        if (result >= 0)
        {
            [SFDataManager sharedInstance].staffid = [NSNumber numberWithInt:result];
            [CRModal dismiss];
            [self enterMainPage];
        }
        else
        {
            self.loginView.loginFailedMessage.text = @"工号或密码输入错误，请重新输入！";
            self.loginView.loginFailedMessage.hidden = NO;
        }
    }
}

@end
