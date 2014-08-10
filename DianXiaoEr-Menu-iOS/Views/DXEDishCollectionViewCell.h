//
//  DXEDishCollectionViewCell.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXEDishCollectionViewCell : UICollectionViewCell

@property (nonatomic) IBOutlet UILabel *dishName;
@property (nonatomic) IBOutlet UILabel *dishEnglishName;
@property (nonatomic) IBOutlet UIImageView *dishImage;
@property (nonatomic) IBOutlet UILabel *dishPrice;
@property (nonatomic) IBOutlet UIImageView *dishPriceIcon;
@property (nonatomic) IBOutlet UILabel *dishFavor;
@property (nonatomic) IBOutlet UIImageView *dishFavorIcon;

@end
