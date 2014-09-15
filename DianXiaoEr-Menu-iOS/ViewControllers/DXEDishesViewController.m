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

#define kDXECollectionViewCellWidth             360
#define kDXECollectionViewInfoCellHeight        140
#define kDXECollectionViewDishCellHeight        600

@interface DXEDishesViewController ()

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
        DXEDishDetailView *dishDetailView = [[[NSBundle mainBundle] loadNibNamed:@"DXEDishDetailView" owner:self options:nil] firstObject];
        dishDetailView.dishName.text = item.name;
        dishDetailView.dishPrice.text = [NSString stringWithFormat:@"%.2f", [item.price floatValue]];
        dishDetailView.dishFavor.text = [item.favor stringValue];
        dishDetailView.dishIngredient.selectable = YES;
        dishDetailView.dishIngredient.text = item.ingredient;
        dishDetailView.dishIngredient.selectable = NO;
        dishDetailView.dishImage.image = [[DXEImageManager sharedInstance] imageForKey:item.imageKey];
        
        [CRModal showModalView:dishDetailView
                   coverOption:CRModalOptionCoverDark
           tapOutsideToDismiss:YES
                      animated:YES
                    completion:nil];
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
    
    if (item.inCart == NO)
    {
        item.inCart = YES;
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

- (IBAction)onCartButtonClickedInDishDetailView:(id)sender
{
    [CRModal dismiss];
}

@end
