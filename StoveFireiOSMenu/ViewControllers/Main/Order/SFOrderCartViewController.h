//
//  SFOrderCartViewController.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFOrderCartViewController : UIViewController
< UITableViewDelegate, UITableViewDataSource >

@property (nonatomic, weak) IBOutlet UITableView *dishesTableView;

@end
