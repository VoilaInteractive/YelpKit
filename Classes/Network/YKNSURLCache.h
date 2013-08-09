//
//  YKNSURLCache.h
//  YelpKit
//
//  Created by Allen Cheung on 8/9/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
//

/*!
 Wrapper around NSURLCache that supports custom timestamping and expiration as well as
 defining namespaces for requests and invalidating namespaces.
 */

@interface YKNSURLCache : NSURLCache

+ (YKNSURLCache *)sharedURLCache;

/*!
 Wraps around storeCachedResponse:forRequest:  Stores an identical cached response 
 but adds timestamp and expiration date information to the user dictionary, for 
 custom caching behavior.
 
 @param cachedResponse The cached response to store
 @param request The URL request against which to save the cached response.  The client may pass a custom URL request for different caching behavior than.
 @param timestamp The cache entry timestamp date
 @param expirationInterval The cache entry expiration interval in seconds since the timestamp
 @param nameSpace Optional namespace to associate request with.  Pass nil if no namespace.
 */
- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request timestamp:(NSDate *)timestamp expirationInterval:(NSTimeInterval)expirationInterval nameSpace:(NSString *)nameSpace;

/*!
 Wraps around cachedResponseForRequest:  Returns the cached response for a given request,
 however also returns by reference whether the request is expired and whether the 
 namespace (if any) is invalid.  
 
 Note: The request is considered expired if its expiration interval is different than the
 value stored in the cached response user info dictionary.
 
 @param request The request to lookup the cached response
 @param expirationInterval The expiration interval for the request
 @param expired Flag returned by reference if the response has expired
 @param invalidnameSpace Flag returned by reference if the response namespace has been invalidated
 @param purgeIfExpiredOrInvalid If set to YES, then any expired or invalid responses are removed from the cache.
 */
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request expirationInterval:(NSTimeInterval)expirationInterval expired:(BOOL *)expired invalidNameSpace:(BOOL *)invalidNameSpace purgeIfExpiredOrInvalid:(BOOL)purge;

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request expirationInterval:(NSTimeInterval)expirationInterval expired:(BOOL *)expired invalidNameSpace:(BOOL *)invalidNameSpace;

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request expirationInterval:(NSTimeInterval)expirationInterval stale:(BOOL *)stale;

- (void)invalidateCacheNameSpace:(NSString *)nameSpace WithDate:(NSDate *)date;

@end
