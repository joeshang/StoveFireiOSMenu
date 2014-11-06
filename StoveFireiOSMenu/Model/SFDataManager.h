//
//  SFDishDataManager.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/2/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFDishItem.h"
#import "SFDishClass.h"

@interface SFDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *dishClasses;
@property (nonatomic, strong) NSMutableDictionary *dishes;
@property (nonatomic, strong) NSArray *tables;
@property (nonatomic, strong) NSNumber *staffid;
@property (nonatomic, strong) NSNumber *openid;
@property (nonatomic, strong) NSNumber *tableid;

+ (SFDataManager *)sharedInstance;
- (void)loadDataFromWeb;

@end
