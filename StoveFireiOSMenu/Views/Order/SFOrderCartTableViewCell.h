//
//  SFDishInCartTableViewCell.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/17/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSFDishItemCountInCartMin                  1
#define kSFDishItemCountInCartMax                  99

@interface SFOrderCartTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *dishThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *dishName;
@property (weak, nonatomic) IBOutlet UILabel *dishEnglishName;
@property (weak, nonatomic) IBOutlet UILabel *dishCount;
@property (weak, nonatomic) IBOutlet UIButton *decreaseButton;
@property (weak, nonatomic) IBOutlet UIButton *increaseButton;
@property (weak, nonatomic) IBOutlet UIImageView *countUnderline;
@property (weak, nonatomic) IBOutlet UILabel *dishPrice;
@property (weak, nonatomic) IBOutlet UILabel *dishTotalPrice;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *dishVipFlag;

@property (weak, nonatomic) id controller;

- (IBAction)onIncreaseButtonClicked:(id)sender;
- (IBAction)onDecreaseButtonClicked:(id)sender;
- (IBAction)onDeleteButtonClicked:(id)sender;

- (void)updateCellByDishCount:(NSInteger)count dishPrice:(float)price;

@end
