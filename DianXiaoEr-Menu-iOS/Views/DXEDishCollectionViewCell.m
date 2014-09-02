//
//  DXEDishCollectionViewCell.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEDishCollectionViewCell.h"

#define kDXEDishCellAnimateDuration             0.3

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
    [self showInCartStatus];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:self];
    SEL selector = NSSelectorFromString(@"onCartButtonClickedAtIndexPath:");
    if ([self.controller respondsToSelector:selector])
    {
        [self.controller performSelector:selector
                              withObject:indexPath];
    }
}

- (void)showInCartStatus
{
    self.maskImage.image = [UIImage imageNamed:@"cell_incart_mask"];
    self.maskImage.hidden = NO;
    [UIView animateWithDuration:kDXEDishCellAnimateDuration
                     animations:^{
                         self.maskImage.alpha = 0.4;
                     }];
}

- (void)showNormalStatus
{
    [UIView animateWithDuration:kDXEDishCellAnimateDuration
                     animations:^{
                         self.maskImage.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         self.maskImage.hidden = YES;
                     }];
}

- (void)showSoldoutStatus
{
    self.maskImage.image = [UIImage imageNamed:@"cell_soldout_mask"];
    self.maskImage.hidden = NO;
    [UIView animateWithDuration:kDXEDishCellAnimateDuration
                     animations:^{
                         self.maskImage.alpha = 0.4;
                     }];
}

@end
