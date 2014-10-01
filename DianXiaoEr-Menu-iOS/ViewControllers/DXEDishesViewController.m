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
#import "DXEDishClass.h"
#import "DXEImageManager.h"
#import "DXEOrderManager.h"
#import "UIView+Genie.h"

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
    self.collectionView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
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

- (void)updateDishCellByDishItem:(DXEDishItem *)item
{
    NSUInteger index = [self.dishClass.dishes indexOfObjectIdenticalTo:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index + 1 inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
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
        cell.dishEnglishName.text = item.englishName;
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

#pragma mark - Target-Action in Collection View

- (void)onCartButtonClickedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    DXEDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
    
    if (!item.inCart)
    {
        item.count = [NSNumber numberWithInteger:1];
        [[DXEOrderManager sharedInstance].cart addObject:item];
    }
    else
    {
        item.count = [NSNumber numberWithInteger:[item.count integerValue] + 1];
    }
    
    DXEDishCollectionViewCell *cell = (DXEDishCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.cartButton.userInteractionEnabled = NO;
    UIImageView *dishImage = [[UIImageView alloc] initWithImage:cell.dishImage.image];
    dishImage.frame = cell.dishImage.frame;
    [cell.contentView insertSubview:dishImage belowSubview:cell.inCartFlag];
    [self putDishImage:dishImage
          intoCartIcon:cell.cartIcon
            completion:^{
                [cell showCellMode:DXEDishCellModeInCart animate:YES];
                cell.cartButton.userInteractionEnabled = YES;
    }];
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

- (void)onTapOnDishImageInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    DXEDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
    if ([item.soldout boolValue] == NO)
    {
        self.selectedIndexPath = indexPath;
        
        self.dishDetailView = [[[NSBundle mainBundle] loadNibNamed:@"DXEDishDetailView" owner:self options:nil] firstObject];
        self.dishDetailView.dishName.text = item.name;
        self.dishDetailView.dishEnglishName.text = item.englishName;
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
           tapOutsideToDismiss:NO
                      animated:YES
                    completion:^{
                        self.selectedIndexPath = nil;
                        self.dishDetailView = nil;
                    }];
    }
}

#pragma mark - Target-Action in Dish Detail View

- (IBAction)onCartButtonClickedInDishDetailView:(id)sender
{
    DXEDishItem *item = [self.dishClass.dishes objectAtIndex:self.selectedIndexPath.row - 1];
    
    if (!item.inCart)
    {
        item.count = [NSNumber numberWithInteger:1];
        [[DXEOrderManager sharedInstance].cart addObject:item];
    }
    else
    {
        item.count = [NSNumber numberWithInteger:[item.count integerValue] + 1];
    }
    
    self.dishDetailView.cartButton.userInteractionEnabled = NO;
    UIImageView *dishImage = [[UIImageView alloc] initWithImage:self.dishDetailView.dishImage.image];
    dishImage.frame = self.dishDetailView.dishImage.frame;
    [self.dishDetailView insertSubview:dishImage belowSubview:self.dishDetailView.inCartFlag];
    [self putDishImage:dishImage
          intoCartIcon:self.dishDetailView.cartIcon
            completion:^{
                [UIView animateWithDuration:0.3 animations:^{
                    self.dishDetailView.inCartFlag.alpha = 1.0;
                }];
                self.dishDetailView.cartButton.userInteractionEnabled = YES;
                [self.collectionView reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
    }];
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

- (IBAction)onTapOnDishImageInDishDetailView:(id)sender
{
    [CRModal dismiss];
}

#pragma mark - Animation

#define kDXEDishImageInCartOriginX          13
#define kDXEDishImageInCartOriginY          6
#define kDXEDishImageInCartHeight           8
#define kDXECartIconOriginWidth             28
#define kDXECartIconOriginHeight            23


- (void)putDishImage:(UIImageView *)dishImage
        intoCartIcon:(UIImageView *)cartIcon
          completion:(void (^)())completion
{
    CGFloat x = cartIcon.frame.size.width / kDXECartIconOriginWidth * kDXEDishImageInCartOriginX;
    CGFloat y = cartIcon.frame.size.height / kDXECartIconOriginHeight * kDXEDishImageInCartOriginY;
    CGFloat height = cartIcon.frame.size.height / kDXECartIconOriginHeight * kDXEDishImageInCartHeight;
    CGRect inCartFrame = CGRectMake(cartIcon.frame.origin.x + floor(x),
                                    cartIcon.frame.origin.y + floor(y),
                                    floor(height),
                                    floor(height));
    
    [UIView animateWithDuration:0.3 animations:^{
        // Step 1. 放大Cart图标
        cartIcon.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished){
        // Step 2. 吸入DishImage
        [dishImage genieInTransitionWithDuration:0.5
                                 destinationRect:inCartFrame
                                 destinationEdge:BCRectEdgeTop
        completion:^{
            // Step 3. DishImage消失
            [dishImage removeFromSuperview];
            [UIView animateWithDuration:0.3 animations:^{
                // Step 4. Cart图标恢复原状
                cartIcon.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                if (completion)
                {
                    completion();
                }
            }];
        }];
    }];
}

@end
