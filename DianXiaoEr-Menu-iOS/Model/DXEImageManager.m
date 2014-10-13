//
//  DXEImageManager.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEImageManager.h"
#import "UIImageView+WebCache.h"

//#define DXE_TEST_IMAGE_KEYS

@interface DXEImageManager ()

@property (nonatomic, strong) NSMutableArray *cachedImageKeys;

- (NSString *)cachedImageKeysArchivePath;
- (NSString *)imagePathForKey:(NSString *)imageKey;

@end

@implementation DXEImageManager

#pragma mark - singleton init

+ (DXEImageManager *)sharedInstance
{
    static DXEImageManager *sharedManager = nil;
    
    if (sharedManager == nil)
    {
        sharedManager = [[super allocWithZone:nil] init];
        
        NSString *path = [sharedManager cachedImageKeysArchivePath];
        sharedManager.cachedImageKeys = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (sharedManager.cachedImageKeys == nil)
        {
            sharedManager.cachedImageKeys = [[NSMutableArray alloc] init];
        }
    }
    
    return sharedManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

#pragma mark - getting image

// imageKey的命名格式为：class-id@time
//  * class：图片的种类，例如菜类图片的class为0，菜品图片的class为1
//  * id：图片的ID，是图片在本类中的唯一标示
//  * time：图片更新的时间，用来对比图片是否需要更新

- (NSString *)imagePathForKey:(NSString *)imageKey
{
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [cacheDirectory stringByAppendingString:imageKey];
}

- (UIImage *)imageForKey:(NSString *)imageKey
{
#ifdef DXE_TEST_IMAGE_KEYS
    NSString *imageClass = [imageKey substringToIndex:1];
    UIImage *image;
    if ([imageClass isEqualToString:@"0"])
    {
        image = [UIImage imageNamed:@"test_dish_class.jpg"];
    }
    else if ([imageClass isEqualToString:@"1"])
    {
        image = [UIImage imageNamed:@"test_dish_item.jpg"];
    }
    else if ([imageClass isEqualToString:@"2"])
    {
        image = [UIImage imageNamed:@"test_dish_item_thumbnail.jpg"];
    }
    return image;
#else
    return [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:imageKey];
#endif
}

- (void)deleteImageForKey:(NSString *)imageKey
{
#ifdef DXE_TEST_IMAGE_KEYS
    NSLog(@"delete image: %@", imageKey);
#else
    [[SDWebImageManager sharedManager].imageCache removeImageForKey:imageKey];
#endif
}

- (void)updateImageWithKeys:(NSMutableArray *)newImageKeys
{
#ifdef DXE_TEST_IMAGE_KEYS
#else
    if ([newImageKeys count] == 0)
    {
        return;
    }
    
    NSMutableArray *requestImageKeys = nil;
    if ([self.cachedImageKeys count] == 0)
    {
        // 本地无图片，因此要请求每一个newKey对应的图片
        requestImageKeys = [NSMutableArray arrayWithArray:newImageKeys];
    }
    else
    {
        requestImageKeys = [[NSMutableArray alloc] init];
        
        for (NSString *newKey in newImageKeys)
        {
            [self.cachedImageKeys enumerateObjectsUsingBlock:^(NSString *cachedKey, NSUInteger index, BOOL *stop){
                // 完全匹配说明图片无更新
                if ([newKey isEqualToString:cachedKey])
                {
                    *stop = YES;
                    [self.cachedImageKeys removeObject:cachedKey];
                }
                else
                {
                    NSString *newID = [[newKey componentsSeparatedByString:@"@"] objectAtIndex:0];
                    NSString *cachedID = [[cachedKey componentsSeparatedByString:@"@"] objectAtIndex:0];
                    // 图片id匹配说明是更新项，删除旧图片，请求新图片
                    if ([newID isEqualToString:cachedID])
                    {
                        *stop = YES;
                        [self.cachedImageKeys removeObject:cachedKey];
                        
                        [self deleteImageForKey:cachedKey];
                        [requestImageKeys addObject:newKey];
                    }
                    else
                    {
                        // newKey在cachedImageKeys没有匹配项，说明是新增项，请求图片
                        if ([cachedKey isEqualToString:[self.cachedImageKeys lastObject]])
                        {
                            [requestImageKeys addObject:newKey];
                        }
                    }
                }
            }];
        }
        
        // 对比完newImageKeys后在cachedImageKeys中还剩下的全是需要删除的图片
        if ([self.cachedImageKeys count] != 0)
        {
            for (NSString *cachedKey in self.cachedImageKeys)
            {
                [self deleteImageForKey:cachedKey];
            }
        }
    }
    
    // 向服务器请求图片
    if ([requestImageKeys count] != 0)
    {
        __block NSUInteger totalCount = [requestImageKeys count];
        __block NSUInteger process = 0;
        NSString *message = [NSString stringWithFormat:@"正在加载图片(进度:%lu/%lu)", process, totalCount];
        NSDictionary *userInfo = @{ @"message": message };
        [[NSNotificationCenter defaultCenter] postNotificationName:kDXEDidLoadingProgressNotification object:self userInfo:userInfo];
        for (NSString *imageKey in requestImageKeys)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kDXEImageBaseURL, imageKey]];
            [[SDWebImageManager sharedManager] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
             {
                 if (finished)
                 {
                     if (error)
                     {
                         NSLog(@"Get image %@: %@", imageURL, error);
                         process++;
                     }
                     else if (image && finished)
                     {
                         NSLog(@"%@", [imageURL absoluteString]);
                         [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:imageKey];
                         
                         process++;
                     }
                     
                     NSString *message = [NSString stringWithFormat:@"正在加载图片(进度:%lu/%lu)", process, totalCount];
                     NSDictionary *userInfo = @{ @"message": message };
                     [[NSNotificationCenter defaultCenter] postNotificationName:kDXEDidLoadingProgressNotification object:self userInfo:userInfo];
                     if (process == totalCount)
                     {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kDXEDidFinishLoadingNotification object:self];
                     }
                 }
             }];
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDXEDidFinishLoadingNotification object:self];
    }
    
    self.cachedImageKeys = [NSMutableArray arrayWithArray:newImageKeys];
#endif
}

#pragma mark - archive

- (BOOL)saveChanges
{
    NSString *path = [self cachedImageKeysArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.cachedImageKeys toFile:path];
}

- (NSString *)cachedImageKeysArchivePath
{
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [cacheDirectory stringByAppendingString:@"imageKeys.archive"];
}

@end
