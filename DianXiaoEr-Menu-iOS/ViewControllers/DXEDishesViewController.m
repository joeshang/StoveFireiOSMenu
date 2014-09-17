//
//  DXEDishesViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEDishesViewController.h"
#import "DXETipsColletionViewCell.h"
#import "DXEDishCollectionViewCell.h"
#import "CRModal.h"
#import "DXEDishDetailView.h"
#import "DXEImageManager.h"
#import "DXEOrderManager.h"

#define kDXECollectionViewCellWidth             357
#define kDXECollectionViewInfoCellHeight        140
#define kDXECollectionViewDishCellHeight        597

@interface DXEDishesViewController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) DXEDishDetailView *dishDetailView;

@end

@implementation DXEDishesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionView.BackgroundColor"];
    self.collectionView.tag = [self.dishClass.classid intValue];
    self.collectionView.delaysContentTouches = NO;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DXETipsCollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:@"DXETipsCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DXEDishCollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:@"DXEDishCollectionViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dishClass.dishes count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        DXETipsColletionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXETipsCollectionViewCell"
                                                                                   forIndexPath:indexPath];
        cell.tipsImage.image = [[DXEImageManager sharedInstance] imageForKey:self.dishClass.imageKey];
        
        return cell;
    }
    else
    {
        DXEDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
        DXEDishCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXEDishCollectionViewCell"
                                                                                    forIndexPath:indexPath];
        
        if ([item.soldout boolValue] == YES)
        {
            cell.cellMode = DXEDishCellModeSoldout;
        }
        else
        {
            if (item.inCart == YES)
            {
                cell.cellMode = DXEDishCellModeInCart;
            }
            else
            {
                cell.cellMode = DXEDishCellModeNormal;
            }
        }
        
        cell.dishName.text = item.name;
        cell.dishImage.image = [[DXEImageManager sharedInstance] imageForKey:item.imageKey];
        cell.dishPrice.text = [NSString stringWithFormat:@"%.2f", [item.price floatValue]];
        cell.dishFavor.text = [item.favor stringValue];
        if (item.inFavor)
        {
            [cell.favorButton setImage:[UIImage imageNamed:@"dish_cell_favor_solid_icon"]
                              forState:UIControlStateNormal];
        }
        else
        {
            [cell.favorButton setImage:[UIImage imageNamed:@"dish_cell_favor_hollow_icon"]
                              forState:UIControlStateNormal];
        }
        
        cell.controller = self;
        cell.collectionView = collectionView;
        
        return cell;
    }
}

#pragma mark- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"page: %ld, index: %ld", collectionView.tag, indexPath.row);
    
    DXEDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
    if ([item.soldout boolValue] == NO)
    {
        self.selectedIndexPath = indexPath;
        
        self.dishDetailView = [[[NSBundle mainBundle] loadNibNamed:@"DXEDishDetailView" owner:self options:nil] firstObject];
        self.dishDetailView.dishName.text = item.name;
        self.dishDetailView.dishPrice.text = [NSString stringWithFormat:@"%.2f", [item.price floatValue]];
        self.dishDetailView.dishFavor.text = [item.favor stringValue];
        self.dishDetailView.dishIngredient.selectable = YES;
        self.dishDetailView.dishIngredient.text = item.ingredient;
        self.dishDetailView.dishIngredient.selectable = NO;
        self.dishDetailView.dishImage.image = [[DXEImageManager sharedInstance] imageForKey:item.imageKey];
        if (item.inCart)
        {
            self.dishDetailView.inCartFlag.alpha = 1.0;
        }
        else
        {
            self.dishDetailView.inCartFlag.alpha = 0.0;
        }
        if (item.inFavor)
        {
            [self.dishDetailView.favorButton setImage:[UIImage imageNamed:@"dish_cell_favor_solid_icon"]
                                             forState:UIControlStateNormal];
        }
        else
        {
            [self.dishDetailView.favorButton setImage:[UIImage imageNamed:@"dish_cell_favor_hollow_icon"]
                                             forState:UIControlStateNormal];
        }
        
        [CRModal showModalView:self.dishDetailView
                   coverOption:CRModalOptionCoverDark
           tapOutsideToDismiss:YES
                      animated:YES
                    completion:^{
                        self.selectedIndexPath = nil;
                        self.dishDetailView = nil;
                    }];
    }
}

#pragma mark - CHTCollectionViewDelegateWaterflowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    if (indexPath.row == 0)
    {
        size = CGSizeMake(kDXECollectionViewCellWidth, kDXECollectionViewInfoCellHeight);
    }
    else
    {
        size = CGSizeMake(kDXECollectionViewCellWidth, kDXECollectionViewDishCellHeight);
    }
    
    return size;
}

#pragma mark - Target-Action

- (void)onCartButtonClickedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    DXEDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
    
    if (!item.inCart)
    {
        item.inCart = YES;
        item.count = 1;
        [[DXEOrderManager sharedInstance].cart addObject:item];
    }
    else
    {
        item.count++;
    }
}

- (IBAction)onCartButtonClickedInDishDetailView:(id)sender
{
    DXEDishItem *item = [self.dishClass.dishes objectAtIndex:self.selectedIndexPath.row - 1];
    if (!item.inCart)
    {
        item.inCart = YES;
        item.count = 1;
        [[DXEOrderManager sharedInstance].cart addObject:item];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.dishDetailView.inCartFlag.alpha = 1.0;
        }];
    }
    else
    {
        item.count++;
    }
    
    [self.collectionView reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
}

- (IBAction)onTapOnDishImage:(id)sender
{
    [CRModal dismiss];
}

- (void)onFavorButtonClickedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    DXEDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
    if (item.inFavor)
    {
        item.inFavor = NO;
        item.favor = [NSNumber numberWithInt:[item.favor intValue] - 1];
    }
    else
    {
        item.inFavor = YES;
        item.favor = [NSNumber numberWithInt:[item.favor intValue] + 1];
    }
    
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (IBAction)onFavorButtonClickedInDishDetailView:(id)sender
{
    DXEDishItem *item = [self.dishClass.dishes objectAtIndex:self.selectedIndexPath.row - 1];
    if (item.inFavor)
    {
        item.inFavor = NO;
        item.favor = [NSNumber numberWithInt:[item.favor intValue] - 1];
        [self.dishDetailView.favorButton setImage:[UIImage imageNamed:@"dish_cell_favor_hollow_icon"]
                                         forState:UIControlStateNormal];
    }
    else
    {
        item.inFavor = YES;
        item.favor = [NSNumber numberWithInt:[item.favor intValue] + 1];
        [self.dishDetailView.favorButton setImage:[UIImage imageNamed:@"dish_cell_favor_solid_icon"]
                                         forState:UIControlStateNormal];
    }
    self.dishDetailView.dishFavor.text = [item.favor stringValue];
    [self.collectionView reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
}

@end
