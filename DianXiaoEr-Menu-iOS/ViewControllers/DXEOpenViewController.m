//
//  DXEOpenViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/12/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOpenViewController.h"
#import "DXEMainViewController.h"
#import "DXELoginView.h"
#import "DXEDataManager.h"
#import "CRModal.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface DXEOpenViewController () < NSXMLParserDelegate >

@property (nonatomic, strong) DXELoginView *loginView;

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) NSXMLParser *loginParser;
@property (nonatomic, strong) NSXMLParser *openParser;

@end

@implementation DXEOpenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onLoadingProgressNotication:)
                                                     name:kDXEDidLoadingProgressNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onFinishLoadingNotication:)
                                                     name:kDXEDidFinishLoadingNotification
                                                   object:nil];
        
        NSURL *baseURL = [NSURL URLWithString:kDXEWebServiceBaseURL];
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
                         DXEMainViewController *main = [[DXEMainViewController alloc] init];
                         [UIApplication sharedApplication].keyWindow.rootViewController = main;
                     }];
}

#pragma mark - DXEQRCodeViewControllerDelegate

- (void)qrCodeDidScan:(NSString *)qrCode
{
    BOOL valid = NO;
    NSString *tableNumber = nil;
    for (NSDictionary *table in [DXEDataManager sharedInstance].tables)
    {
        NSNumber *tableid = [table objectForKey:@"id"];
        if ([qrCode intValue] == [tableid intValue])
        {
            valid = YES;
            [DXEDataManager sharedInstance].tableid = tableid;
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
        [DXEDataManager sharedInstance].tableid = nil;
    }
}

#pragma mark - Target-Action

- (IBAction)onEnterButtonClicked:(id)sender
{
    NSNumber *tableId = [DXEDataManager sharedInstance].tableid;
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
}

- (IBAction)onChoosingTableButtonClicked:(id)sender
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
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    int result = [string intValue];
    if (parser == self.openParser)
    {
        if (result >= 0)
        {
            [SVProgressHUD dismiss];
            [DXEDataManager sharedInstance].openid = [NSNumber numberWithInt:result];
            
            NSString *nibName = NSStringFromClass([DXELoginView class]);
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
        else
        {
            [SVProgressHUD showErrorWithStatus:@"此桌号未开台"];
        }
    }
    else if (parser == self.loginParser)
    {
        if (result >= 0)
        {
            [DXEDataManager sharedInstance].staffid = [NSNumber numberWithInt:result];
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
