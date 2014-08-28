//
//  DXEOpenViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/12/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOpenViewController.h"
#import "DXEMainViewController.h"

@interface DXEOpenViewController ()

@end

@implementation DXEOpenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
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

#pragma mark - Target-Action

- (IBAction)onLoginButtonClicked:(id)sender
{
    DXEMainViewController *main = [[DXEMainViewController alloc] init];
    [self.navigationController pushViewController:main animated:YES];
}

@end
