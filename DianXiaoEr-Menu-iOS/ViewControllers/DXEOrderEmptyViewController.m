//
//  DXEOrderEmptyViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/23/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderEmptyViewController.h"

@interface DXEOrderEmptyViewController ()

@end

@implementation DXEOrderEmptyViewController

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
    
    self.view.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    
    UIColor *textColor = [[RNThemeManager sharedManager] colorForKey:@"Order.Empty.FontColor"];
    self.tipsTitle.textColor = textColor;
    self.tipsSubtitle.textColor = textColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onMoveToHomepageButtonClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MoveToHomepage"
                                                        object:self];
}

@end
