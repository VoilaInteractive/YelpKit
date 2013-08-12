//
//  YKURLRequestTest.m
//  YelpKit
//
//  Created by Allen Cheung on 8/8/13.
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

#import "YKURLRequestTest.h"
#import <GHUnitIOS/GHMockNSURLConnection.h>
#import <YelpKit/YKNSURLCache.h>

@implementation YKURLRequestTest

static const NSInteger length = 1;
static uint8_t bytes[length];

- (void)setUp {
  [super setUp];
  // Force YKNSURLCache to load its singleton - doing this lazily causes some weird insert behavior on the first usage - console log: ADDRESPONSE - ADDING TO MEMORY ONLY
  [YKNSURLCache sharedURLCache];
  // Keep a unique default URL for each test to avoid test pollution - there is some time delay for NSURLCache removing its contents for the remove all method
  static NSInteger uniquifier = 0;
  [YKURLRequest setConnectionClass:[GHMockNSURLConnection class]];
  _defaultURL = [[YKURL alloc] initWithURLString:[NSString stringWithFormat:@"http://fake.yelp.test/ykurlrequesttest/%d", uniquifier++]];
  _defaultDataResponse = [[NSData alloc] initWithBytes:bytes length:length];
  _defaultCacheKeyRequest = [[NSURLRequest alloc] initWithURL:[YKURLRequest URLToCacheFromURL:[_defaultURL NSURL]]];
}

- (void)tearDown {
  [_defaultURL release];
  [_defaultDataResponse release];
  [_defaultCacheKeyRequest release];
  [YKURLRequest setConnectionClass:[NSURLConnection class]]; // Reset connection class
  [[YKNSURLCache sharedURLCache] removeAllCachedResponses];
  [super tearDown];
}

- (void)testInCache {
  [self prepare];
  YKURLRequest *request = [[YKURLRequest alloc] init];
  [request setCacheEnabled:YES expiresAfter:10000];
  [request requestWithURL:_defaultURL headers:nil delegate:self
           finishSelector:@selector(requestDidFinish:)
             failSelector:@selector(request:failedWithError:)
           cancelSelector:@selector(requestDidCancel:)];
  [(GHMockNSURLConnection *)request.connection receiveData:_defaultDataResponse statusCode:200 MIMEType:@"text/json" afterDelay:0.1];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1];
  
  GHAssertFalse(request.cacheHit, @"Sanity check - there should not be a cache hit here, request URL: %@", request.URL.URLString);
  GHAssertTrue(request.inCache, @"The request is not marked as being in the cache, request URL: %@", request.URL.URLString);
  
  [request release];
}

- (void)testCacheHit {
  NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[_defaultURL NSURL] statusCode:200 HTTPVersion:nil headerFields:nil];
  NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:_defaultDataResponse];
  [[YKNSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:_defaultCacheKeyRequest timestamp:[NSDate date] expirationInterval:10000 nameSpace:nil];
  [cachedResponse release];
  
  [self prepare];
  YKURLRequest *request = [[YKURLRequest alloc] init];
  [request setCacheEnabled:YES expiresAfter:10000];
  [request requestWithURL:_defaultURL headers:nil delegate:self
           finishSelector:@selector(requestDidFinish:)
             failSelector:@selector(request:failedWithError:)
           cancelSelector:@selector(requestDidCancel:)];
  // Since this is a cache hit there shouldn't be any need to pass data along the mock connection
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:0.1];
  BOOL stale = NO;
  cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:_defaultCacheKeyRequest expirationInterval:10000 stale:&stale];
  
  GHAssertTrue(request.cacheHit, @"The request is not marked as hitting the cache");
  
  [response release];
  [request release];
}

#pragma mark YKURLRequestDelegate

- (void)requestDidFinish:(YKURLRequest *)request {
  [self notify:kGHUnitWaitStatusSuccess forSelector:NULL];
}

- (void)request:(YKURLRequest *)request failedWithError:(NSError *)error {
  GHFail(@"Mock request should not error");
}

- (void)requestDidCancel:(YKURLRequest *)request {
  GHFail(@"Mock request should not cancel");
}

@end
