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

static const NSInteger length = 1;
static uint8_t bytes[length];


@interface YKNSURLCacheTest : GHTestCase {
  YKURL *_defaultURL;
  NSData *_defaultDataResponse;
  NSCachedURLResponse *_defaultCachedResponse;
  NSURLRequest *_defaultCacheKeyRequest;
}
@end


@implementation YKNSURLCacheTest

- (void)setUp {
  [super setUp];
  // Force YKNSURLCache to load its singleton - doing this lazily causes some weird insert behavior on the first usage - console log: ADDRESPONSE - ADDING TO MEMORY ONLY
  [YKNSURLCache sharedURLCache];
  // Keep a unique default URL for each test to avoid test pollution - there is some time delay for NSURLCache removing its contents for the remove all method
  static NSInteger uniquifier = 0;
  _defaultURL = [[YKURL alloc] initWithURLString:[NSString stringWithFormat:@"http://fake.yelp.test/yknsurlcachetest/%d", uniquifier++]];
  _defaultDataResponse = [[NSData alloc] initWithBytes:bytes length:length];
  NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[_defaultURL NSURL] statusCode:200 HTTPVersion:nil headerFields:nil];
  _defaultCachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:_defaultDataResponse];
  [response release];
  _defaultCacheKeyRequest = [[NSURLRequest alloc] initWithURL:[_defaultURL NSURL]];
}

- (void)tearDown {
  [_defaultURL release];
  [_defaultDataResponse release];
  [_defaultCachedResponse release];
  [_defaultCacheKeyRequest release];
  [[YKNSURLCache sharedURLCache] removeAllCachedResponses];
  [super tearDown];
}

- (void)testInCache {
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:_defaultCacheKeyRequest timestamp:[NSDate date] expirationInterval:10000 nameSpace:nil];
  
  BOOL stale = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 stale:&stale];
  
  for (int i = 0; i < 100; ++i) {
    if (cachedResponse) break;
    usleep(1000);
    cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 stale:&stale];
  }
  
  GHAssertTrue(!!cachedResponse, @"Cached response should be in cache");
  GHAssertEqualObjects(cachedResponse.data, _defaultCachedResponse.data, @"Cached response data for request changed");
  GHAssertFalse(stale, @"Cache response should not be stale");
}

- (void)testRemoveFromCache {
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:_defaultCacheKeyRequest timestamp:[NSDate date] expirationInterval:10000 nameSpace:nil];
  
  BOOL stale = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!!cachedResponse, @"Cached response should be in cache");

  [[YKNSURLCache sharedURLCache] removeCachedResponseForRequest:_defaultCacheKeyRequest];
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!cachedResponse, @"After removal, cached response should not be in cache");
}

- (void)testCacheMiss {
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:_defaultCacheKeyRequest timestamp:[NSDate date] expirationInterval:10000 nameSpace:nil];
  
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[_defaultURL.URLString stringByAppendingFormat:@"a"]] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:0];
  BOOL stale = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!cachedResponse, @"Cache should not hit for modified URL");
}

- (void)testCacheExpiration {
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:_defaultCacheKeyRequest timestamp:[NSDate dateWithTimeIntervalSinceNow:-10001] expirationInterval:10000 nameSpace:nil];
  
  BOOL expired = NO;
  BOOL invalid = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 expired:&expired invalidNameSpace:&invalid purgeIfExpiredOrInvalid:NO];
  
  GHAssertTrue(expired, @"Cached response should have expired");
  GHAssertTrue(!!cachedResponse, @"Expired cache hits should still return the cached response");
  
  BOOL stale = NO;
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(stale, @"Cached response should have expired and stale should be true");

  // Test that the cached response has been purged
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(!cachedResponse, @"Cache response should have been purged during previous hit");
}

- (void)testCacheExpirationIntervalChanged {
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:_defaultCacheKeyRequest timestamp:[NSDate date] expirationInterval:10000 nameSpace:nil];
  
  BOOL expired = NO;
  BOOL invalid = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:200 expired:&expired invalidNameSpace:&invalid purgeIfExpiredOrInvalid:NO];
  
  GHAssertTrue(expired, @"Cached response should have expired due to changed expiration interval");
  
  BOOL stale = NO;
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:200 stale:&stale];
  
  GHAssertTrue(stale, @"Cached response should have expired and stale should be true");
}

- (void)testCacheInvalidNameSpace {
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:_defaultCacheKeyRequest timestamp:[NSDate date] expirationInterval:10000 nameSpace:@"Foo"];
  
  [[YKNSURLCache sharedURLCache] invalidateCacheNameSpace:@"Foo" withDate:[NSDate date]];
  
  BOOL expired = NO;
  BOOL invalid = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 expired:&expired invalidNameSpace:&invalid purgeIfExpiredOrInvalid:NO];
  
  GHAssertTrue(invalid, @"Cached response should be invalid");
  
  BOOL stale = NO;
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(stale, @"Cached response should be invalid and stale should be true");
}

- (void)testCacheInsertAfterInvalidatingNameSpace {
  [[YKNSURLCache sharedURLCache] invalidateCacheNameSpace:@"Foo" withDate:[NSDate dateWithTimeIntervalSinceNow:-1]];
  
  [[YKNSURLCache sharedURLCache] storeCachedResponse:_defaultCachedResponse forRequest:_defaultCacheKeyRequest timestamp:[NSDate date] expirationInterval:10000 nameSpace:@"Foo"];
  
  BOOL stale = NO;
  NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 stale:&stale];
  
  GHAssertFalse(stale, @"Cache response should not be stale since the response timestamp is after invalidating the namespace");
  GHAssertTrue(!!cachedResponse, @"Cached response should be in cache");
}

@end
