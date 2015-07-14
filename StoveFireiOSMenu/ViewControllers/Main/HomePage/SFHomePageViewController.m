//
//  SFHomePageViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 7/14/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFHomePageViewController.h"
#import "SFDishesViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "SCRScrollMenuController.h"
#import "SFOrderItem.h"
#import "SFDataManager.h"
#import "SFOrderManager.h"

#define kSFHomePageScrollMenuHeight                    53
#define kSFHomePageScrollMenuButtonPadding             18
#define kSFHomePageScrollMenuIndicatorHeight           2
#define kSFHomePageScrollMenuTitleFontSize             20
#define kSFHomePageScrollMenuSubtitleFontSize          9

#define kSFCollectionViewSectionTop                    17
#define kSFCollectionViewSectionBottom                 17
#define kSFCollectionViewSectionLeft                   17
#define kSFCollectionViewSectionRight                  17
#define kSFCollectionViewHeaderHeight                  0
#define kSFCollectionViewFooterHeight                  0
#define kSFCollectionViewColumnSpacing                 17
#define kSFCollectionViewInteritemSpacing              17

@interface SFHomePageViewController ()

@property (nonatomic, strong) SCRScrollMenuController *scrollMenuController;
@property (nonatomic, strong) NSMutableArray *contentViewControllers;
@property (nonatomic, strong) NSMutableArray *scrollMenuItems;
@property (nonatomic, strong) NSMutableArray *showDishes;
@property (nonatomic, strong) NSMutableArray *hideDishes;

@end

@implementation SFHomePageViewController

#pragma mark - life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        NSPredicate *showPredicate = [NSPredicate predicateWithFormat:@"vip == FALSE"];
        _showDishes = [NSMutableArray arrayWithArray:[[SFDataManager sharedInstance].dishClasses
                                                      filteredArrayUsingPredicate:showPredicate]];
        NSPredicate *hidePredicate = [NSPredicate predicateWithFormat:@"vip == TRUE"];
        _hideDishes = [NSMutableArray arrayWithArray:[[SFDataManager sharedInstance].dishClasses
                                                      filteredArrayUsingPredicate:hidePredicate]];
        
        [[SFOrderManager sharedInstance] addObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(cartList))
                                              options:NSKeyValueObservingOptionOld
                                              context:nil];
    }
    return self;
}

- (void)dealloc
{
    [[SFOrderManager sharedInstance] removeObserver:self
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
    self.scrollMenuController = [[SCRScrollMenuController alloc] init];
    self.scrollMenuController.scrollMenuHeight = kSFHomePageScrollMenuHeight;
    self.scrollMenuController.scrollMenuBackgroundImage = [[RNThemeManager sharedManager] imageForKey:@"scrollmenu_background"];
    self.scrollMenuController.scrollMenuIndicatorColor = selectedColor;
    self.scrollMenuController.scrollMenuIndicatorHeight = kSFHomePageScrollMenuIndicatorHeight;
    self.scrollMenuController.scrollMenuButtonPadding = kSFHomePageScrollMenuButtonPadding;
    self.scrollMenuController.normalTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kSFHomePageScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: normalColor
      };
    self.scrollMenuController.selectedTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kSFHomePageScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: selectedColor
      };
    self.scrollMenuController.normalSubtitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kSFHomePageScrollMenuSubtitleFontSize],
      NSForegroundColorAttributeName: normalColor
      };
    self.scrollMenuController.selectedSubtitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kSFHomePageScrollMenuSubtitleFontSize],
      NSForegroundColorAttributeName: selectedColor
      };
    [self addChildViewController:self.scrollMenuController];
    [self.view addSubview:self.scrollMenuController.view];
    [self.scrollMenuController didMoveToParentViewController:self];
    
    self.contentViewControllers = [NSMutableArray arrayWithCapacity:[self.showDishes count]];
    self.scrollMenuItems = [NSMutableArray arrayWithCapacity:[self.showDishes count]];
    [self.showDishes enumerateObjectsUsingBlock:^(SFDishClass *class, NSUInteger index, BOOL *stop){
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

- (void)generateContentControllerByData:(SFDishClass *)class
                                atIndex:(NSInteger)index
{
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(kSFCollectionViewSectionTop,
                                           kSFCollectionViewSectionLeft,
                                           kSFCollectionViewSectionBottom,
                                           kSFCollectionViewSectionRight);
    layout.headerHeight = kSFCollectionViewHeaderHeight;
    layout.footerHeight = kSFCollectionViewFooterHeight;
    layout.minimumColumnSpacing = kSFCollectionViewColumnSpacing;
    layout.minimumInteritemSpacing = kSFCollectionViewInteritemSpacing;
    
    SFDishesViewController *dishViewController = [[SFDishesViewController alloc] initWithCollectionViewLayout:layout];
    dishViewController.dishClass = class;
    [self.contentViewControllers insertObject:dishViewController atIndex:index];
    
    SCRScrollMenuItem *item = [[SCRScrollMenuItem alloc] init];
    item.title = class.name;
    item.subtitle = class.englishName;
    [self.scrollMenuItems insertObject:item atIndex:index];
}

- (void)showAllDishClasses
{
    for (SFDishClass *hideClass in self.hideDishes)
    {
        __block NSUInteger insertIndex = 0;
        [self.showDishes enumerateObjectsUsingBlock:^(SFDishClass *showClass, NSUInteger index, BOOL *stop){
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
        for (SFOrderItem *item in removalItems)
        {
            SFDishItem *dish = [[SFDataManager sharedInstance].dishes objectForKey:item.itemid];
            for (SFDishesViewController *controller in self.contentViewControllers)
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
