//
//  DXEMyselfViewController.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXEMember;

@interface DXEMyselfViewController : UIViewController
< UITableViewDataSource, UITableViewDelegate >

@property (weak, nonatomic) IBOutlet UIImageView *memberImage;
@property (weak, nonatomic) IBOutlet UILabel *memberUppercaseName;
@property (weak, nonatomic) IBOutlet UILabel *memberName;
@property (weak, nonatomic) IBOutlet UILabel *memberPhone;
@property (weak, nonatomic) IBOutlet UILabel *memberAccount;
@property (weak, nonatomic) IBOutlet UITableView *recordTableView;
@property (weak, nonatomic) IBOutlet UIImageView *recordEmptyTips;

@property (strong, nonatomic) DXEMember *member;
@property (assign, nonatomic) BOOL login;

@end
