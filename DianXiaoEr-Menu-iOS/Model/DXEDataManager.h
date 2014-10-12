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

@interface DXEDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *dishClasses;
@property (nonatomic, strong) NSMutableArray *tables;
@property (nonatomic, copy)   NSString *staffid;
@property (nonatomic, copy)   NSString *openid;
@property (nonatomic, copy)   NSString *tableid;

+ (DXEDataManager *)sharedInstance;
- (void)loadDataFromWeb;

@end
