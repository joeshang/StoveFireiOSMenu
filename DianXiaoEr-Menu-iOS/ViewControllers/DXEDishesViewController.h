//
//  DXEDishesViewController.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"

@class DXEDishItem;
@class DXEDishClass;

@interface DXEDishesViewController : UICollectionViewController
< UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout >

@property (nonatomic, strong) DXEDishClass *dishClass;

- (void)updateDishCellByDishItem:(DXEDishItem *)item;

@end
