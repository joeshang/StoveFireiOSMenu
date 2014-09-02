//
//  DXEDishCollectionViewCell.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXEDishCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dishName;
@property (weak, nonatomic) IBOutlet UILabel *dishEnglishName;
@property (weak, nonatomic) IBOutlet UIImageView *dishImage;
@property (weak, nonatomic) IBOutlet UILabel *dishPrice;
@property (weak, nonatomic) IBOutlet UIImageView *dishPriceIcon;
@property (weak, nonatomic) IBOutlet UILabel *dishFavor;
@property (weak, nonatomic) IBOutlet UIImageView *dishFavorIcon;
@property (weak, nonatomic) IBOutlet UIImageView *maskImage;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;

@property (weak, nonatomic) id controller;
@property (weak, nonatomic) UICollectionView *collectionView;

- (IBAction)onCartButtonClicked:(id)sender;

@end
