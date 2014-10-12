//
//  DXEDishDataManager.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/2/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXEDishItem.h"
#import "DXEDishClass.h"

@interface DXEDishDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *dishClasses;

+ (DXEDishDataManager *)sharedInstance;
- (void)loadDataFromWeb;

@end
