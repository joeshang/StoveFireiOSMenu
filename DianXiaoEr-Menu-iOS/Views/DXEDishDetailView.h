//
//  DXEDishDetailView.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/4/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXEDishItem.h"

@interface DXEDishDetailView : UIView

@property (weak, nonatomic) IBOutlet UILabel *dishName;
@property (weak, nonatomic) IBOutlet UILabel *dishEnglishName;
@property (weak, nonatomic) IBOutlet UIImageView *dishImage;
@property (weak, nonatomic) IBOutlet UILabel *dishPrice;
@property (weak, nonatomic) IBOutlet UILabel *dishFavor;
@property (weak, nonatomic) IBOutlet UIButton *favorButton;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;
@property (weak, nonatomic) IBOutlet UIImageView *separator;
@property (weak, nonatomic) IBOutlet UITextView *dishIngredient;
@property (weak, nonatomic) IBOutlet UIImageView *inCartFlag;

@end
