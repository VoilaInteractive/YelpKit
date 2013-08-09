//
//  YKNSURLCacheTest.m
//  YelpKit
//
//  Created by Allen Cheung on 8/9/13.
//  Copyright 2013 Yelp. All rights reserved.
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


#import <YelpKit/YKNSURLCache.h>

static uint8_t bytes[300];


@interface YKNSURLCacheTest : GHTestCase {
  YKURL *_defaultURL;
  NSData *_defaultDataResponse;
  NSCachedURLResponse *_defaultCachedResponse;
}
@end


@implementation YKNSURLCacheTest

- (void)setUp {
  [super setUp];
  // Keep a unique default URL for each test to avoid test pollution - there is some time delay for NSURLCache removing its contents for the remove all method
  static NSInteger uniquifier = 0;
  _defaultURL = [[YKURL alloc] initWithURLString:[NSString stringWithFormat:@"http://fake.yelp.test/%d", uniquifier++]];
  _defaultDataResponse = [[NSData alloc] initWithBytes:bytes length:300];
  NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[_defaultURL NSURL] statusCode:200 HTTPVersion:nil headerFields:nil];
  _defaultCachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:_defaultDataResponse];
  [response release];
  [[YKNSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)tearDown {
  [_defaultURL release];
  [_defaultDataResponse release];
  [_defaultCachedResponse release];
  [[YKNSURLCache sharedURLCache] removeAllCachedResponses];
  [super tearDown];
}

- (void)testInCache {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[_defaultURL NSURL] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:0];
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:request timestamp:[NSDate date] expirationInterval:10000 nameSpace:nil];
  
  BOOL stale = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!!cachedResponse, @"Cached response should be in cache");
  GHAssertEqualObjects(cachedResponse.data, _defaultCachedResponse.data, @"Cached response data for request changed");
  GHAssertFalse(stale, @"Cache response should not be stale");
}

- (void)testRemoveFromCache {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[_defaultURL NSURL] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:0];
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:request timestamp:[NSDate date] expirationInterval:10000 nameSpace:nil];
  
  BOOL stale = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!!cachedResponse, @"Cached response should be in cache");

  [[YKNSURLCache sharedURLCache] removeCachedResponseForRequest:request];
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!cachedResponse, @"After removal, cached response should not be in cache");
}

- (void)testCacheMiss {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[_defaultURL NSURL] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:0];
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:request timestamp:[NSDate date] expirationInterval:10000 nameSpace:nil];
  
  request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[_defaultURL.URLString stringByAppendingFormat:@"a"]] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:0];
  BOOL stale = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!cachedResponse, @"Cache should not hit for modified URL");
}

- (void)testCacheExpiration {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[_defaultURL NSURL] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:0];
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:request timestamp:[NSDate dateWithTimeIntervalSinceNow:-10001] expirationInterval:10000 nameSpace:nil];
  
  BOOL expired = NO;
  BOOL invalid = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 expired:&expired invalidNameSpace:&invalid purgeIfExpiredOrInvalid:NO];
  
  GHAssertTrue(!!cachedResponse, @"Expired cache hits should still return the cached response");
  GHAssertTrue(expired, @"Cached response should have expired");
  
  BOOL stale = NO;
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(stale, @"Cached response should have expired and stale should be true");

  // Test that the cached response has been purged
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!cachedResponse, @"Cache response should have been purged during previous hit");
}

- (void)testCacheExpirationIntervalChanged {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[_defaultURL NSURL] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:0];
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:request timestamp:[NSDate date] expirationInterval:10000 nameSpace:nil];
  
  BOOL expired = NO;
  BOOL invalid = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:200 expired:&expired invalidNameSpace:&invalid purgeIfExpiredOrInvalid:NO];
  
  GHAssertTrue(expired, @"Cached response should have expired due to changed expiration interval");
  
  BOOL stale = NO;
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:200 stale:&stale];
  
  GHAssertTrue(stale, @"Cached response should have expired and stale should be true");
}

- (void)testCacheExpirationInvalidNameSpace {
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[_defaultURL NSURL] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:0];
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:request timestamp:[NSDate date] expirationInterval:10000 nameSpace:@"Foo"];
  
  [[YKNSURLCache sharedURLCache] invalidateCacheNameSpace:@"Foo" WithDate:[NSDate date]];
  
  BOOL expired = NO;
  BOOL invalid = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 expired:&expired invalidNameSpace:&invalid purgeIfExpiredOrInvalid:NO];
  
  GHAssertTrue(invalid, @"Cached response should be invalid");
  
  BOOL stale = NO;
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(stale, @"Cached response should be invalid and stale should be true");
}

- (void)testCacheInsertAfterInvalidatingNameSpace {
  [[YKNSURLCache sharedURLCache] invalidateCacheNameSpace:@"Foo" WithDate:[NSDate dateWithTimeIntervalSinceNow:-1]];
  
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[_defaultURL NSURL] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:0];
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:request timestamp:[NSDate date] expirationInterval:10000 nameSpace:@"Foo"];
  
  BOOL stale = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!!cachedResponse, @"Cached response should be in cache");
  GHAssertFalse(stale, @"Cache response should not be stale since the response timestamp is after invalidating the namespace");
}

@end
