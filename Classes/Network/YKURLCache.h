//
//  YKURLCache.h
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

typedef void (^YKURLCacheDataBlock)(NSData *data);

/*!
 A general purpose URL cache for caching data in memory and on disk.
 
 Based on TTURLCache from Three20 library.
 */
@interface YKURLCache : NSObject {  
  NSString *_name;
}

/*!
 Disables the disk cache. Disables ETag support as well.
 */
@property (assign, nonatomic) BOOL disableDiskCache;

/*!
 Gets the path to the directory of the disk cache.
 */
@property (copy, nonatomic) NSString *cachePath;

/*!
 Gets the path to the directory of the disk cache for ETags.
 */
@property (nonatomic, readonly) NSString *ETagCachePath;

/*!
  The amount of time to set back the modification timestamp on files when invalidating them.
 */
@property (assign, nonatomic) NSTimeInterval invalidationAge;

/*!
 Gets a shared cache identified with a unique name.

 @param name Name
 */
+ (YKURLCache *)cacheWithName:(NSString *)name;

/*!
 Get shared cache.
 */
+ (YKURLCache *)sharedCache;

/*!
 Create cache.

 @param name Name
 */
- (id)initWithName:(NSString *)name;

/*!
 Total memory for the device.
 */
+ (NSUInteger)totalMemory;

/*!
 Gets the key that would be used to cache a URL response.
 
 @param URLString URL as a string
 */
- (NSString *)keyForURLString:(NSString *)URLString;

/*!
 Gets the path in the cache where a URL may be stored.
 
 @param URLString URL as a string
 */
- (NSString *)cachePathForURLString:(NSString *)URLString;

/*!
 Gets the path in the cache where a key may be stored.
 
 @param key Key
 */
- (NSString *)cachePathForKey:(NSString *)key;

/*!
 Etag cache files are stored in the following way:
 File name: <key>
 File data: <ETag value>
 
 @param key Key
 @result The ETag cache path for the given key.
 */
- (NSString *)ETagCachePathForKey:(NSString *)key;

/*!
 Determines if there is a cache entry for a URL.
 @param URLString
 */
- (BOOL)hasDataForURLString:(NSString *)URLString;

/*!
 Determines if there is a cache entry for a key.
 @param URLString
 @param expires
 @result YES if exists and not expired
 */
 - (BOOL)hasDataForURLString:(NSString *)URLString expires:(NSTimeInterval)expires;

/*!
 Determines if there is a cache entry for a key.
 @param key
 @param expires
 @result YES if exists and not expired
 */
- (BOOL)hasDataForKey:(NSString *)key expires:(NSTimeInterval)expires;

/*!
 Gets the data for a URL from the cache if it exists.
 
 @param URLString URL as a string
 @result nil if the URL is not cached.
 */
- (NSData *)dataForURLString:(NSString *)URLString;

/*!
 Gets the data for a URL from the cache if it exists and is newer than a minimum timestamp.
 
 @param URLString URL as a string
 @param expires How long until resource expires
 @param timestamp If not nil will be set to the timestamp of the data
 @result nil if the URL is not cached or if the cache entry is older than the minimum.
 */
- (NSData *)dataForURLString:(NSString *)URLString expires:(NSTimeInterval)expirationAge timestamp:(NSDate**)timestamp;

/*!
 Gets the data for a key from the cache if it exists and is newer than a minimum timestamp.
 
 @param key Key
 @param expires How long until resource expires
 @param timestamp If not nil will be set to the timestamp of the data
 @result nil if the URL is not cached or if the cache entry is older than the minimum.
 */
- (NSData *)dataForKey:(NSString *)key expires:(NSTimeInterval)expirationAge timestamp:(NSDate**)timestamp;

/*!
 Default dispatch queue for cache writes.
 */
+ (dispatch_queue_t)defaultWriteQueue;

/*!
 Default dispatch queue for cache reads.
 */
+ (dispatch_queue_t)defaultReadQueue;

/*!
 Get an ETag value for a given cache key.
 */
- (NSString *)ETagForKey:(NSString *)key;

/*!
 Stores a data on disk for URL string.
 @param data
 @param URLString
 @param asynchronous
 */
- (void)storeData:(NSData *)data forURLString:(NSString *)URLString asynchronous:(BOOL)asynchronous;

/*!
 Stores a data on disk for key.
 @param data
 @param URLString
 @param asynchronous
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key asynchronous:(BOOL)asynchronous;

/*!
 Stores an ETag value in the ETag cache.
 */
- (void)storeETag:(NSString *)ETag forKey:(NSString*)key asynchronous:(BOOL)asynchronous;

/*!
 Load data in dispatch queue.
 @param key
 @param dataBlock
 */
- (void)dataForKey:(NSString *)key dataBlock:(YKURLCacheDataBlock)dataBlock;

/*!
 Load data (for URL string) in dispatch queue.
 @param URLString
 @param dataBlock
 */
- (void)dataForURLString:(NSString *)URLString dataBlock:(YKURLCacheDataBlock)dataBlock;

/*!
 Soves the data currently stored under one URL to another URL.
 
 This is handy when you are caching data at a temporary URL while the permanent URL is being
 retrieved from a server.  Once you know the permanent URL you can use this to move the data.
 */
- (void)moveDataForURLString:(NSString *)oldURLString toURLString:(NSString *)newURLString;

- (void)moveDataFromPath:(NSString *)path toURLString:(NSString *)newURLString;

/*!
 Removes the data for a URL from the disk cache.
 */
- (void)removeURLString:(NSString *)URLString;

- (void)removeKey:(NSString *)key;

/*!
 Erases the disk cache.  This method is blocking and not thread safe.
 */
- (void)removeAll;

/*!
 Invalidates the file in the disk cache so that its modified timestamp is the current
 time minus the default cache expiration age.
 
 This ensures that the next time the URL is requested from the cache it will be loaded
 from the network if the default cache expiration age is used.
 */
- (void)invalidateURLString:(NSString *)URL;

- (void)invalidateKey:(NSString *)key;

/*!
 Invalidates all files in the disk cache according to rules explained in `invalidateURL`.
 */
- (void)invalidateAll;

#pragma mark Image Disk Cache

- (UIImage *)diskCachedImageForURLString:(NSString *)URLString expires:(NSTimeInterval)expires;

@end