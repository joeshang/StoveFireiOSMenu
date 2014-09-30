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

@property (weak, nonatomic) IBOutlet UILabel *table;

@end
