//
//  DXEQuestionnaireViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEQuestionnaireViewController.h"

@interface DXEQuestionnaireViewController ()

@end

@implementation DXEQuestionnaireViewController

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
    
    UIColor *backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    self.view.backgroundColor = backgroundColor;
    self.webView.backgroundColor = backgroundColor;
    
    NSURL *url = [NSURL URLWithString:kDXEWebServiceBaseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
