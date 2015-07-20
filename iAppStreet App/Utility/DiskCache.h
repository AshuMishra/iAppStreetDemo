//
//  DiskCache.h
//  iAppStreet App
//
//  Created by Ashutosh Mishra on 19/07/15.
//  Copyright (c) 2015 Ashutosh Mishra. All rights reserved.
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
