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

static NSMutableDictionary *gNamedCaches = NULL;

@interface YKURLCache()
+ (NSString *)_cachePathWithName:(NSString *)name;
@end


@implementation YKURLCache

@synthesize disableDiskCache=_disableDiskCache, cachePath=_cachePath, invalidationAge=_invalidationAge;

- (id)initWithName:(NSString *)name {
  if ((self = [super init])) {
    _name = [name copy];
    _cachePath = [[YKURLCache _cachePathWithName:name] retain];
    _invalidationAge = YKTimeIntervalDay;
  }
  return self;
}

- (id)init {
  [NSException raise:NSInvalidArgumentException format:@"Must use initWithName:"];
  return nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_name release];
  [_cachePath release];
  [super dealloc];
}

+ (dispatch_queue_t)defaultDispatchQueue {
  static dispatch_once_t once;
  static dispatch_queue_t DefaultDispatchQueue = NULL;
  dispatch_once(&once, ^{
    DefaultDispatchQueue = dispatch_queue_create("com.YelpKit.YKURLCache.defaultDispatchQueue", 0);
  });
  return DefaultDispatchQueue;
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
  YKURLCache *cache = nil;
  @synchronized([YKURLCache class]) {
    if (gNamedCaches == NULL)
      gNamedCaches = [[NSMutableDictionary alloc] init];

    cache = gNamedCaches[name];
    if (!cache) {
      cache = [[[YKURLCache alloc] initWithName:name] autorelease];
      gNamedCaches[name] = cache;
    }
  }
  return cache;
}

+ (NSString*)_cachePathWithName:(NSString*)name {
  NSString *cachesPath = [YKResource cacheDirectory];
  NSString *cachePath = [cachesPath stringByAppendingPathComponent:name];
  NSString *ETagCachePath = [cachePath stringByAppendingPathComponent:kEtagCacheDirectoryName];

  [NSFileManager gh_ensureDirectoryExists:cachesPath created:nil error:nil];
  [NSFileManager gh_ensureDirectoryExists:cachePath created:nil error:nil];
  [NSFileManager gh_ensureDirectoryExists:ETagCachePath created:nil error:nil];

  return cachePath;
}

- (NSString *)ETagFromCacheWithKey:(NSString *)key {
  NSString *path = [self ETagCachePathForKey:key];
  NSData *data = [NSData dataWithContentsOfFile:path];
  return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *)ETagCachePath {
  return [self.cachePath stringByAppendingPathComponent:kEtagCacheDirectoryName];
}

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

- (BOOL)hasDataForURLString:(NSString *)URLString {
  NSString *filePath = [self cachePathForURLString:URLString];
  NSFileManager *fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:filePath];
}

- (BOOL)hasDataForURLString:(NSString *)URLString expires:(NSTimeInterval)expires {
  NSString *key = [self keyForURLString:URLString];
  return [self hasDataForKey:key expires:expires];
}

- (NSData *)dataForURLString:(NSString *)URLString {
  return [self dataForURLString:URLString expires:YKTimeIntervalMax timestamp:nil];
}

- (NSData *)dataForURLString:(NSString *)URLString expires:(NSTimeInterval)expirationAge timestamp:(NSDate **)timestamp {
  if (!URLString) return nil;
  NSString *key = [self keyForURLString:URLString];
  return [self dataForKey:key expires:expirationAge timestamp:timestamp];
}

- (BOOL)hasDataForKey:(NSString *)key expires:(NSTimeInterval)expires {
  NSString *filePath = [self cachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:filePath]) {
    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
    NSDate *modified = attrs[NSFileModificationDate];
    if ([modified timeIntervalSinceNow] < -expires) {
      return NO;
    }
    return YES;
  }
  return NO;
}

- (NSData *)dataForKey:(NSString*)key expires:(NSTimeInterval)expires timestamp:(NSDate**)timestamp {
  NSString *filePath = [self cachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:filePath]) {
    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error:nil];
    NSDate *modified = attrs[NSFileModificationDate];
    if ([modified timeIntervalSinceNow] < -expires) {
      return nil;
    }
    if (timestamp) {
      *timestamp = modified;
    }
    return [NSData dataWithContentsOfFile:filePath];
  }
  return nil;
}

- (void)dataForURLString:(NSString *)URLString dataBlock:(YKURLCacheDataBlock)dataBlock {
  NSString *key = [self keyForURLString:URLString];
  [self dataForKey:key dataBlock:dataBlock];
}

- (void)dataForKey:(NSString *)key dataBlock:(YKURLCacheDataBlock)dataBlock {
  dispatch_async([YKURLCache defaultDispatchQueue], ^{
    NSData *data = [NSData dataWithContentsOfFile:[self cachePathForKey:key]];
    dispatch_async(dispatch_get_main_queue(), ^{
      dataBlock(data);
    });
  });
}

- (NSString *)ETagForKey:(NSString*)key {
  return [self ETagFromCacheWithKey:key];
}

- (void)storeData:(NSData *)data forURLString:(NSString *)URLString asynchronous:(BOOL)asynchronous {
  NSParameterAssert(URLString);
  NSString *key = [self keyForURLString:URLString];
  [self storeData:data forKey:key asynchronous:asynchronous];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key asynchronous:(BOOL)asynchronous {
  NSParameterAssert(key);
  if (_disableDiskCache) return;
  
  NSString *filePath = [self cachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  if (asynchronous) {
    dispatch_async([YKURLCache defaultDispatchQueue], ^{
      [fm createFileAtPath:filePath contents:data attributes:nil];
    });
  } else {
    [fm createFileAtPath:filePath contents:data attributes:nil];
  }
}

- (void)storeETag:(NSString *)ETag forKey:(NSString*)key {
  NSString *filePath = [self ETagCachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  [fm createFileAtPath:filePath contents:[ETag dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

- (void)moveDataForURLString:(NSString *)oldURLString toURLString:(NSString *)newURLString {
  NSParameterAssert(oldURLString);
  NSParameterAssert(newURLString);
  NSString *oldKey = [self keyForURLString:oldURLString];
  NSString *oldPath = [self cachePathForKey:oldKey];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:oldPath]) {
    NSString *newKey = [self keyForURLString:newURLString];
    NSString *newPath = [self cachePathForKey:newKey];
    [fm moveItemAtPath:oldPath toPath:newPath error:nil];
  }
}

- (void)moveDataFromPath:(NSString *)path toURLString:(NSString *)newURLString {
  NSParameterAssert(path);
  NSParameterAssert(newURLString);
  NSString *newKey = [self keyForURLString:newURLString];
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    NSString *newPath = [self cachePathForKey:newKey];
    [fm moveItemAtPath:path toPath:newPath error:nil];
  }
}

- (void)removeURLString:(NSString *)URLString fromDisk:(BOOL)fromDisk {
  if (fromDisk) {
    NSString *key = [self keyForURLString:URLString];
    NSString *filePath = [self cachePathForKey:key];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (filePath) {
      [fm removeItemAtPath:filePath error:nil];
    }
  }
}

- (void)removeKey:(NSString *)key {
  NSString *filePath = [self cachePathForKey:key];
  NSFileManager *fm = [NSFileManager defaultManager];
  if (filePath && [fm fileExistsAtPath:filePath]) {
    [fm removeItemAtPath:filePath error:nil];
  }
}

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
  NSFileManager *fm = [NSFileManager defaultManager];
  if (filePath && [fm fileExistsAtPath:filePath]) {
    NSDate *invalidDate = [NSDate dateWithTimeIntervalSinceNow:-_invalidationAge];
    NSDictionary *attrs = @{NSFileModificationDate: invalidDate};

#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    [fm setAttributes:attrs ofItemAtPath:filePath error:nil];
#else
    [fm changeFileAttributes:attrs atPath:filePath];
#endif
  }
}

- (void)invalidateAll {
  NSDate *invalidDate = [NSDate dateWithTimeIntervalSinceNow:-_invalidationAge];
  NSDictionary *attrs = @{NSFileModificationDate: invalidDate};

  NSFileManager *fm = [NSFileManager defaultManager];
  NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:_cachePath];
  for (NSString *fileName in enumerator) {
    NSString* filePath = [_cachePath stringByAppendingPathComponent:fileName];
#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    [fm setAttributes:attrs ofItemAtPath:filePath error:nil];
#else
    [fm changeFileAttributes:attrs atPath:filePath];
#endif
  }
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
      [self removeURLString:URLString fromDisk:YES];
    }
  }
  return image;
}

@end
