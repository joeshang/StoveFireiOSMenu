//
//  SFOrderProgressTableViewCell.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/24/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFOrderProgressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *dishThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *dishName;
@property (weak, nonatomic) IBOutlet UILabel *dishEnglishName;
@property (weak, nonatomic) IBOutlet UILabel *dishCount;
@property (weak, nonatomic) IBOutlet UILabel *dishPrice;
@property (weak, nonatomic) IBOutlet UILabel *dishTotalPrice;
@property (weak, nonatomic) IBOutlet UIImageView *dishVipFlag;
@property (weak, nonatomic) IBOutlet UIImageView *todoPoint;
@property (weak, nonatomic) IBOutlet UIImageView *doingPoint;
@property (weak, nonatomic) IBOutlet UIImageView *donePoint;
@property (weak, nonatomic) IBOutlet UIImageView *doingLine;
@property (weak, nonatomic) IBOutlet UIImageView *doneLine;
@property (weak, nonatomic) IBOutlet UILabel *todoTitle;
@property (weak, nonatomic) IBOutlet UILabel *doingTitle;
@property (weak, nonatomic) IBOutlet UILabel *doneTitle;

@property (assign, nonatomic) SFDishProgress state;

@end
