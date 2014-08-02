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

#define kScrollMenuHeight                   55
#define kNavigationBarHeight                64

#define kCollectionViewSectionTop           17
#define kCollectionViewSectionBottom        17
#define kCollectionViewSectionLeft          17
#define kCollectionViewSectionRight         17
#define kCollectionViewHeaderHeight         0
#define kCollectionViewFooterHeight         0
#define kCollectionViewColumnSpacing        17
#define kCollectionViewInteritemSpacing     17

#define kCollectionViewCellWidth            360
#define kCollectionViewInfoCellHeight       140
#define kCollectionViewDishCellHeight       600

#warning 当接入Model时使用从后台取得的数据
#define kCollectionViewCellCount            15
#define kScrollMenuItemCount                10

@interface DXEHomePageViewController ()

@end

@implementation DXEHomePageViewController

@synthesize dishScrollView = _dishScrollView;
@synthesize collectionViews = _collectionViews;

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
    for (UICollectionView *collectionView in _collectionViews)
    {
        collectionView.delegate = nil;
        collectionView.dataSource = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化包含collection view的scroll view
    self.dishScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                         kNavigationBarHeight + kScrollMenuHeight,
                                                                         CGRectGetWidth(self.view.bounds),
                                                                         CGRectGetHeight(self.view.bounds) - kNavigationBarHeight - kScrollMenuHeight)];
    self.dishScrollView.delegate = self;
    self.dishScrollView.showsVerticalScrollIndicator = NO;
    self.dishScrollView.showsHorizontalScrollIndicator = NO;
    self.dishScrollView.pagingEnabled = YES;
    
    // 为每一类菜品创建对应的collection view
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(kCollectionViewSectionTop,
                                           kCollectionViewSectionLeft,
                                           kCollectionViewSectionBottom,
                                           kCollectionViewSectionRight);
    layout.headerHeight = kCollectionViewHeaderHeight;
    layout.footerHeight = kCollectionViewFooterHeight;
    layout.minimumColumnSpacing = kCollectionViewColumnSpacing;
    layout.minimumInteritemSpacing = kCollectionViewInteritemSpacing;
    
    CGRect collectionViewRect;
#warning 当接入Model时使用从后台取得的数据
    for (int i = 0; i < kScrollMenuItemCount; i++)
    {
        collectionViewRect= CGRectMake(i * CGRectGetWidth(self.view.bounds),
                                       0,
                                       CGRectGetWidth(self.dishScrollView.bounds),
                                       CGRectGetHeight(self.dishScrollView.bounds));
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect
                                                              collectionViewLayout:layout];
        collectionView.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionView.BackgroundColor"];
        
        collectionView.tag = i;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        [collectionView registerNib:[UINib nibWithNibName:@"DXETipsCollectionViewCell" bundle:nil]
         forCellWithReuseIdentifier:@"DXETipsCollectionViewCell"];
        [collectionView registerNib:[UINib nibWithNibName:@"DXEDishCollectionViewCell" bundle:nil]
         forCellWithReuseIdentifier:@"DXEDishCollectionViewCell"];
        
        [self.dishScrollView addSubview:collectionView];
        [self.collectionViews addObject:collectionView];
    }
    
    self.dishScrollView.contentSize = CGSizeMake(kScrollMenuItemCount * CGRectGetWidth(self.dishScrollView.bounds),
                                                 CGRectGetHeight(self.dishScrollView.bounds));
    
    [self.view addSubview:self.dishScrollView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.dishScrollView)
    {
        
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
#warning 当接入Model时使用从后台取得的数据
    return kCollectionViewCellCount;
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

#pragma mark - CHTCollectionViewDelegateWaterflowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    if (indexPath.row == 0)
    {
        size = CGSizeMake(kCollectionViewCellWidth, kCollectionViewInfoCellHeight);
    }
    else
    {
        size = CGSizeMake(kCollectionViewCellWidth, kCollectionViewDishCellHeight);
    }
    
    return size;
}

@end
