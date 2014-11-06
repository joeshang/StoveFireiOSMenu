//
//  SFOriginViewController.m
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 7/15/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "SFOriginViewController.h"

@interface SFOriginViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation SFOriginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIImage *originContent = [UIImage imageNamed:@"origin_content"];
    CGSize imageSize = [originContent size];
    UIImageView *origin = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        imageSize.width,
                                                                        imageSize.height)];
    origin.image = originContent;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.bounces = NO;
    self.scrollView.contentSize = imageSize;
    [self.scrollView addSubview:origin];
    [self.view addSubview:self.scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.frame = self.view.bounds;
}

@end
