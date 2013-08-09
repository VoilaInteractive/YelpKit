//
//  YKNSURLCache.m
//  YelpKit
//
//  Created by Allen Cheung on 8/9/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
//

#import "YKNSURLCache.h"

static NSMutableDictionary *gCacheNamespaceInvalidationDates = nil;

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
    <li>Disk path: <nobr>(user home directory)/Library/Caches/(current application name)</nobr>
    <br>where:
    <br>user home directory is determined by calling
    <tt>NSHomeDirectory()</tt>
    <br>current application name is determined by calling
    <tt>[[NSProcessInfo processInfo] processName]</tt>
    </ul>
     */
    NSArray *cachePathComponents = @[NSHomeDirectory(), @"Library", @"Caches", [[NSProcessInfo processInfo] processName]
                                     ];
    YKNSURLCache *customCache = [[YKNSURLCache alloc] initWithMemoryCapacity:[NSURLCache sharedURLCache].memoryCapacity diskCapacity:[NSURLCache sharedURLCache].diskCapacity diskPath:[NSString pathWithComponents:cachePathComponents]];
    [NSURLCache setSharedURLCache:customCache];
  });
  
  NSAssert([[NSURLCache sharedURLCache] isKindOfClass:self], @"Using YKNSURLCache but the shared cache is the wrong class!");
  return (YKNSURLCache *)[NSURLCache sharedURLCache];
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request timestamp:(NSDate *)timestamp expirationInterval:(NSTimeInterval)expirationInterval nameSpace:(NSString *)nameSpace {
  if (!nameSpace) {
    nameSpace = (id)[NSNull null];
  }
  NSCachedURLResponse *formattedResponse = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data userInfo:@{@"YKNSCacheExpirationInterval": [NSNumber numberWithDouble:expirationInterval], @"YKNSCacheTimestamp": timestamp, @"YKNSCacheNamespace": nameSpace} storagePolicy:NSURLCacheStorageAllowed];
  [self storeCachedResponse:formattedResponse forRequest:request];
  [formattedResponse release];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request expirationInterval:(NSTimeInterval)expirationInterval expired:(BOOL *)expired invalidNameSpace:(BOOL *)invalidNameSpace purgeIfExpiredOrInvalid:(BOOL)purge {
  NSCachedURLResponse *cachedResponse = [self cachedResponseForRequest:request];
  // Don't assume that NSURLCache retains and autoreleases - this can get purged later
  [[cachedResponse retain] autorelease];
  
  if (cachedResponse) {
    // Determine if response expired - the expiration interval is different than the cached value or current date is after expiration date
    NSTimeInterval cachedExpirationInterval = [cachedResponse.userInfo[@"YKNSCacheExpirationInterval"] doubleValue];
    NSDate *expirationDate = [cachedResponse.userInfo[@"YKNSCacheTimestamp"] dateByAddingTimeInterval:cachedExpirationInterval];
    *expired = (cachedExpirationInterval != expirationInterval ||
                [expirationDate earlierDate:[NSDate date]] == expirationDate);
    
    // Determine if response namespace is invalid - if the namespace was invalidated after the response timestamp
    NSDate *nameSpaceInvalidationDate = gCacheNamespaceInvalidationDates[cachedResponse.userInfo[@"YKNSCacheNamespace"]];
    *invalidNameSpace = (nameSpaceInvalidationDate &&
                         [nameSpaceInvalidationDate laterDate:cachedResponse.userInfo[@"YKNSCacheTimestamp"]] == nameSpaceInvalidationDate);
    
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

- (void)invalidateCacheNameSpace:(NSString *)nameSpace WithDate:(NSDate *)date {
  gCacheNamespaceInvalidationDates[nameSpace] = date;
}

@end
