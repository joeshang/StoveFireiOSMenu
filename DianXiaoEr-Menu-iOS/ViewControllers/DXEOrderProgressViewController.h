//
//  DXEOrderStatusViewController.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/24/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXEOrderProgressViewController : UIViewController
< UITableViewDelegate, UITableViewDataSource >

@property (weak, nonatomic) IBOutlet UITableView *dishesTableView;
@property (weak, nonatomic) IBOutlet UIImageView *todoIcon;
@property (weak, nonatomic) IBOutlet UIImageView *doingIcon;
@property (weak, nonatomic) IBOutlet UIImageView *doneIcon;
@property (weak, nonatomic) IBOutlet UILabel *todoTitle;
@property (weak, nonatomic) IBOutlet UILabel *doingTitle;
@property (weak, nonatomic) IBOutlet UILabel *doneTitle;
@property (weak, nonatomic) IBOutlet UILabel *todoCount;
@property (weak, nonatomic) IBOutlet UILabel *doingCount;
@property (weak, nonatomic) IBOutlet UILabel *doneCount;
@property (weak, nonatomic) IBOutlet UILabel *progressTitle;
@property (weak, nonatomic) IBOutlet UILabel *countTitle;

@end
