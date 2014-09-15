//
//  DXEHomePageViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/14/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEHomePageViewController.h"
#import "DXEDishesViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "CRScrollMenuController.h"
#import "DXEDishDataManager.h"

#define kDXEScrollMenuButtonPadding             21
#define kDXEScrollMenuIndicatorHeight           2

#define kDXECollectionViewSectionTop            17
#define kDXECollectionViewSectionBottom         17
#define kDXECollectionViewSectionLeft           17
#define kDXECollectionViewSectionRight          17
#define kDXECollectionViewHeaderHeight          0
#define kDXECollectionViewFooterHeight          0
#define kDXECollectionViewColumnSpacing         17
#define kDXECollectionViewInteritemSpacing      17

@interface DXEHomePageViewController ()

@property (nonatomic, strong) CRScrollMenuController *scrollMenuController;
@property (nonatomic, strong) NSMutableArray *contentViewControllers;
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

#pragma mark - view related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor redColor];
    
    self.scrollMenuController = [[CRScrollMenuController alloc] init];
    self.scrollMenuController.scrollMenuHeight = kDXEScrollMenuHeight;
    self.scrollMenuController.scrollMenuBackgroundImage = [[RNThemeManager sharedManager] imageForName:@"scrollmenu_background"];
    self.scrollMenuController.scrollMenuIndicatorColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemSelectedTextColor"];
    self.scrollMenuController.scrollMenuIndicatorHeight = kDXEScrollMenuIndicatorHeight;
    self.scrollMenuController.scrollMenuButtonPadding = kDXEScrollMenuButtonPadding;
    self.scrollMenuController.normalTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17],
                                                        NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemUnselectedTextColor"]};
    self.scrollMenuController.selectedTitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17],
                                                          NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemSelectedTextColor"]};
    self.scrollMenuController.normalSubtitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:8],
                                                           NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemUnselectedTextColor"]};
    self.scrollMenuController.selectedSubtitleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:8],
                                                             NSForegroundColorAttributeName: [[RNThemeManager sharedManager] colorForKey:@"HomePage.ScrollMenu.ItemSelectedTextColor"]};
    
    [self addChildViewController:self.scrollMenuController];
    self.scrollMenuController.view.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.CollectionView.BackgroundColor"];
    [self.view addSubview:self.scrollMenuController.view];
    [self.scrollMenuController didMoveToParentViewController:self];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[self.showDishes count]];
    self.contentViewControllers = [NSMutableArray arrayWithCapacity:[self.showDishes count]];
    for (DXEDishClass *class in self.showDishes)
    {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(kDXECollectionViewSectionTop,
                                               kDXECollectionViewSectionLeft,
                                               kDXECollectionViewSectionBottom,
                                               kDXECollectionViewSectionRight);
        layout.headerHeight = kDXECollectionViewHeaderHeight;
        layout.footerHeight = kDXECollectionViewFooterHeight;
        layout.minimumColumnSpacing = kDXECollectionViewColumnSpacing;
        layout.minimumInteritemSpacing = kDXECollectionViewInteritemSpacing;
    
        DXEDishesViewController *dishViewController = [[DXEDishesViewController alloc] initWithCollectionViewLayout:layout];
        dishViewController.dishClass = class;
        [self.contentViewControllers addObject:dishViewController];
        
        CRScrollMenuItem *item = [[CRScrollMenuItem alloc] init];
        item.title = class.name;
        item.subtitle = class.englishName;
        [items addObject:item];
    }
    [self.scrollMenuController setViewControllers:self.contentViewControllers withItems:items];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollMenuController.view.frame = CGRectMake(0,
                                                      0,
                                                      CGRectGetWidth(self.view.bounds),
                                                      CGRectGetHeight(self.view.bounds));
}

@end
