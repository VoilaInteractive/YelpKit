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

@implementation YKURLRequestTest

static uint8_t bytes[300];

- (void)setUp {
  [super setUp];
  [YKURLRequest setConnectionClass:[GHMockNSURLConnection class]];
  _defaultURL = [[YKURL alloc] initWithURLString:@"http://fake.yelp.test"];
  _defaultDataResponse = [[NSData alloc] initWithBytes:bytes length:300];
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)tearDown {
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
  [_defaultURL release];
  [_defaultDataResponse release];
  [YKURLRequest setConnectionClass:[NSURLConnection class]]; // Reset connection class
  [super tearDown];
}

- (void)testCacheInCache {
  [self prepare];
  YKURLRequest *request = [[YKURLRequest alloc] init];
  [request setCacheEnabled:YES expiresAfter:10000];
  [request requestWithURL:_defaultURL headers:nil delegate:self
           finishSelector:@selector(requestDidFinish:)
             failSelector:@selector(request:failedWithError:)
           cancelSelector:@selector(requestDidCancel:)];
  [(GHMockNSURLConnection *)request.connection receiveData:_defaultDataResponse statusCode:200 MIMEType:@"text/json" afterDelay:0.1];
  [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1];
  
  GHAssertTrue(request.inCache, @"The request is not marked as being in the cache");
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
