//
//  SFDishesViewController.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"

@class SFDishItem;
@class SFDishClass;

@interface SFDishesViewController : UICollectionViewController
< UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout >

@property (nonatomic, strong) SFDishClass *dishClass;

- (void)updateDishCellByDishItem:(SFDishItem *)item;

@end
