//
//  DXEOpenViewController.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/12/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXEOpenViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;

- (IBAction)onLoginButtonClicked:(id)sender;

@end
