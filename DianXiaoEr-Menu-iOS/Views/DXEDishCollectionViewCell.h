//
//  DXEDishCollectionViewCell.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DXEDishCellMode) {
    DXEDishCellModeNormal,
    DXEDishCellModeInCart,
    DXEDishCellModeSoldout
};

@interface DXEDishCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dishName;
@property (weak, nonatomic) IBOutlet UILabel *dishEnglishName;
@property (weak, nonatomic) IBOutlet UIImageView *dishImage;
@property (weak, nonatomic) IBOutlet UILabel *dishPrice;
@property (weak, nonatomic) IBOutlet UIImageView *dishPriceIcon;
@property (weak, nonatomic) IBOutlet UILabel *dishFavor;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIImageView *inCartFlag;
@property (weak, nonatomic) IBOutlet UIImageView *soldoutFlag;
@property (weak, nonatomic) IBOutlet UIButton *favorButton;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;

@property (weak, nonatomic) id controller;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) DXEDishCellMode cellMode;

- (IBAction)onCartButtonClicked:(id)sender;
- (IBAction)onFavorButtonClicked:(id)sender;

- (void)showCellMode:(DXEDishCellMode)cellMode animate:(BOOL)animated;

@end
