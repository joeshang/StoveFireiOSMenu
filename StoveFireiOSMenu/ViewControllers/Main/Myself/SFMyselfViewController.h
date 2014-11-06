//
//  SFMyselfViewController.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFMember;

@interface SFMyselfViewController : UIViewController
< UITableViewDataSource, UITableViewDelegate >

@property (weak, nonatomic) IBOutlet UILabel *memberName;
@property (weak, nonatomic) IBOutlet UILabel *memberPhone;
@property (weak, nonatomic) IBOutlet UILabel *memberAccount;
@property (weak, nonatomic) IBOutlet UITableView *recordTableView;
@property (weak, nonatomic) IBOutlet UIImageView *recordEmptyTips;

@property (strong, nonatomic) SFMember *member;
@property (assign, nonatomic) BOOL login;

@end
