//
//  SFDishesViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFDishesViewController.h"
#import "SFTipsColletionViewCell.h"
#import "SFDishCollectionViewCell.h"
#import "CRModal.h"
#import "SFDishDetailView.h"
#import "SFDishClass.h"
#import "SFOrderItem.h"
#import "SFImageManager.h"
#import "SFProjectorManager.h"
#import "SFOrderManager.h"
#import "UIView+Genie.h"
#import "AFNetworking.h"

#define kSFCollectionViewCellWidth             357
#define kSFCollectionViewInfoCellHeight        140
#define kSFCollectionViewDishCellHeight        597

@interface SFDishesViewController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) SFDishDetailView *dishDetailView;

@end

@implementation SFDishesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SFTipsCollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:@"SFTipsCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SFDishCollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:@"SFDishCollectionViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateDishCellByDishItem:(SFDishItem *)item
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
        SFTipsColletionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SFTipsCollectionViewCell"
                                                                                   forIndexPath:indexPath];
        UIImage *dishClassImage = [[SFImageManager sharedInstance] imageForKey:self.dishClass.imageKey];
        if (!dishClassImage)
        {
            dishClassImage = [UIImage imageNamed:@"default_dish_class"];
        }
        cell.tipsImage.image = dishClassImage;
        
        return cell;
    }
    else
    {
        SFDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
        SFDishCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SFDishCollectionViewCell"
                                                                                    forIndexPath:indexPath];
        
        if ([item.soldout boolValue] == YES)
        {
            cell.cellMode = SFDishCellModeSoldout;
        }
        else
        {
            if (item.inCart == YES)
            {
                cell.cellMode = SFDishCellModeInCart;
            }
            else
            {
                cell.cellMode = SFDishCellModeNormal;
            }
        }
        
        cell.dishName.text = item.name;
        cell.dishEnglishName.text = item.englishName;
        UIImage *dishItemImage = [[SFImageManager sharedInstance] imageForKey:item.imageKey];
        if (!dishItemImage)
        {
            dishItemImage = [UIImage imageNamed:@"default_dish_item"];
        }
        cell.dishImage.image = dishItemImage;
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
        size = CGSizeMake(kSFCollectionViewCellWidth, kSFCollectionViewInfoCellHeight);
    }
    else
    {
        size = CGSizeMake(kSFCollectionViewCellWidth, kSFCollectionViewDishCellHeight);
    }
    
    return size;
}

#pragma mark - Functional

- (void)addToCart:(SFDishItem *)dish
{
    if (dish.inCart)
    {
        for (SFOrderItem *item in [SFOrderManager sharedInstance].cart)
        {
            if ([item.itemid integerValue] == [dish.itemid integerValue])
            {
                item.count = [NSNumber numberWithInteger:[item.count integerValue] + 1];
                break;
            }
        }
    }
    else
    {
        SFOrderItem *item = [[SFOrderItem alloc] initWithItemid:dish.itemid];
        [[SFOrderManager sharedInstance].cart addObject:item];
    }
}

#pragma mark - Target-Action in Collection View

- (void)onCartButtonClickedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    SFDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
    [self addToCart:item];
    
    SFDishCollectionViewCell *cell = (SFDishCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.cartButton.userInteractionEnabled = NO;
    UIImageView *dishImage = [[UIImageView alloc] initWithImage:cell.dishImage.image];
    dishImage.frame = cell.dishImage.frame;
    [cell.contentView insertSubview:dishImage belowSubview:cell.inCartFlag];
    [self putDishImage:dishImage
          intoCartIcon:cell.cartIcon
            completion:^{
                [cell showCellMode:SFDishCellModeInCart animate:YES];
                cell.cartButton.userInteractionEnabled = YES;
    }];
}

- (void)onFavorButtonClickedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    SFDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
    if (item.inFavor)
    {
        [self cancelFavor:item];
    }
    else
    {
        [self doFavor:item];
    }
    
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)onTapOnDishImageInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    SFDishItem *item = [self.dishClass.dishes objectAtIndex:indexPath.row - 1];
    if ([item.soldout boolValue] == NO)
    {
        self.selectedIndexPath = indexPath;
        
        self.dishDetailView = [[[NSBundle mainBundle] loadNibNamed:@"SFDishDetailView" owner:self options:nil] firstObject];
        self.dishDetailView.dishName.text = item.name;
        self.dishDetailView.dishEnglishName.text = item.englishName;
        self.dishDetailView.dishPrice.text = [NSString stringWithFormat:@"%.2f", [item.price floatValue]];
        self.dishDetailView.dishFavor.text = [item.favor stringValue];
        self.dishDetailView.dishIngredient.selectable = YES;
        self.dishDetailView.dishIngredient.text = [item.ingredient stringByReplacingOccurrencesOfString: @"\\n" withString: @"\n"];
        self.dishDetailView.dishIngredient.selectable = NO;
        UIImage *dishItemImage = [[SFImageManager sharedInstance] imageForKey:item.imageKey];
        if (!dishItemImage)
        {
            dishItemImage = [UIImage imageNamed:@"default_dish_item"];
        }
        self.dishDetailView.dishImage.image = dishItemImage;
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
        
        [[SFProjectorManager sharedInstance] doAction:SFProjectorActionPlay withName:item.name];
        [CRModal showModalView:self.dishDetailView
                   coverOption:CRModalOptionCoverDark
           tapOutsideToDismiss:NO
                      animated:YES
                    completion:^{
                        self.selectedIndexPath = nil;
                        self.dishDetailView = nil;
                        [[SFProjectorManager sharedInstance] doAction:SFProjectorActionStop withName:item.name];
                    }];
    }
}

#pragma mark - Target-Action in Dish Detail View

- (IBAction)onCartButtonClickedInDishDetailView:(id)sender
{
    SFDishItem *item = [self.dishClass.dishes objectAtIndex:self.selectedIndexPath.row - 1];
    [self addToCart:item];
    
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
    SFDishItem *item = [self.dishClass.dishes objectAtIndex:self.selectedIndexPath.row - 1];
    if (item.inFavor)
    {
        [self cancelFavor:item];
        
        [self.dishDetailView.favorButton setImage:[UIImage imageNamed:@"dish_cell_favor_hollow_icon"]
                                         forState:UIControlStateNormal];
    }
    else
    {
        [self doFavor:item];
        
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

#define kSFDishImageInCartOriginX          13
#define kSFDishImageInCartOriginY          6
#define kSFDishImageInCartHeight           8
#define kSFCartIconOriginWidth             29
#define kSFCartIconOriginHeight            23


- (void)putDishImage:(UIImageView *)dishImage
        intoCartIcon:(UIImageView *)cartIcon
          completion:(void (^)())completion
{
    CGFloat x = cartIcon.frame.size.width / kSFCartIconOriginWidth * kSFDishImageInCartOriginX;
    CGFloat y = cartIcon.frame.size.height / kSFCartIconOriginHeight * kSFDishImageInCartOriginY;
    CGFloat height = cartIcon.frame.size.height / kSFCartIconOriginHeight * kSFDishImageInCartHeight;
    CGRect inCartFrame = CGRectMake(cartIcon.frame.origin.x + floor(x),
                                    cartIcon.frame.origin.y + floor(y),
                                    floor(height),
                                    floor(height));
    
    [UIView animateWithDuration:0.3 animations:^{
        // Step 1. 放大Cart图标
        cartIcon.transform = CGAffineTransformMakeScale(1.3, 1.3);
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

#pragma mark - Favor

- (void)doFavor:(SFDishItem *)item
{
    item.inFavor = YES;
    item.favor = [NSNumber numberWithInt:[item.favor intValue] + 1];
    
    NSDictionary *parameters = @{
                                 @"id": item.itemid
                                 };
    NSURL *baseURL = [NSURL URLWithString:kSFWebServiceBaseURL];
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [httpManager POST:@"Like" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        NSLog(@"%@", error);
    }];
}

- (void)cancelFavor:(SFDishItem *)item
{
    item.inFavor = NO;
    item.favor = [NSNumber numberWithInt:[item.favor intValue] - 1];
    
    NSDictionary *parameters = @{
                                 @"id": item.itemid
                                 };
    NSURL *baseURL = [NSURL URLWithString:kSFWebServiceBaseURL];
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [httpManager POST:@"Dislike" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        NSLog(@"%@", error);
    }];
}

@end
