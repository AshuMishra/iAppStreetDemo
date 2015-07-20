//
//  DiskCache.h
//  ETAsyncableImageView
//
//  Created by plb-fueled on 04/06/13.
//  Copyright (c) 2013 fueled.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    FileDeletionTypeNone = 0,
    FileDeletionTypeSize,
    FileDeletionTypeTime
    
} FileDeletionType;


@interface DiskCache : NSObject

+(DiskCache *) sharedCache;

- (void)setCache:(NSData *)data forKey:(NSString *)key;
- (void)setCache:(NSData *)data forKey:(NSString *)key withGroup:(NSString *)group;
- (NSData *)getCacheForKey:(NSString *)key;
- (NSData *)getCacheForKey:(NSString *)key withGroup:(NSString *)group;

- (void)getImageForKey:(NSString *)key forView:(UIImageView *)imageView;
- (void)setFileDeletionType:(FileDeletionType) deletionType;
- (unsigned long long int) diskCacheFolderSize;
- (NSArray *)allKeys;

- (UIImage *)imageForKey:(NSString *)key;

@end
