//
//  DXEDishCollectionViewCell.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEDishCollectionViewCell.h"

#define kDXEDishCellAnimateDuration             0.3
#define kDXEDishCellDarkMaskAlpha               0.6

@implementation DXEDishCollectionViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.layer.cornerRadius = kDXECollectionViewCellRadius;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = kDXECollectionViewCellBorderWidth;
        self.layer.borderColor = [[UIColor blueColor] CGColor];
        
    }
    
    return self;
}

- (IBAction)onCartButtonClicked:(id)sender
{
    [self showCellMode:DXEDishCellModeInCart animate:YES];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:self];
    SEL selector = NSSelectorFromString(@"onCartButtonClickedInCollectionView:atIndexPath:");
    if ([self.controller respondsToSelector:selector])
    {
        [self.controller performSelector:selector
                              withObject:self.collectionView
                              withObject:indexPath];
    }
}

- (void)setCellMode:(DXEDishCellMode)cellMode
{
    [self showCellMode:cellMode animate:NO];
}

- (void)showCellMode:(DXEDishCellMode)cellMode animate:(BOOL)animated
{
    NSTimeInterval duration = 0.0;
    if (animated)
    {
        duration = kDXEDishCellAnimateDuration;
    }
    _cellMode = cellMode;
    
    switch (cellMode)
    {
        case DXEDishCellModeNormal:
        {
            self.cartButton.enabled = YES;
            self.cartButton.imageView.image = [UIImage imageNamed:@"cell_order_button"];
            [UIView animateWithDuration:kDXEDishCellAnimateDuration
                             animations:^{
                                 self.maskView.alpha = 0.0;
                                 self.inCartFlag.alpha = 0.0;
                                 self.soldoutFlag.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 self.maskView.hidden = YES;
                                 self.inCartFlag.hidden = YES;
                                 self.soldoutFlag.hidden = YES;
                             }];
            break;
        }
        case DXEDishCellModeInCart:
        {
            self.cartButton.enabled = YES;
            self.cartButton.imageView.image = [UIImage imageNamed:@"cell_order_button"];
            self.maskView.hidden = NO;
            self.inCartFlag.hidden = NO;
            [UIView animateWithDuration:kDXEDishCellAnimateDuration
                             animations:^{
                                 self.maskView.alpha = kDXEDishCellDarkMaskAlpha;
                                 self.inCartFlag.alpha = 1.0;
                                 self.soldoutFlag.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 self.soldoutFlag.hidden = YES;
                             }];
            break;
        }
        case DXEDishCellModeSoldout:
        {
            self.cartButton.enabled = NO;
            self.cartButton.imageView.image = [UIImage imageNamed:@"cell_soldout_button"];
            self.maskView.hidden = NO;
            self.soldoutFlag.hidden = NO;
            [UIView animateWithDuration:kDXEDishCellAnimateDuration
                             animations:^{
                                 self.maskView.alpha = kDXEDishCellDarkMaskAlpha;
                                 self.soldoutFlag.alpha = 1.0;
                                 self.inCartFlag.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 self.inCartFlag.hidden = YES;
                             }];
            break;
        }
        default:
            break;
    }
}

@end
