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
#import "DXEOrderItem.h"
#import "DXEDataManager.h"
#import "DXEOrderManager.h"

#define kDXEHomePageScrollMenuHeight                    53
#define kDXEHomePageScrollMenuButtonPadding             18
#define kDXEHomePageScrollMenuIndicatorHeight           2
#define kDXEHomePageScrollMenuTitleFontSize             20
#define kDXEHomePageScrollMenuSubtitleFontSize          9

#define kDXECollectionViewSectionTop                    17
#define kDXECollectionViewSectionBottom                 17
#define kDXECollectionViewSectionLeft                   17
#define kDXECollectionViewSectionRight                  17
#define kDXECollectionViewHeaderHeight                  0
#define kDXECollectionViewFooterHeight                  0
#define kDXECollectionViewColumnSpacing                 17
#define kDXECollectionViewInteritemSpacing              17

@interface DXEHomePageViewController ()

@property (nonatomic, strong) CRScrollMenuController *scrollMenuController;
@property (nonatomic, strong) NSMutableArray *contentViewControllers;
@property (nonatomic, strong) NSMutableArray *scrollMenuItems;
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
        NSPredicate *showPredicate = [NSPredicate predicateWithFormat:@"vip == FALSE"];
        _showDishes = [NSMutableArray arrayWithArray:[[DXEDataManager sharedInstance].dishClasses
                                                      filteredArrayUsingPredicate:showPredicate]];
        NSPredicate *hidePredicate = [NSPredicate predicateWithFormat:@"vip == TRUE"];
        _hideDishes = [NSMutableArray arrayWithArray:[[DXEDataManager sharedInstance].dishClasses
                                                      filteredArrayUsingPredicate:hidePredicate]];
        
        [[DXEOrderManager sharedInstance] addObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(cartList))
                                              options:NSKeyValueObservingOptionOld
                                              context:nil];
    }
    return self;
}

- (void)dealloc
{
    [[DXEOrderManager sharedInstance] removeObserver:self
                                          forKeyPath:NSStringFromSelector(@selector(cartList))];
}

#pragma mark - view related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    
    UIColor *normalColor =[[RNThemeManager sharedManager] colorForKey:@"DarkenColor"];
    UIColor *selectedColor =[[RNThemeManager sharedManager] colorForKey:@"HighlightColor"];
    self.scrollMenuController = [[CRScrollMenuController alloc] init];
    self.scrollMenuController.scrollMenuHeight = kDXEHomePageScrollMenuHeight;
    self.scrollMenuController.scrollMenuBackgroundImage = [[RNThemeManager sharedManager] imageForKey:@"scrollmenu_background"];
    self.scrollMenuController.scrollMenuIndicatorColor = selectedColor;
    self.scrollMenuController.scrollMenuIndicatorHeight = kDXEHomePageScrollMenuIndicatorHeight;
    self.scrollMenuController.scrollMenuButtonPadding = kDXEHomePageScrollMenuButtonPadding;
    self.scrollMenuController.normalTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kDXEHomePageScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: normalColor
      };
    self.scrollMenuController.selectedTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kDXEHomePageScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: selectedColor
      };
    self.scrollMenuController.normalSubtitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kDXEHomePageScrollMenuSubtitleFontSize],
      NSForegroundColorAttributeName: normalColor
      };
    self.scrollMenuController.selectedSubtitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kDXEHomePageScrollMenuSubtitleFontSize],
      NSForegroundColorAttributeName: selectedColor
      };
    [self addChildViewController:self.scrollMenuController];
    [self.view addSubview:self.scrollMenuController.view];
    [self.scrollMenuController didMoveToParentViewController:self];
    
    self.contentViewControllers = [NSMutableArray arrayWithCapacity:[self.showDishes count]];
    self.scrollMenuItems = [NSMutableArray arrayWithCapacity:[self.showDishes count]];
    [self.showDishes enumerateObjectsUsingBlock:^(DXEDishClass *class, NSUInteger index, BOOL *stop){
        [self generateContentControllerByData:class atIndex:index];
    }];
    [self.scrollMenuController setViewControllers:self.contentViewControllers
                                        withItems:self.scrollMenuItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollMenuController.view.frame = self.view.bounds;
}

- (void)generateContentControllerByData:(DXEDishClass *)class
                                atIndex:(NSInteger)index
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
    [self.contentViewControllers insertObject:dishViewController atIndex:index];
    
    CRScrollMenuItem *item = [[CRScrollMenuItem alloc] init];
    item.title = class.name;
    item.subtitle = class.englishName;
    [self.scrollMenuItems insertObject:item atIndex:index];
}

- (void)showAllDishClasses
{
    for (DXEDishClass *hideClass in self.hideDishes)
    {
        __block NSUInteger insertIndex = 0;
        [self.showDishes enumerateObjectsUsingBlock:^(DXEDishClass *showClass, NSUInteger index, BOOL *stop){
            if ([hideClass.showSequence integerValue] < [showClass.showSequence integerValue])
            {
                [self.showDishes insertObject:hideClass atIndex:index];
                insertIndex = index;
                *stop = YES;
            }
        }];
        [self generateContentControllerByData:hideClass atIndex:insertIndex];
    }
    [self.scrollMenuController setViewControllers:self.contentViewControllers
                                        withItems:self.scrollMenuItems];
    [self.hideDishes removeAllObjects];
}

#pragma mark - notification

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(cartList))]
        && [change[NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeRemoval)
    {
        NSArray *removalItems = change[NSKeyValueChangeOldKey];
        for (DXEOrderItem *item in removalItems)
        {
            DXEDishItem *dish = [[DXEDataManager sharedInstance].dishes objectForKey:item.itemid];
            for (DXEDishesViewController *controller in self.contentViewControllers)
            {
                if ([dish.classid integerValue] == [controller.dishClass.classid integerValue])
                {
                    [controller updateDishCellByDishItem:dish];
                    break;
                }
            }
        }
    }
}

@end
