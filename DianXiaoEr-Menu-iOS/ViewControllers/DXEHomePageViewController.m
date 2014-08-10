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

#warning 当接入Model时使用从后台取得的数据
#define kDXECollectionViewCellCount             15
#define kDXEScrollMenuItemCount                 10

@interface DXEHomePageViewController ()

@end

@implementation DXEHomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect contentRect = CGRectMake(0,
                                    kDXENavigationBarHeight + kDXEScrollMenuHeight,
                                    CGRectGetWidth(self.view.bounds),
                                    CGRectGetHeight(self.view.bounds) - kDXENavigationBarHeight - kDXEScrollMenuHeight - kDXETabBarHeight);
    self.contentContainer = [[iCarousel alloc] initWithFrame:contentRect];
    self.contentContainer.type = iCarouselTypeLinear;
    self.contentContainer.pagingEnabled = YES;
    self.contentContainer.bounceDistance = 0.4;
    self.contentContainer.delegate = self;
    self.contentContainer.dataSource = self;
    self.contentContainer.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionView.BackgroundColor"];
    [self.view addSubview:self.contentContainer];
}

#pragma mark - iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
#warning 当接入Model时使用从后台取得的数据
    return kDXEScrollMenuItemCount;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
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
                                          CGRectGetWidth(carousel.bounds),
                                          CGRectGetHeight(carousel.bounds));
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect
                                                          collectionViewLayout:layout];
    collectionView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionView.BackgroundColor"];
    
    collectionView.tag = index;
    collectionView.delaysContentTouches = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    [collectionView registerNib:[UINib nibWithNibName:@"DXETipsCollectionViewCell" bundle:nil]
     forCellWithReuseIdentifier:@"DXETipsCollectionViewCell"];
    [collectionView registerNib:[UINib nibWithNibName:@"DXEDishCollectionViewCell" bundle:nil]
     forCellWithReuseIdentifier:@"DXEDishCollectionViewCell"];
    
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
#warning 当接入Model时使用从后台取得的数据
    return kDXECollectionViewCellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        DXETipsColletionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXETipsCollectionViewCell"
                                                                                   forIndexPath:indexPath];
        return cell;
    }
    else
    {
        DXEDishCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DXEDishCollectionViewCell"
                                                                                    forIndexPath:indexPath];
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
