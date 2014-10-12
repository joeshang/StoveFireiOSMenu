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

@interface DXEOpenViewController () < NSXMLParserDelegate >

@property (nonatomic, strong) DXELoginView *loginView;

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
            [DXEDataManager sharedInstance].tableid = [tableid stringValue];
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
    }
}

#pragma mark - Target-Action

- (IBAction)onEnterButtonClicked:(id)sender
{
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

- (IBAction)onChoosingTableButtonClicked:(id)sender
{
    DXEQRCodeViewController *scanning = [[DXEQRCodeViewController alloc] init];
    scanning.delegate = self;
    [self presentViewController:scanning animated:NO completion:nil];
}

- (void)onLoginButtonClickedInLoginView:(DXELoginView *)loginView
{
    NSURL *baseURL = [NSURL URLWithString:kDXEWebServiceBaseURL];
    NSDictionary *parameters = @{
                                 @"name": loginView.userName.text,
                                 @"passwd": loginView.password.text
                                 };
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [manager POST:@"WaiterLogin" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
        self.loginParser = (NSXMLParser *)responseObject;
        self.loginParser.delegate = self;
        [self.loginParser parse];
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        self.loginView.loginFailedMessage.text = @"网络连接错误，请检查网络";
        NSLog(@"%@", error);
    }];
}

#pragma mark - Notfication

- (void)onLoadingProgressNotication:(NSNotification *)notification
{
    NSString *message = [notification.userInfo objectForKey:@"message"];
    self.loadingLabel.text = message;
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

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (parser == self.openParser)
    {
        
    }
    else if (parser == self.loginParser)
    {
        int result = [string intValue];
        if (result >= 0)
        {
            [DXEDataManager sharedInstance].staffid = string;
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

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}

@end
