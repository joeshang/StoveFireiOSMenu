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

- (void)awakeFromNib
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = kDXECommonCornerRadius;
    self.layer.borderWidth = kDXECommonBorderWidth;
    self.layer.borderColor = [[[RNThemeManager sharedManager] colorForKey:@"BorderColor"] CGColor];
    
    self.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(onTapOnDishImage:)];
    [self.dishImage addGestureRecognizer:tapRecognizer];
}

- (IBAction)onCartButtonClicked:(id)sender
{
    SEL selector = NSSelectorFromString(@"onCartButtonClickedInCollectionView:atIndexPath:");
    [self sendActionToControllerWithSelector:selector];
}

- (IBAction)onFavorButtonClicked:(id)sender
{
    SEL selector = NSSelectorFromString(@"onFavorButtonClickedInCollectionView:atIndexPath:");
    [self sendActionToControllerWithSelector:selector];
}

- (void)onTapOnDishImage:(id)sender
{
    SEL selector = NSSelectorFromString(@"onTapOnDishImageInCollectionView:atIndexPath:");
    [self sendActionToControllerWithSelector:selector];
}

- (void)sendActionToControllerWithSelector:(SEL)selector
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:self];
    if ([self.controller respondsToSelector:selector])
    {
        // func is a trick for performSelector:withObject without "may cause a leak because its selector is unknown" warning
        // [self.controller performSelector:selector
        //                       withObject:self.collectionView
        //                       withObject:indexPath];
        IMP imp = [self.controller methodForSelector:selector];
        void (*func)(id, SEL, UICollectionView *, NSIndexPath *) = (void *)imp;
        func(self.controller, selector, self.collectionView, indexPath);
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
            self.cartButton.imageView.image = [UIImage imageNamed:@"cell_add2cart_button"];
            [UIView animateWithDuration:duration
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
            self.cartButton.imageView.image = [UIImage imageNamed:@"cell_add2cart_button"];
            self.inCartFlag.hidden = NO;
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.maskView.alpha = 0.0;
                                 self.inCartFlag.alpha = 1.0;
                                 self.soldoutFlag.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 self.maskView.hidden = YES;
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
            [UIView animateWithDuration:duration
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
