//
//  SFMemberLoginView.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/25/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFLoginView : UIView

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *loginFailedMessage;

@property (weak, nonatomic) id controller;

@property (strong, nonatomic) NSString *userNamePlaceholder;

@end
