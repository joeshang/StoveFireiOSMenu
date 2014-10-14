//
//  DXEOpenViewController.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/12/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXEQRCodeViewController.h"

@interface DXEOpenViewController : UIViewController
< DXEQRCodeViewControllerDelegate >

@property (weak, nonatomic) IBOutlet UILabel *tableNumber;
@property (weak, nonatomic) IBOutlet UILabel *tableTitle;
@property (weak, nonatomic) IBOutlet UIImageView *tableSeperator;
@property (weak, nonatomic) IBOutlet UIButton *tableButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loadingErrorIcon;

@end
