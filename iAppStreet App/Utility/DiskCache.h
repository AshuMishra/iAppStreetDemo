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

@property(nonatomic,strong) NSString* groupName;
+(DiskCache *) sharedCache;

- (void)setCache:(NSData *)data forKey:(NSString *)key withGroup:(NSString *)group;
- (NSData *)getCacheForKey:(NSString *)key withGroup:(NSString *)group;
- (void)setFileDeletionType:(FileDeletionType) deletionType;
- (unsigned long long int) diskCacheFolderSize;
- (NSArray *)allKeys:(NSString *)groupname;

@end
