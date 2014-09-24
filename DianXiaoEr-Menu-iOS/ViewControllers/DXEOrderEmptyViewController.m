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
        _type = DXEOrderEmptyViewControllerTypeNotOrdered;
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
    
    if (self.type == DXEOrderEmptyViewControllerTypeNotOrdered)
    {
        self.tipsImageView.image = [UIImage imageNamed:@"order_empty_cart_not_ordered"];
        self.tipsTitle.text = @"不忍心让盘子空着?";
        self.tipsSubtitle.text = @"快去点餐吧!";
    }
    else if (self.type == DXEOrderEmptyViewControllerTypeOrdered)
    {
        self.tipsImageView.image = [UIImage imageNamed:@"order_empty_cart_ordered"];
        self.tipsTitle.text = @"厨师正在为您制作美食";
        self.tipsSubtitle.text = @"请耐心等待，还需要加餐吗?";
    }
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
