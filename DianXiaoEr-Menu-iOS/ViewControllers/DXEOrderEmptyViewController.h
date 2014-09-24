//
//  DXEOrderEmptyViewController.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/23/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DXEOrderEmptyViewControllerType)
{
    DXEOrderEmptyViewControllerTypeNotOrdered,
    DXEOrderEmptyViewControllerTypeOrdered
};

@interface DXEOrderEmptyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *moveToHomepageButton;
@property (weak, nonatomic) IBOutlet UIImageView *tipsImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipsTitle;
@property (weak, nonatomic) IBOutlet UILabel *tipsSubtitle;

@property (assign, nonatomic) DXEOrderEmptyViewControllerType type;

@end
