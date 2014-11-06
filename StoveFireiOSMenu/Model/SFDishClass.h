//
//  SFDishClass.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 8/31/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDishClass : NSObject

@property (nonatomic, strong) NSNumber *classid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *englishName;
@property (nonatomic, strong) NSNumber *showSequence;
@property (nonatomic, strong) NSString *imageKey;
@property (nonatomic, strong) NSNumber *vip;

@property (nonatomic, strong) NSMutableArray *dishes;

- (void)updateByNewObject:(SFDishClass *)update;

@end
