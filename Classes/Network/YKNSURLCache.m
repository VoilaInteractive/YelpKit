//
//  YKNSURLCache.m
//  YelpKit
//
//  Created by Allen Cheung on 8/9/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
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

#import "YKNSURLCache.h"
#import "YKDefines.h"

static NSMutableDictionary *gCacheNamespaceInvalidationDates = nil;

static NSString *const YKNSCacheExpirationInterval = @"YKNSCacheExpirationInterval";
static NSString *const YKNSCacheNameSpace = @"YKNSCacheNameSpace";
static NSString *const YKNSCacheTimestamp = @"YKNSCacheTimestamp";


@implementation YKNSURLCache

+ (void)initialize {
  if (self == [YKNSURLCache class]) {
    gCacheNamespaceInvalidationDates = [[NSMutableDictionary alloc] init];
  }
}

+ (YKNSURLCache *)sharedURLCache {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    /*
     From the Apple docs the disk path for the default cache is as follows:  It's stupid that
     this isn't a read-only property on the cache, but we need to construct it here.
     
    <li>Disk path: <nobr>(user home directory)/Library/Caches/(current application name)</nobr>
    <br>where:
    <br>user home directory is determined by calling
    <tt>NSHomeDirectory()</tt>
    <br>current application name is determined by calling
    <tt>[[NSProcessInfo processInfo] processName]</tt>
    </ul>
     */
    NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    YKNSURLCache *customCache = [[YKNSURLCache alloc] initWithMemoryCapacity:1000 diskCapacity:[NSURLCache sharedURLCache].diskCapacity diskPath:[cacheDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]]];
    [NSURLCache setSharedURLCache:customCache];
    [customCache release];
  });
  
  YKAssert([[NSURLCache sharedURLCache] isKindOfClass:self], @"Using YKNSURLCache but the shared cache is the wrong class!");
  return (YKNSURLCache *)[NSURLCache sharedURLCache];
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request timestamp:(NSDate *)timestamp expirationInterval:(NSTimeInterval)expirationInterval nameSpace:(NSString *)nameSpace {
  if (!nameSpace) {
    nameSpace = (id)[NSNull null];
  }
  NSCachedURLResponse *formattedResponse = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data userInfo:@{YKNSCacheExpirationInterval: @(expirationInterval), YKNSCacheTimestamp: timestamp, YKNSCacheNameSpace: nameSpace} storagePolicy:NSURLCacheStorageAllowed];
  [self storeCachedResponse:formattedResponse forRequest:request];
  [formattedResponse release];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request expirationInterval:(NSTimeInterval)expirationInterval expired:(BOOL *)expired invalidNameSpace:(BOOL *)invalidNameSpace purgeIfExpiredOrInvalid:(BOOL)purge {
  NSCachedURLResponse *cachedResponse = [self cachedResponseForRequest:request];
  // Don't assume that NSURLCache retains and autoreleases - this can get purged later
  [[cachedResponse retain] autorelease];
  
  if (cachedResponse) {
    // Determine if response expired - the expiration interval is different than the cached value or current date is after expiration date
    NSTimeInterval cachedExpirationInterval = [cachedResponse.userInfo[YKNSCacheExpirationInterval] doubleValue];
    NSDate *expirationDate = [cachedResponse.userInfo[YKNSCacheTimestamp] dateByAddingTimeInterval:cachedExpirationInterval];
    *expired = (cachedExpirationInterval != expirationInterval ||
                [expirationDate earlierDate:[NSDate date]] == expirationDate);
    
    // Determine if response namespace is invalid - if the namespace was invalidated after the response timestamp
    NSDate *nameSpaceInvalidationDate = gCacheNamespaceInvalidationDates[cachedResponse.userInfo[YKNSCacheNameSpace]];
    *invalidNameSpace = (nameSpaceInvalidationDate &&
                         [nameSpaceInvalidationDate laterDate:cachedResponse.userInfo[YKNSCacheTimestamp]] == nameSpaceInvalidationDate);
    
    if (purge && (*expired || *invalidNameSpace)) {
      [self removeCachedResponseForRequest:request];
    }
  }
  
  return cachedResponse;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request expirationInterval:(NSTimeInterval)expirationInterval expired:(BOOL *)expired invalidNameSpace:(BOOL *)invalidNameSpace {
  return [self cachedResponseForRequest:request expirationInterval:expirationInterval expired:expired invalidNameSpace:invalidNameSpace purgeIfExpiredOrInvalid:YES];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request expirationInterval:(NSTimeInterval)expirationInterval stale:(BOOL *)stale {
  BOOL expired = NO;
  BOOL invalid = NO;
  NSCachedURLResponse *response = [self cachedResponseForRequest:request expirationInterval:expirationInterval expired:&expired invalidNameSpace:&invalid purgeIfExpiredOrInvalid:YES];
  *stale = expired || invalid;
  return response;
}

- (void)invalidateCacheNameSpace:(NSString *)nameSpace withDate:(NSDate *)date {
  gCacheNamespaceInvalidationDates[nameSpace] = date;
}

@end
