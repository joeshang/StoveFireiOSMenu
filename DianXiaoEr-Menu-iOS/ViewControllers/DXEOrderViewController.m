//
//  DXEOrderViewController.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEOrderViewController.h"
#import "DXEOrderManager.h"
#import "CRScrollMenu.h"
#import "DXEOrderCartViewController.h"
#import "DXEOrderProgressViewController.h"
#import "DXEOrderEmptyViewController.h"

typedef NS_ENUM(NSUInteger, DXEOrderViewState)
{
    DXEOrderViewStateEmptyCart,
    DXEOrderViewStateCartButNotOrdered,
    DXEOrderViewStateOrdered,
    DXEOrderViewStateOrderedWithCart
};

typedef NS_ENUM(NSUInteger, DXEOrderScrollMenuIndex)
{
    DXEOrderScrollMenuIndexCart,
    DXEOrderScrollMenuIndexProgress
};

typedef NS_ENUM(NSUInteger, DXEOrderOperation)
{
    DXEOrderOperationUnconcern,
    DXEOrderOperationAddToCart,
    DXEOrderOperationClearCart,
    DXEOrderOperationOrdering
};

#define kDXEOrderScrollMenuTitles                    @[@"已点菜品", @"制作进度"]
#define kDXEOrderScrollMenuHeight                    53
#define kDXEOrderScrollMenuButtonPadding             63
#define kDXEOrderScrollMenuIndicatorHeight           2
#define kDXEOrderScrollMenuTitleFontSize             20

@interface DXEOrderViewController ()
< CRScrollMenuDelegate >

@property (nonatomic, strong) CRScrollMenu *scrollMenu;
@property (nonatomic, strong) DXEOrderCartViewController *cartViewController;
@property (nonatomic, strong) DXEOrderProgressViewController *progressViewController;
@property (nonatomic, strong) DXEOrderEmptyViewController *emptyOrderedViewController;
@property (nonatomic, strong) DXEOrderEmptyViewController *emptyNotOrderedViewController;

@property (nonatomic, assign) DXEOrderViewState state;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) NSMutableArray *menuContentContainer;

@end

@implementation DXEOrderViewController

#pragma mark - init & dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[DXEOrderManager sharedInstance] addObserver:self
                                           forKeyPath:@"cartList"
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
        _state = DXEOrderViewStateEmptyCart;
    }
    return self;
}

- (void)dealloc
{
    [[DXEOrderManager sharedInstance] removeObserver:self
                                          forKeyPath:@"cartList"];
}

#pragma mark - view related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    
    UIColor *normalColor =[[RNThemeManager sharedManager] colorForKey:@"DarkenColor"];
    UIColor *selectedColor =[[RNThemeManager sharedManager] colorForKey:@"HighlightColor"];
    self.scrollMenu = [[CRScrollMenu alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     CGRectGetWidth(self.view.bounds),
                                                                     kDXEOrderScrollMenuHeight)];
    self.scrollMenu.delegate = self;
    self.scrollMenu.backgroundImage = [[RNThemeManager sharedManager] imageForName:@"scrollmenu_background"];
    self.scrollMenu.indicatorColor = selectedColor;
    self.scrollMenu.indicatorHeight = kDXEOrderScrollMenuIndicatorHeight;
    self.scrollMenu.buttonPadding = kDXEOrderScrollMenuButtonPadding;
    self.scrollMenu.normalTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kDXEOrderScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: normalColor
      };
    self.scrollMenu.selectedTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kDXEOrderScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: selectedColor
      };
    [self.view addSubview:self.scrollMenu];
    
    NSArray *titles = kDXEOrderScrollMenuTitles;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[titles count]];
    for (NSString *title in titles)
    {
        CRScrollMenuItem *item = [[CRScrollMenuItem alloc] init];
        item.title = title;
        [items addObject:item];
    }
    [self.scrollMenu setButtonsByItems:items];
    
    self.cartViewController = [[DXEOrderCartViewController alloc] init];
    [self addChildViewController:self.cartViewController];
    [self.cartViewController willMoveToParentViewController:self];
    
    self.progressViewController = [[DXEOrderProgressViewController alloc] init];
    [self addChildViewController:self.progressViewController];
    [self.progressViewController willMoveToParentViewController:self];
    
    self.emptyNotOrderedViewController = [[DXEOrderEmptyViewController alloc] init];
    self.emptyNotOrderedViewController.view.backgroundColor = [UIColor redColor];
    [self addChildViewController:self.emptyNotOrderedViewController];
    [self.emptyNotOrderedViewController willMoveToParentViewController:self];
    
    self.emptyOrderedViewController = [[DXEOrderEmptyViewController alloc] init];
    self.emptyOrderedViewController.view.backgroundColor = [UIColor blueColor];
    [self addChildViewController:self.emptyOrderedViewController];
    [self.emptyOrderedViewController willMoveToParentViewController:self];
    
    [self.view addSubview:self.emptyNotOrderedViewController.view];
    self.currentViewController = self.emptyNotOrderedViewController;
    self.menuContentContainer = [NSMutableArray arrayWithObjects:self.emptyNotOrderedViewController, self.emptyNotOrderedViewController, nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.currentViewController.view.frame = CGRectMake(0,
                                                       kDXEOrderScrollMenuHeight,
                                                       CGRectGetWidth(self.view.bounds),
                                                       CGRectGetHeight(self.view.bounds) - kDXEOrderScrollMenuHeight);
}

- (void)switchChildViewControllerFrom:(UIViewController *)from to:(UIViewController *)to
{
    if (from == to)
    {
        return;
    }
    
    [from.view removeFromSuperview];
    [self.view addSubview:to.view];
    to.view.frame = CGRectMake(0,
                               kDXEOrderScrollMenuHeight,
                               CGRectGetWidth(self.view.bounds),
                               CGRectGetHeight(self.view.bounds) - kDXEOrderScrollMenuHeight);
    self.currentViewController = to;
}

- (void)setState:(DXEOrderViewState)state
{
    switch (state) {
        case DXEOrderViewStateEmptyCart:
            [self.menuContentContainer replaceObjectAtIndex:DXEOrderScrollMenuIndexCart
                                                 withObject:self.emptyNotOrderedViewController];
            [self.menuContentContainer replaceObjectAtIndex:DXEOrderScrollMenuIndexProgress
                                                 withObject:self.emptyNotOrderedViewController];
            break;
        case DXEOrderViewStateCartButNotOrdered:
            [self.menuContentContainer replaceObjectAtIndex:DXEOrderScrollMenuIndexCart
                                                 withObject:self.cartViewController];
            [self.menuContentContainer replaceObjectAtIndex:DXEOrderScrollMenuIndexProgress
                                                 withObject:self.emptyNotOrderedViewController];
            break;
        case DXEOrderViewStateOrdered:
            [self.menuContentContainer replaceObjectAtIndex:DXEOrderScrollMenuIndexCart
                                                 withObject:self.emptyOrderedViewController];
            [self.menuContentContainer replaceObjectAtIndex:DXEOrderScrollMenuIndexProgress
                                                 withObject:self.progressViewController];
            break;
        case DXEOrderViewStateOrderedWithCart:
            [self.menuContentContainer replaceObjectAtIndex:DXEOrderScrollMenuIndexCart
                                                 withObject:self.cartViewController];
            [self.menuContentContainer replaceObjectAtIndex:DXEOrderScrollMenuIndexProgress
                                                 withObject:self.progressViewController];
        default:
            break;
    }
    
    _state = state;
}

#pragma mark - notification

- (void)scrollMenu:(CRScrollMenu *)scrollMenu didSelectedAtIndex:(NSUInteger)index
{
    [self switchChildViewControllerFrom:self.currentViewController
                                     to:[self.menuContentContainer objectAtIndex:index]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSInteger kind = [change[NSKeyValueChangeKindKey] integerValue];
    DXEOrderOperation operation = DXEOrderOperationUnconcern;
    
    if ([keyPath isEqualToString:@"cartList"])
    {
        if (kind == NSKeyValueChangeInsertion)
        {
            operation = DXEOrderOperationAddToCart;
        }
        else if (kind == NSKeyValueChangeRemoval)
        {
            if ([[DXEOrderManager sharedInstance].cart count] == 0)
            {
                if ([[DXEOrderManager sharedInstance].order count] == 0)
                {
                    operation = DXEOrderOperationClearCart;
                }
                else
                {
                    operation = DXEOrderOperationOrdering;
                }
            }
        }
    }
    
    switch (self.state)
    {
        case DXEOrderViewStateEmptyCart:
        {
            if (operation == DXEOrderOperationAddToCart)
            {
                if (self.scrollMenu.currentIndex == DXEOrderScrollMenuIndexCart)
                {
                    [self switchChildViewControllerFrom:self.currentViewController
                                                     to:self.cartViewController];
                }
                self.state = DXEOrderViewStateCartButNotOrdered;
            }
            break;
        }
        case DXEOrderViewStateCartButNotOrdered:
        {
            if (operation == DXEOrderOperationClearCart)
            {
                [self switchChildViewControllerFrom:self.currentViewController
                                                 to:self.emptyNotOrderedViewController];
                self.state = DXEOrderViewStateEmptyCart;
            }
            else if (operation == DXEOrderOperationOrdering)
            {
                [self switchChildViewControllerFrom:self.currentViewController
                                                 to:self.emptyOrderedViewController];
                self.state = DXEOrderViewStateOrdered;
            }
            break;
        }
        case DXEOrderViewStateOrdered:
        {
            if (operation == DXEOrderOperationAddToCart)
            {
                if (self.scrollMenu.currentIndex == DXEOrderScrollMenuIndexCart)
                {
                    [self switchChildViewControllerFrom:self.currentViewController
                                                     to:self.cartViewController];
                }
                self.state = DXEOrderViewStateOrderedWithCart;
            }
            break;
        }
        case DXEOrderViewStateOrderedWithCart:
        {
            if (operation == DXEOrderOperationOrdering)
            {
                [self switchChildViewControllerFrom:self.currentViewController
                                                 to:self.emptyOrderedViewController];
                self.state = DXEOrderViewStateOrdered;
            }
            break;
        }
        default:
            break;
    }
}

@end
