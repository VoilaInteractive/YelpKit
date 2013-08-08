//
//  YKURLRequestTest.m
//  YelpKit
//
//  Created by Allen Cheung on 8/8/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
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
