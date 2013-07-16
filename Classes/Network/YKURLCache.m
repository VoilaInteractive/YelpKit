//
//  YKURLCache.m
//  YelpIPhone
//
//  Created by Gabriel Handford on 6/24/10.
//  Copyright 2010 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

//
// Based on TTURLCache:
//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


#import "YKURLCache.h"
#import "YKResource.h"
#import "YKDefines.h"
#import "YKImageMemoryCache.h"

#include <sys/sysctl.h>


static NSString *kEtagCacheDirectoryName = @"ETag";

static NSString *gWriteFileName = nil;
static NSString *gReadFileName = nil;
static NSLock *gFileNameLock = nil;

@implementation YKURLCache

+ (void)initialize {
  if (self == [YKURLCache class]) {
    gFileNameLock = [[NSLock alloc] init];
  }
}

+ (BOOL)_setWriteFileName:(NSString *)name {
  [gFileNameLock lock];
  // Only proceed with writing the file if it is not currently being read
  BOOL shouldWrite = (!name || ![name isEqualToString:gReadFileName]);
  if (shouldWrite) {
    [name retain];
    [gWriteFileName release];
    gWriteFileName = name;
  }
  [gFileNameLock unlock];
  return shouldWrite;
}

+ (BOOL)_setReadFileName:(NSString *)name {
  [gFileNameLock lock];
  // Only proceed with reading the file if it is not currently being written to
  BOOL shouldRead = (!name || ![name isEqualToString:gWriteFileName]);
  if (shouldRead) {
    [name retain];
    [gReadFileName release];
    gReadFileName = name;
  }
  [gFileNameLock unlock];
  return shouldRead;
}

- (id)initWithName:(NSString *)name {
  if ((self = [super init])) {
    _name = [name copy];
    _cachePath = [[YKURLCache _cachePathWithName:name] retain];
    _ETagCachePath = [[YKURLCache _ETagCachePathWithName:name] retain];
    _invalidationAge = YKTimeIntervalDay;
    if (![YKURLCache _ensureCacheDirectoriesExist:name]) {
      YKAssert(NO, @"YKURLCache did not successfully create cache directory");
    }
  }
  return self;
}

- (id)init {
  [NSException raise:NSInvalidArgumentException format:@"Must use initWithName:"];
  return nil;
}

- (void)dealloc {
  [_name release];
  [_cachePath release];
  [_ETagCachePath release];
  [super dealloc];
}

+ (dispatch_queue_t)defaultWriteQueue {
  static dispatch_once_t once;
  static dispatch_queue_t DefaultWriteQueue = NULL;
  dispatch_once(&once, ^{
    DefaultWriteQueue = dispatch_queue_create("com.YelpKit.YKURLCache.defaultWriteQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(DefaultWriteQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
  });
  return DefaultWriteQueue;
}

+ (dispatch_queue_t)defaultReadQueue {
  static dispatch_once_t once;
  static dispatch_queue_t DefaultReadQueue = NULL;
  dispatch_once(&once, ^{
    DefaultReadQueue = dispatch_queue_create("com.YelpKit.YKURLCache.defaultReadQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(DefaultReadQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
  });
  return DefaultReadQueue;
}

+ (NSUInteger)getSysInfo:(uint)typeSpecifier {
  size_t size = sizeof(int);
  int results;
  int mib[2] = {CTL_HW, typeSpecifier};
  sysctl(mib, 2, &results, &size, NULL, 0);
  return (NSUInteger) results;
}

+ (NSUInteger)totalMemory {
  return [self getSysInfo:HW_PHYSMEM];
}

+ (YKURLCache *)sharedCache {
  return [self cacheWithName:@"YKURLCache"];
}

+ (YKURLCache *)cacheWithName:(NSString *)name {
  static dispatch_once_t once;
  static dispatch_queue_t CacheAccessQueue = NULL;
  static NSMutableDictionary *gNamedCaches = NULL;
  dispatch_once(&once, ^{
    gNamedCaches = [[NSMutableDictionary alloc] init];
    CacheAccessQueue = dispatch_queue_create("com.YelpKit.YKURLCache.cacheAccessQueue", DISPATCH_QUEUE_SERIAL);
  });
  
  __block YKURLCache *cache = nil;
  dispatch_sync(CacheAccessQueue, ^{
    cache = [gNamedCaches objectForKey:name];
    if (!cache) {
      cache = [[[YKURLCache alloc] initWithName:name] autorelease];
      [gNamedCaches setObject:cache forKey:name];
    }
  });
  
  return cache;
}

/*!
 @param name Name of the cache
 
 @result Whether the cache directories exist or were successfully created
 */
+ (BOOL)_ensureCacheDirectoriesExist:(NSString *)name {
  return [NSFileManager gh_ensureDirectoryExists:[YKURLCache _ETagCachePathWithName:name] created:nil error:nil];
}

+ (NSString *)_cachePathWithName:(NSString*)name {
  return [[YKResource cacheDirectory] stringByAppendingPathComponent:name];
}

+ (NSString *)_ETagCachePathWithName:(NSString *)name {
  return [[YKURLCache _cachePathWithName:name] stringByAppendingPathComponent:kEtagCacheDirectoryName];
}

#pragma mark Path handling

- (NSString *)keyForURLString:(NSString *)URLString {
  return [URLString gh_MD5];
}

- (NSString *)cachePathForURLString:(NSString *)URLString {
  NSString *key = [self keyForURLString:URLString];
  return [self cachePathForKey:key];
}

- (NSString *)cachePathForKey:(NSString *)key {
  return [_cachePath stringByAppendingPathComponent:key];
}

- (NSString *)ETagCachePathForKey:(NSString *)key {
  return [self.ETagCachePath stringByAppendingPathComponent:key];
}

- (NSString *)ETagForKey:(NSString*)key {
  return [self ETagFromCacheWithKey:key];
}

#pragma mark Cache read

- (NSString *)ETagFromCacheWithKey:(NSString *)key {
  NSString *path = [self ETagCachePathForKey:key];
  __block NSData *data = nil;
  dispatch_sync([YKURLCache defaultReadQueue], ^{
    if ([YKURLCache _setReadFileName:path]) {
      data = [NSData dataWithContentsOfFile:path];
      [YKURLCache _setReadFileName:nil];
    }
  });
  
  return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (BOOL)hasDataForURLString:(NSString *)URLString {
  return [self hasDataForURLString:URLString expires:YKTimeIntervalMax];
}

- (BOOL)hasDataForURLString:(NSString *)URLString expires:(NSTimeInterval)expires {
  NSString *key = [self keyForURLString:URLString];
  return [self hasDataForKey:key expires:expires];
}

- (BOOL)hasDataForKey:(NSString *)key expires:(NSTimeInterval)expires {
  NSString *filePath = [self cachePathForKey:key];
  __block BOOL exists = NO;
  dispatch_sync([YKURLCache defaultReadQueue], ^{
    if ([YKURLCache _setReadFileName:filePath]) {
      NSFileManager *fm = [NSFileManager defaultManager];
      if ([fm fileExistsAtPath:filePath]) {
        NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
        NSDate *modified = [attrs objectForKey:NSFileModificationDate];
        if ([modified timeIntervalSinceNow] < -expires) {
          exists = NO;
        }
        exists = YES;
      }
      [YKURLCache _setReadFileName:nil];
    }
  });

  return exists;
}

- (NSData *)dataForURLString:(NSString *)URLString {
  return [self dataForURLString:URLString expires:YKTimeIntervalMax timestamp:nil];
}

- (NSData *)dataForURLString:(NSString *)URLString expires:(NSTimeInterval)expirationAge timestamp:(NSDate **)timestamp {
  if (!URLString) return nil;
  NSString *key = [self keyForURLString:URLString];
  return [self dataForKey:key expires:expirationAge timestamp:timestamp];
}

- (NSData *)dataForKey:(NSString*)key expires:(NSTimeInterval)expires timestamp:(NSDate**)timestamp {
  NSString *filePath = [self cachePathForKey:key];
  __block NSData *data = nil;
  dispatch_sync([YKURLCache defaultReadQueue], ^{
    if ([YKURLCache _setReadFileName:filePath]) {
      NSFileManager *fm = [NSFileManager defaultManager];
      if ([fm fileExistsAtPath:filePath]) {
        NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
        NSDate *modified = [attrs objectForKey:NSFileModificationDate];
        if ([modified timeIntervalSinceNow] >= -expires) {
          data = [NSData dataWithContentsOfFile:filePath];
        }
        if (timestamp) {
          *timestamp = modified;
        }
      }
      [YKURLCache _setReadFileName:nil];
    }
  });

  return data;
}

- (void)dataForURLString:(NSString *)URLString dataBlock:(YKURLCacheDataBlock)dataBlock {
  NSString *key = [self keyForURLString:URLString];
  [self dataForKey:key dataBlock:dataBlock];
}

- (void)dataForKey:(NSString *)key dataBlock:(YKURLCacheDataBlock)dataBlock {
  NSString *filePath = [self cachePathForKey:key];
  dispatch_async([YKURLCache defaultReadQueue], ^{
    NSData *data = nil;
    if ([YKURLCache _setReadFileName:filePath]) {
      data = [NSData dataWithContentsOfFile:filePath];
      [YKURLCache _setReadFileName:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      dataBlock(data);
    });
  });
}

#pragma mark Cache write

- (void)storeData:(NSData *)data forURLString:(NSString *)URLString asynchronous:(BOOL)asynchronous {
  NSParameterAssert(URLString);
  NSString *key = [self keyForURLString:URLString];
  [self storeData:data forKey:key asynchronous:asynchronous];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key asynchronous:(BOOL)asynchronous {
  NSParameterAssert(key);
  NSString *filePath = [self cachePathForKey:key];
  [self _storeData:data forPath:filePath asynchronous:asynchronous];
}

- (void)storeETag:(NSString *)ETag forKey:(NSString*)key asynchronous:(BOOL)asynchronous {
  NSString *filePath = [self ETagCachePathForKey:key];
  [self _storeData:[ETag dataUsingEncoding:NSUTF8StringEncoding] forPath:filePath asynchronous:asynchronous];
}

- (void)_storeData:(NSData *)data forPath:(NSString *)path asynchronous:(BOOL)asynchronous {
  if (_disableDiskCache) return;
  
  NSFileManager *fm = [NSFileManager defaultManager];
  void (^storeAction)() = ^{
    if ([YKURLCache _setWriteFileName:path]) {
      [fm createFileAtPath:path contents:data attributes:nil];
      [YKURLCache _setWriteFileName:nil];
    }
  };
  
  if (asynchronous) {
    dispatch_async([YKURLCache defaultWriteQueue], storeAction);
  } else {
    dispatch_sync([YKURLCache defaultWriteQueue], storeAction);
  }
}

- (void)moveDataForURLString:(NSString *)oldURLString toURLString:(NSString *)newURLString {
  NSParameterAssert(oldURLString);
  NSParameterAssert(newURLString);
  NSString *oldKey = [self keyForURLString:oldURLString];
  NSString *oldPath = [self cachePathForKey:oldKey];
  [self moveDataFromPath:oldPath toURLString:newURLString];
}

- (void)moveDataFromPath:(NSString *)path toURLString:(NSString *)newURLString {
  NSParameterAssert(path);
  NSParameterAssert(newURLString);
  NSString *newKey = [self keyForURLString:newURLString];
  NSFileManager *fm = [NSFileManager defaultManager];
  
  // Assume moving data to a new URL, this means moving is equivalent to a read operation, could check the new URL too but that increases complexity significantly
  dispatch_sync([YKURLCache defaultReadQueue], ^{
    if ([YKURLCache _setReadFileName:path]) {
      if ([fm fileExistsAtPath:path]) {
        NSString *newPath = [self cachePathForKey:newKey];
        [fm moveItemAtPath:path toPath:newPath error:nil];
      }
      [YKURLCache _setReadFileName:nil];
    }
  });
}

- (void)removeURLString:(NSString *)URLString {
  NSString *key = [self keyForURLString:URLString];
  [self removeKey:key];
}

- (void)removeKey:(NSString *)key {
  NSString *filePath = [self cachePathForKey:key];
  [self _removePath:filePath];
}

- (void)_removePath:(NSString *)path {
  NSFileManager *fm = [NSFileManager defaultManager];
  dispatch_async([YKURLCache defaultWriteQueue], ^{
    if ([YKURLCache _setWriteFileName:path]) {
      [fm removeItemAtPath:path error:nil];
      [YKURLCache _setWriteFileName:nil];
    }
  });
}

// This method is blocking and not thread safe
- (void)removeAll {
  NSFileManager *fm = [NSFileManager defaultManager];
  [fm removeItemAtPath:_cachePath error:nil];
  [NSFileManager gh_ensureDirectoryExists:_cachePath created:nil error:nil];
}

- (void)invalidateURLString:(NSString *)URLString {
  NSString *key = [self keyForURLString:URLString];
  return [self invalidateKey:key];
}

- (void)invalidateKey:(NSString *)key {
  NSString *filePath = [self cachePathForKey:key];
  [self _invalidatePath:filePath];
}

- (void)invalidateAll {
  NSFileManager *fm = [NSFileManager defaultManager];
  NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:_cachePath];
  for (NSString *fileName in enumerator) {
    NSString* filePath = [_cachePath stringByAppendingPathComponent:fileName];
    [self _invalidatePath:filePath];
  }
}

- (void)_invalidatePath:(NSString *)path {
  NSDate *invalidDate = [NSDate dateWithTimeIntervalSinceNow:-_invalidationAge];
  NSDictionary *attrs = [NSDictionary dictionaryWithObject:invalidDate forKey:NSFileModificationDate];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  dispatch_async([YKURLCache defaultWriteQueue], ^{
    if ([YKURLCache _setWriteFileName:path]) {
      [fm setAttributes:attrs ofItemAtPath:path error:nil];
      [YKURLCache _setWriteFileName:nil];
    }
  });
}

#pragma mark Image Disk Cache

- (UIImage *)diskCachedImageForURLString:(NSString *)URLString expires:(NSTimeInterval)expires {
  if (!URLString) return nil;
#if DEBUG
  NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#endif
  UIImage *image = nil;
  NSData *cachedData = [self dataForURLString:URLString expires:expires timestamp:nil];
  if (cachedData) {
    image = [UIImage imageWithData:cachedData];
    YKDebug(@"Image disk cache HIT: %@ (length=%d), Loading image took: %0.3f", URLString, [cachedData length], ([NSDate timeIntervalSinceReferenceDate] - start));
    // If the image was invalid, remove it from the cache
    if (!image) {
      [self removeURLString:URLString];
    }
  }
  return image;
}

@end
