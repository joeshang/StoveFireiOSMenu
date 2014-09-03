//
//  DXEImageManager.m
//  DianXiaoEr-Menu-iOS
//
//  Created by Joe Shang on 9/3/14.
//  Copyright (c) 2014 Shang Chuanren. All rights reserved.
//

#import "DXEImageManager.h"
#import "UIImageView+WebCache.h"

@interface DXEImageManager ()

@property (nonatomic, strong) NSMutableArray *cachedImageKeys;
@property (nonatomic, strong) NSMutableDictionary *cachedImages;

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
        
        sharedManager.cachedImages = [[NSMutableDictionary alloc] init];
    }
    
    return sharedManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

#pragma mark - getting image

- (NSString *)imagePathForKey:(NSString *)imageKey
{
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [cacheDirectory stringByAppendingString:imageKey];
}

- (UIImage *)imageForKey:(NSString *)imageKey
{
    UIImage *image = [self.cachedImages objectForKey:imageKey];
    if (image == nil)
    {
        image = [UIImage imageWithContentsOfFile:[self imagePathForKey:imageKey]];
        
        if (image)
        {
            [self.cachedImages setValue:image forKey:imageKey];
        }
        else
        {
            NSLog(@"Error: unable to find %@", [self imagePathForKey:imageKey]);
        }
    }
    
    return image;
}

- (void)deleteImageForKey:(NSString *)imageKey
{
    [[SDWebImageManager sharedManager].imageCache removeImageForKey:imageKey];
}

- (void)requestWebImageForKey:(NSString *)imageKey
{
    [[SDWebImageManager sharedManager] downloadImageWithURL:nil
                                                    options:0
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                                                      if (image && finished)
                                                      {
                                                          NSLog(@"%@", [imageURL absoluteString]);
                                                          [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:imageKey];
                                                      }
                                                  }];
}

- (void)updateImageWithKeys:(NSMutableArray *)newImageKeys
{
    if ([newImageKeys count] == 0)
    {
        return;
    }
    
    if ([self.cachedImageKeys count] == 0)
    {
        // 本地无图片，因此要请求每一个newKey对应的图片
        for (NSString *newKey in newImageKeys)
        {
            [self requestWebImageForKey:newKey];
        }
    }
    else
    {
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
                    NSString *newID = [[newKey componentsSeparatedByString:@"_"] objectAtIndex:0];
                    NSString *cachedID = [[cachedKey componentsSeparatedByString:@"_"] objectAtIndex:0];
                    // 图片id匹配说明是更新项，删除旧图片，请求新图片
                    if ([newID isEqualToString:cachedID])
                    {
                        *stop = YES;
                        [self.cachedImageKeys removeObject:cachedKey];
                        
                        [self deleteImageForKey:cachedKey];
                        [self requestWebImageForKey:newKey];
                    }
                    else
                    {
                        // newKey在cachedImageKeys没有匹配项，说明是新增项，请求图片
                        if ([cachedKey isEqualToString:[self.cachedImageKeys lastObject]])
                        {
                            [self requestWebImageForKey:newKey];
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
    
    self.cachedImageKeys = [NSMutableArray arrayWithArray:newImageKeys];
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
