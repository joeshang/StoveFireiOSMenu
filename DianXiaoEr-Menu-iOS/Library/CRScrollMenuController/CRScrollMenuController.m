//
//  CRScrollMenuController.m
//  CRScrollMenuController
//
//  Created by Joe Shang on 9/10/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "CRScrollMenuController.h"

#define kCRScrollMenuDefaultHeight          44

@interface CRScrollMenuController ()
< CRScrollMenuDelegate, UIScrollViewDelegate >

@property (nonatomic, strong) CRScrollMenu *scrollMenu;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation CRScrollMenuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    _scrollMenuHeight = kCRScrollMenuDefaultHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    self.scrollMenu.frame = CGRectMake(0,
                                       0,
                                       CGRectGetWidth(self.view.bounds),
                                       self.scrollMenuHeight);
    self.scrollView.frame = CGRectMake(0,
                                       self.scrollMenuHeight,
                                       CGRectGetWidth(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds) - self.scrollMenuHeight);
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *childController, NSUInteger index, BOOL *stop){
        childController.view.frame = CGRectMake(index * CGRectGetWidth(self.scrollView.bounds),
                                                0,
                                                CGRectGetWidth(self.scrollView.bounds),
                                                CGRectGetHeight(self.scrollView.bounds));
    }];
    self.scrollView.contentSize = CGSizeMake([self.viewControllers count] * CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    self.scrollView.contentOffset = CGPointMake(self.currentIndex * CGRectGetWidth(self.scrollView.bounds), 0);
}

#pragma mark - overwritten getters/setters

- (UIScrollView *)scrollView
{
    if (_scrollView == nil)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                     self.scrollMenuHeight,
                                                                     CGRectGetWidth(self.view.bounds),
                                                                     CGRectGetHeight(self.view.bounds) - self.scrollMenuHeight)];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.directionalLockEnabled = YES;
        [self.view addSubview:_scrollView];
        
    }
    
    return _scrollView;
}

- (CRScrollMenu *)scrollMenu
{
    if (_scrollMenu == nil)
    {
        _scrollMenu = [[CRScrollMenu alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     CGRectGetWidth(self.view.bounds),
                                                                     self.scrollMenuHeight)];
        _scrollMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _scrollMenu.delegate = self;
        [self.view addSubview:_scrollMenu];
    }
    
    return _scrollMenu;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    NSAssert(currentIndex < self.viewControllers.count, @"currentIndex should belong within the range of the view controllers array");
    
    if (_currentIndex != currentIndex)
    {
        _currentIndex = currentIndex;
        
        [self.scrollMenu scrollToIndex:currentIndex];
        [self.scrollView setContentOffset:CGPointMake(currentIndex * self.scrollView.bounds.size.width, 0.) animated:YES];
    }
}

- (void)setScrollMenuHeight:(NSUInteger)scrollMenuHeight
{
    if (_scrollMenuHeight != scrollMenuHeight)
    {
        _scrollMenuHeight = scrollMenuHeight;
        [self layoutSubviews];
    }
}

- (void)setScrollMenuBackgroundColor:(UIColor *)scrollMenuBackgroundColor
{
    self.scrollMenuBackgroundColor = scrollMenuBackgroundColor;
}

- (void)setScrollMenuBackgroundImage:(UIImage *)scrollMenuBackgroundImage
{
    self.scrollMenu.backgroundImage = scrollMenuBackgroundImage;
}

- (void)setScrollMenuIndicatorColor:(UIColor *)scrollMenuIndicatorColor
{
    self.scrollMenu.indicatorColor = scrollMenuIndicatorColor;
}

- (void)setScrollMenuIndicatorHeight:(NSUInteger)scrollMenuIndicatorHeight
{
    self.scrollMenu.indicatorHeight = scrollMenuIndicatorHeight;
}

- (void)setScrollMenuButtonPadding:(NSUInteger)scrollMenuButtonPadding
{
    self.scrollMenu.buttonPadding = scrollMenuButtonPadding;
}

- (void)setNormalTitleAttributes:(NSDictionary *)normalTitleAttributes
{
    self.scrollMenu.normalTitleAttributes = normalTitleAttributes;
}

- (void)setSelectedTitleAttributes:(NSDictionary *)selectedTitleAttributes
{
    self.scrollMenu.selectedTitleAttributes = selectedTitleAttributes;
}

- (void)setNormalSubtitleAttributes:(NSDictionary *)normalSubtitleAttributes
{
    self.scrollMenu.normalSubtitleAttributes = normalSubtitleAttributes;
}

- (void)setSelectedSubtitleAttributes:(NSDictionary *)selectedSubtitleAttributes
{
    self.scrollMenu.selectedSubtitleAttributes = selectedSubtitleAttributes;
}

- (void)setViewControllers:(NSArray *)viewControllers withItems:(NSArray *)items
{
    if (_viewControllers != viewControllers)
    {
        if (self.viewControllers != nil)
        {
            for (UIViewController *controller in _viewControllers)
            {
                [controller willMoveToParentViewController:nil];
                [controller.view removeFromSuperview];
                [controller removeFromParentViewController];
            }
        }
        
        _viewControllers = [NSMutableArray arrayWithArray:viewControllers];
        
        [viewControllers enumerateObjectsUsingBlock:^(UIViewController *childController, NSUInteger index, BOOL *stop){
            [self addChildViewController:childController];
            [self.scrollView addSubview:childController.view];
            [childController didMoveToParentViewController:self];
        }];
        
        [self.scrollMenu setButtonsByItems:items];
        
        _currentIndex = 0;
    }
}

#pragma mark - CRScrollMenu delegate

- (void)scrollMenu:(CRScrollMenu *)scrollMenu didSelectedAtIndex:(NSUInteger)index
{
    [self.scrollView setContentOffset:CGPointMake(index * self.scrollView.bounds.size.width, 0) animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentIndex = scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.bounds);
}

@end
