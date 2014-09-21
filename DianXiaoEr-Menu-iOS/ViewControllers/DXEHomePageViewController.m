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
    self.view.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"HomePage.BackgroundColor"];
    
    UIColor *normalColor =[[RNThemeManager sharedManager] colorForKey:@"ScrollMenu.NormalTextColor"];
    UIColor *selectedColor =[[RNThemeManager sharedManager] colorForKey:@"ScrollMenu.SelectedTextColor"];
    self.scrollMenuController = [[CRScrollMenuController alloc] init];
    self.scrollMenuController.scrollMenuHeight = kDXEHomePageScrollMenuHeight;
    self.scrollMenuController.scrollMenuBackgroundImage = [[RNThemeManager sharedManager] imageForName:@"scrollmenu_background"];
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
    
    self.scrollMenuController.view.frame = self.view.bounds;
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
        for (DXEDishItem *item in removalItems)
        {
            for (DXEDishesViewController *controller in self.contentViewControllers)
            {
                if ([item.classid isEqualToNumber:[controller.dishClass classid]])
                {
                    [controller updateDishCellByDishItem:item];
                    break;
                }
            }
        }
    }
}

@end
