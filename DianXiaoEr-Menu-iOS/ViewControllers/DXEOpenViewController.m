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
#import "CRModal.h"

@interface DXEOpenViewController ()

@property (nonatomic, strong) DXELoginView *loginView;

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

- (void)qrCodeDidScan:(NSString *)codeString
{
    self.tableNumber.text = codeString;
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
    self.loginView.loginFailedMessage.text = @"工号或密码输入错误，请重新输入！";
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
    [CRModal dismiss];
    [self enterMainPage];
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
//    self.loadingIndicator.hidden = YES;
    self.loadingLabel.hidden = YES;
    
    self.tableTitle.hidden = NO;
    self.tableSeperator.hidden = NO;
    self.tableNumber.hidden = NO;
    self.tableButton.hidden = NO;
    self.enterButton.hidden = NO;
}

@end
