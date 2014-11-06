//
//  SFRecordDishItem.h
//  StoveFireiOSMenu
//
//  Created by Joe Shang on 9/23/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFRecordDishItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *englishName;
@property (nonatomic, strong) NSString *thumbnailKey;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *vip;

@end
