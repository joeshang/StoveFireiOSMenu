//
//  DXEHomePageViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/14/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEHomePageViewController.h"
#import "DXETipsColletionViewCell.h"
#import "DXEDishCollectionViewCell.h"
#import "DXEDishDataManager.h"
#import "DXEImageManager.h"

#define kDXECollectionViewSectionTop            17
#define kDXECollectionViewSectionBottom         17
#define kDXECollectionViewSectionLeft           17
#define kDXECollectionViewSectionRight          17
#define kDXECollectionViewHeaderHeight          0
#define kDXECollectionViewFooterHeight          0
#define kDXECollectionViewColumnSpacing         17
#define kDXECollectionViewInteritemSpacing      17

#define kDXECollectionViewCellWidth             360
#define kDXECollectionViewInfoCellHeight        140
#define kDXECollectionViewDishCellHeight        600

@interface DXEHomePageViewController ()

@property (nonatomic, strong) iCarousel *contentContainer;
@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, strong) NSMutableArray *showDishes;
@property (nonatomic, strong) NSMutableArray *hideDishes;

@end

@implementation DXEHomePageViewController

#pragma mark - life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        NSPredicate *showPredicate = [NSPredicate predicateWithFormat:@"name != %@", @"会员"];
        _showDishes = [NSMutableArray arrayWithArray:[[DXEDishDataManager sharedInstance].dishClasses filteredArrayUsingPredicate:showPredicate]];
        NSPredicate *hidePredicate = [NSPredicate predicateWithFormat:@"name = %@", @"会员"];
        _hideDishes = [NSMutableArray arrayWithArray:[[DXEDishDataManager sharedInstance].dishClasses filteredArrayUsingPredicate:hidePredicate]];
    }
    return self;
}

- (void)dealloc
{
    _contentContainer.delegate = nil;
    _contentContainer.dataSource = nil;
    _contentContainer = nil;
}

#pragma mark - view related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect contentRect = CGRectMake(0,
                                    kDXEScrollMenuHeight,
                                    CGRectGetWidth(self.view.bounds),
                                    CGRectGetHeight(self.view.bounds) - kDXEStatusBarHeight - kDXENavigationBarHeight - kDXEScrollMenuHeight - kDXETabBarHeight);
    self.contentContainer = [[iCarousel alloc] initWithFrame:contentRect];
    self.contentContainer.type = iCarouselTypeLinear;
    self.contentContainer.pagingEnabled = YES;
    self.contentContainer.bounceDistance = 0.4;
    self.contentContainer.delegate = self;
    self.contentContainer.dataSource = self;
    self.contentContainer.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionView.BackgroundColor"];
    [self.view addSubview:self.contentContainer];
    
    self.contents = [NSMutableArray arrayWithCapacity:[self.showDishes count]];
    [self.showDishes enumerateObjectsUsingBlock:^(DXEDishClass *class, NSUInteger index, BOOL *stop){
        // 为每一类菜品创建对应的collection view
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(kDXECollectionViewSectionTop,
                                               kDXECollectionViewSectionLeft,
                                               kDXECollectionViewSectionBottom,
                                               kDXECollectionViewSectionRight);
        layout.headerHeight = kDXECollectionViewHeaderHeight;
        layout.footerHeight = kDXECollectionViewFooterHeight;
        layout.minimumColumnSpacing = kDXECollectionViewColumnSpacing;
        layout.minimumInteritemSpacing = kDXECollectionViewInteritemSpacing;
        
        CGRect collectionViewRect= CGRectMake(index * CGRectGetWidth(self.view.bounds),
                                              0,
                                              CGRectGetWidth(self.contentContainer.bounds),
                                              CGRectGetHeight(self.contentContainer.bounds));
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect
                                                              collectionViewLayout:layout];
        collectionView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionView.BackgroundColor"];
        
        collectionView.tag = [class.classid intValue];
        collectionView.delaysContentTouches = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        [collectionView registerNib:[UINib nibWithNibName:@"DXETipsCollectionViewCell" bundle:nil]
         forCellWithReuseIdentifier:@"DXETipsCollectionViewCell"];
        [collectionView registerNib:[UINib nibWithNibName:@"DXEDishCollectionViewCell" bundle:nil]
         forCellWithReuseIdentifier:@"DXEDishCollectionViewCell"];
        
        [self.contents addObject:collectionView];
    }];
}

#pragma mark - target-action

- (void)onCartButtonClickedInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [self.contents indexOfObject:collectionView];
    DXEDishClass *class = [self.showDishes objectAtIndex:index];
    DXEDishItem *item = [class.dishes objectAtIndex:indexPath.row - 1];
    if (item.inCart == NO)
    {
        item.inCart = YES;
    }
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.showDishes count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    NSLog(@"carousel index: %ld", index);
    
    UICollectionView *collectionView = [self.contents objectAtIndex:index];
    
    return collectionView;
}

#pragma mark - iCarouselDelegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger index = [self.contents indexOfObject:collectionView];
    DXEDishClass *class = [self.showDishes objectAtIndex:index];
    
    return [class.dishes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [self.contents indexOfObject:collectionView];
    DXEDishClass *class = [self.showDishes objectAtIndex:index];
    
    if (indexPath.row == 0)
    {
        DXETipsColletionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXETipsCollectionViewCell"
                                                                                   forIndexPath:indexPath];
        cell.tipsImage.image = [[DXEImageManager sharedInstance] imageForKey:class.imageKey];
        
        return cell;
    }
    else
    {
        DXEDishItem *item = [class.dishes objectAtIndex:indexPath.row - 1];
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
        cell.dishPriceIcon.image = [UIImage imageNamed:@"cell_price_icon"];
        cell.dishFavor.text = [item.favor stringValue];
        cell.dishFavorIcon.image = [UIImage imageNamed:@"cell_favor_icon"];
        
        cell.controller = self;
        cell.collectionView = collectionView;
        
        return cell;
    }
}

#pragma mark- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"page: %ld, index: %ld", collectionView.tag, indexPath.row);
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

@end
