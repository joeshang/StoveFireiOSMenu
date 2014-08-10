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

@synthesize contentScrollView = _contentScrollView;
@synthesize collectionViews = _collectionViews;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _collectionViews = [[NSMutableArray alloc] initWithCapacity:kDXEScrollMenuItemCount];
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
    _collectionViews = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 初始化包含collection view的scroll view
    CGRect contentRect = CGRectMake(0,
                                    kDXENavigationBarHeight + kDXEScrollMenuHeight,
                                    CGRectGetWidth(self.view.bounds),
                                    CGRectGetHeight(self.view.bounds) - kDXENavigationBarHeight - kDXEScrollMenuHeight - kDXETabBarHeight);
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:contentRect];
    self.contentScrollView.delegate = self;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.directionalLockEnabled = YES;
    
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
    
    CGRect collectionViewRect;
#warning 当接入Model时使用从后台取得的数据
    for (int i = 0; i < kDXEScrollMenuItemCount; i++)
    {
        collectionViewRect= CGRectMake(i * CGRectGetWidth(self.view.bounds),
                                       0,
                                       CGRectGetWidth(self.contentScrollView.bounds),
                                       CGRectGetHeight(self.contentScrollView.bounds));
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
        
        [self.contentScrollView addSubview:collectionView];
        [self.collectionViews addObject:collectionView];
    }
    
#warning 当接入Model时使用从后台取得的数据
    self.contentScrollView.contentSize = CGSizeMake(kDXEScrollMenuItemCount * CGRectGetWidth(self.contentScrollView.bounds),
                                                 CGRectGetHeight(self.contentScrollView.bounds));
    
//    [self.view addSubview:self.contentScrollView];
}

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
