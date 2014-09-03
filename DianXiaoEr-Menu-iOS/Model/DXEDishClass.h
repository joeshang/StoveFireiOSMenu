//
//  DXEDishClass.h
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 8/31/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXEDishClass : NSObject

@property (nonatomic, strong) NSNumber *classid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *showSequence;
@property (nonatomic, strong) NSString *imageKey;

@property (nonatomic, strong) NSMutableArray *dishes;

- (void)updateByNewObject:(DXEDishClass *)update;

@end
