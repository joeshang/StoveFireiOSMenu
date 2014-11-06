//
//  SFOrderStatusViewController.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/24/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFOrderProgressViewController : UIViewController
< UITableViewDelegate, UITableViewDataSource >

@property (weak, nonatomic) IBOutlet UITableView *dishesTableView;
@property (weak, nonatomic) IBOutlet UILabel *todoCount;
@property (weak, nonatomic) IBOutlet UILabel *doingCount;
@property (weak, nonatomic) IBOutlet UILabel *doneCount;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

@end
