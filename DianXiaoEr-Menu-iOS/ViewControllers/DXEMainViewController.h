//
//  DXETopBarBaseViewController.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/16/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXEQRCodeViewController.h"

@class CRTabBar;

@interface DXEMainViewController : UIViewController
< DXEQRCodeViewControllerDelegate >

@property (nonatomic, strong) CRTabBar *tabBar;
@property (nonatomic, strong) NSArray *contentViewControllers;
@property (nonatomic, strong) UIViewController *selectedViewController;

@end
