//
//  SFOrderViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOrderViewController.h"
#import "SFOrderManager.h"
#import "SCRScrollMenu.h"
#import "SFOrderCartViewController.h"
#import "SFOrderProgressViewController.h"
#import "SFOrderEmptyViewController.h"

typedef NS_ENUM(NSUInteger, SFOrderViewState)
{
    SFOrderViewStateEmptyCart,
    SFOrderViewStateCartButNotOrdered,
    SFOrderViewStateOrdered,
    SFOrderViewStateOrderedWithCart
};

typedef NS_ENUM(NSUInteger, SFOrderScrollMenuIndex)
{
    SFOrderScrollMenuIndexCart,
    SFOrderScrollMenuIndexProgress
};

typedef NS_ENUM(NSUInteger, SFOrderOperation)
{
    SFOrderOperationUnconcern,
    SFOrderOperationAddToCart,
    SFOrderOperationClearCart,
    SFOrderOperationOrdering
};

#define kSFOrderScrollMenuTitles                    @[@"已点菜品", @"制作进度"]
#define kSFOrderScrollMenuHeight                    53
#define kSFOrderScrollMenuButtonPadding             30
#define kSFOrderScrollMenuIndicatorHeight           2
#define kSFOrderScrollMenuTitleFontSize             20

@interface SFOrderViewController ()
< SCRScrollMenuDelegate >

@property (nonatomic, strong) SCRScrollMenu *scrollMenu;
@property (nonatomic, strong) SFOrderCartViewController *cartViewController;
@property (nonatomic, strong) SFOrderProgressViewController *progressViewController;
@property (nonatomic, strong) SFOrderEmptyViewController *emptyOrderedViewController;
@property (nonatomic, strong) SFOrderEmptyViewController *emptyNotOrderedViewController;

@property (nonatomic, assign) SFOrderViewState state;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) NSMutableArray *menuContentContainer;

@end

@implementation SFOrderViewController

#pragma mark - init & dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[SFOrderManager sharedInstance] addObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(cartList))
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
        [[SFOrderManager sharedInstance] addObserver:self
                                           forKeyPath:NSStringFromSelector(@selector(orderList))
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
        _state = SFOrderViewStateEmptyCart;
    }
    return self;
}

- (void)dealloc
{
    [[SFOrderManager sharedInstance] removeObserver:self
                                          forKeyPath:NSStringFromSelector(@selector(cartList))];
    [[SFOrderManager sharedInstance] removeObserver:self
                                          forKeyPath:NSStringFromSelector(@selector(orderList))];
}

#pragma mark - view related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[RNThemeManager sharedManager] colorForKey:@"BackgroundColor"];
    
    UIColor *normalColor =[[RNThemeManager sharedManager] colorForKey:@"DarkenColor"];
    UIColor *selectedColor =[[RNThemeManager sharedManager] colorForKey:@"HighlightColor"];
    self.scrollMenu = [[SCRScrollMenu alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     CGRectGetWidth(self.view.bounds),
                                                                     kSFOrderScrollMenuHeight)];
    self.scrollMenu.delegate = self;
    self.scrollMenu.backgroundImage = [[RNThemeManager sharedManager] imageForKey:@"scrollmenu_background"];
    self.scrollMenu.indicatorColor = selectedColor;
    self.scrollMenu.indicatorHeight = kSFOrderScrollMenuIndicatorHeight;
    self.scrollMenu.buttonPadding = kSFOrderScrollMenuButtonPadding;
    self.scrollMenu.normalTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kSFOrderScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: normalColor
      };
    self.scrollMenu.selectedTitleAttributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:kSFOrderScrollMenuTitleFontSize],
      NSForegroundColorAttributeName: selectedColor
      };
    [self.view addSubview:self.scrollMenu];
    
    NSArray *titles = kSFOrderScrollMenuTitles;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[titles count]];
    for (NSString *title in titles)
    {
        SCRScrollMenuItem *item = [[SCRScrollMenuItem alloc] init];
        item.title = title;
        [items addObject:item];
    }
    [self.scrollMenu setButtonsByItems:items];
    
    self.cartViewController = [[SFOrderCartViewController alloc] init];
    [self addChildViewController:self.cartViewController];
    [self.cartViewController willMoveToParentViewController:self];
    
    self.progressViewController = [[SFOrderProgressViewController alloc] init];
    [self addChildViewController:self.progressViewController];
    [self.progressViewController willMoveToParentViewController:self];
    
    self.emptyNotOrderedViewController = [[SFOrderEmptyViewController alloc] init];
    self.emptyNotOrderedViewController.type = SFOrderEmptyViewControllerTypeNotOrdered;
    [self addChildViewController:self.emptyNotOrderedViewController];
    [self.emptyNotOrderedViewController willMoveToParentViewController:self];
    
    self.emptyOrderedViewController = [[SFOrderEmptyViewController alloc] init];
    self.emptyOrderedViewController.type = SFOrderEmptyViewControllerTypeOrdered;
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
                                                       kSFOrderScrollMenuHeight,
                                                       CGRectGetWidth(self.view.bounds),
                                                       CGRectGetHeight(self.view.bounds) - kSFOrderScrollMenuHeight);
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
                               kSFOrderScrollMenuHeight,
                               CGRectGetWidth(self.view.bounds),
                               CGRectGetHeight(self.view.bounds) - kSFOrderScrollMenuHeight);
    self.currentViewController = to;
}

- (void)setState:(SFOrderViewState)state
{
    switch (state) {
        case SFOrderViewStateEmptyCart:
            [self.menuContentContainer replaceObjectAtIndex:SFOrderScrollMenuIndexCart
                                                 withObject:self.emptyNotOrderedViewController];
            [self.menuContentContainer replaceObjectAtIndex:SFOrderScrollMenuIndexProgress
                                                 withObject:self.emptyNotOrderedViewController];
            break;
        case SFOrderViewStateCartButNotOrdered:
            [self.menuContentContainer replaceObjectAtIndex:SFOrderScrollMenuIndexCart
                                                 withObject:self.cartViewController];
            [self.menuContentContainer replaceObjectAtIndex:SFOrderScrollMenuIndexProgress
                                                 withObject:self.emptyNotOrderedViewController];
            break;
        case SFOrderViewStateOrdered:
            [self.menuContentContainer replaceObjectAtIndex:SFOrderScrollMenuIndexCart
                                                 withObject:self.emptyOrderedViewController];
            [self.menuContentContainer replaceObjectAtIndex:SFOrderScrollMenuIndexProgress
                                                 withObject:self.progressViewController];
            break;
        case SFOrderViewStateOrderedWithCart:
            [self.menuContentContainer replaceObjectAtIndex:SFOrderScrollMenuIndexCart
                                                 withObject:self.cartViewController];
            [self.menuContentContainer replaceObjectAtIndex:SFOrderScrollMenuIndexProgress
                                                 withObject:self.progressViewController];
        default:
            break;
    }
    
    _state = state;
}

#pragma mark - notification

- (void)scrollMenu:(SCRScrollMenu *)scrollMenu didSelectedAtIndex:(NSUInteger)index
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
    SFOrderOperation operation = SFOrderOperationUnconcern;
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(cartList))])
    {
        if (kind == NSKeyValueChangeInsertion)
        {
            operation = SFOrderOperationAddToCart;
        }
        else if (kind == NSKeyValueChangeRemoval)
        {
            if ([[SFOrderManager sharedInstance].cart count] == 0)
            {
                if ([[SFOrderManager sharedInstance].order count] == 0)
                {
                    operation = SFOrderOperationClearCart;
                }
                else
                {
                    operation = SFOrderOperationOrdering;
                }
            }
        }
    }
    else if ([keyPath isEqualToString:NSStringFromSelector(@selector(orderList))])
    {
        if (kind == NSKeyValueChangeInsertion)
        {
            operation = SFOrderOperationOrdering;
        }
    }
    
    if (operation == SFOrderOperationUnconcern)
    {
        return;
    }
    
    switch (self.state)
    {
        case SFOrderViewStateEmptyCart:
        {
            if (operation == SFOrderOperationAddToCart)
            {
                if (self.scrollMenu.currentIndex == SFOrderScrollMenuIndexCart)
                {
                    [self switchChildViewControllerFrom:self.currentViewController
                                                     to:self.cartViewController];
                }
                self.state = SFOrderViewStateCartButNotOrdered;
            }
            else if (operation == SFOrderOperationOrdering)
            {
                if (self.scrollMenu.currentIndex == SFOrderScrollMenuIndexCart)
                {
                    [self.scrollMenu scrollToIndex:SFOrderScrollMenuIndexProgress];
                    [self switchChildViewControllerFrom:self.currentViewController
                                                     to:self.progressViewController];
                }
                self.state = SFOrderViewStateOrdered;
            }
            break;
        }
        case SFOrderViewStateCartButNotOrdered:
        {
            if (operation == SFOrderOperationClearCart)
            {
                [self switchChildViewControllerFrom:self.currentViewController
                                                 to:self.emptyNotOrderedViewController];
                self.state = SFOrderViewStateEmptyCart;
            }
            else if (operation == SFOrderOperationOrdering)
            {
                [self switchChildViewControllerFrom:self.currentViewController
                                                 to:self.progressViewController];
                [self.scrollMenu scrollToIndex:SFOrderScrollMenuIndexProgress];
                self.state = SFOrderViewStateOrdered;
            }
            break;
        }
        case SFOrderViewStateOrdered:
        {
            if (operation == SFOrderOperationAddToCart)
            {
                if (self.scrollMenu.currentIndex == SFOrderScrollMenuIndexCart)
                {
                    [self switchChildViewControllerFrom:self.currentViewController
                                                     to:self.cartViewController];
                }
                self.state = SFOrderViewStateOrderedWithCart;
            }
            break;
        }
        case SFOrderViewStateOrderedWithCart:
        {
            if (operation == SFOrderOperationOrdering)
            {
                [self switchChildViewControllerFrom:self.currentViewController
                                                 to:self.progressViewController];
                [self.scrollMenu scrollToIndex:SFOrderScrollMenuIndexProgress];
                self.state = SFOrderViewStateOrdered;
            }
            break;
        }
        default:
            break;
    }
}

@end
