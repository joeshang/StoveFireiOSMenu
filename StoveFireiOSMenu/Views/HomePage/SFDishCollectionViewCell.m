//
//  SFDishCollectionViewCell.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFDishCollectionViewCell.h"

#define kSFDishCellAnimateDuration             0.3
#define kSFDishCellDarkMaskAlpha               0.6

@implementation SFDishCollectionViewCell

- (void)awakeFromNib
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = kSFCommonCornerRadius;
    self.layer.borderWidth = kSFCommonBorderWidth;
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

- (void)setCellMode:(SFDishCellMode)cellMode
{
    [self showCellMode:cellMode animate:NO];
}

- (void)showCellMode:(SFDishCellMode)cellMode animate:(BOOL)animated
{
    NSTimeInterval duration = 0.0;
    if (animated)
    {
        duration = kSFDishCellAnimateDuration;
    }
    _cellMode = cellMode;
    
    switch (cellMode)
    {
        case SFDishCellModeNormal:
        {
            self.cartIcon.hidden = NO;
            self.cartButton.enabled = YES;
            self.cartButton.alpha = 1.0;
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
        case SFDishCellModeInCart:
        {
            self.cartIcon.hidden = NO;
            self.cartButton.enabled = YES;
            self.cartButton.alpha = 1.0;
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
        case SFDishCellModeSoldout:
        {
            self.cartIcon.hidden = YES;
            self.cartButton.enabled = NO;
            self.cartButton.alpha = 0.5;
            self.maskView.hidden = NO;
            self.soldoutFlag.hidden = NO;
            [UIView animateWithDuration:duration
                             animations:^{
                                 self.maskView.alpha = kSFDishCellDarkMaskAlpha;
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
