//
//  DXEOrderViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderViewController.h"
#import "RDVTabBarItem.h"
#import "RDVTabBarController.h"
#import "DXEOrderManager.h"
#import "DXEOrderCartViewController.h"

@interface DXEOrderViewController ()

@end

@implementation DXEOrderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[DXEOrderManager sharedInstance] addObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(totalCount))
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
    }
    return self;
}

- (void)dealloc
{
    [[DXEOrderManager sharedInstance] removeObserver:self
                                          forKeyPath:NSStringFromSelector(@selector(totalCount))];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"Order.BackgroundColor"];
    
    DXEOrderCartViewController *cart = [[DXEOrderCartViewController alloc] init];
    CRScrollMenuItem *cartItem = [[CRScrollMenuItem alloc] init];
    cartItem.title = @"已点菜单";
    
    [self.scrollMenuController setViewControllers:@[cart]
                                        withItems:@[cartItem]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(totalCount))])
    {
        NSLog(@"%@", change);
        
        NSNumber *totalCount = [DXEOrderManager sharedInstance].totalCount;
        if ([totalCount integerValue] == 0)
        {
            self.rdv_tabBarItem.badgeValue = @"";
        }
        else
        {
            self.rdv_tabBarItem.badgeValue = [totalCount stringValue];
        }
    }
}

@end
