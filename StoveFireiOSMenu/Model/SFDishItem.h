//
//  SFDishItem.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 8/31/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDishItem : NSObject

@property (nonatomic, strong) NSNumber *itemid;
@property (nonatomic, strong) NSNumber *classid;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *englishName;
@property (nonatomic, copy)   NSString *imageKey;
@property (nonatomic, copy)   NSString *thumbnailKey;
@property (nonatomic, strong) NSNumber *showSequence;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *favor;
@property (nonatomic, copy)   NSString *ingredient;
@property (nonatomic, strong) NSNumber *soldout;
@property (nonatomic, strong) NSNumber *vip;

@property (nonatomic, assign) BOOL inCart;
@property (nonatomic, assign) BOOL inFavor;

- (void)updateByNewObject:(SFDishItem *)update;

@end
