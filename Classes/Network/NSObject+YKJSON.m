//
//  NSObject+YKJSON.m
//  YelpKit
//
//  Created by Alexander Haefner on 7/15/13.
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

#import "NSObject+YKJSON.h"
#import "YKJSON.h"

@implementation NSObject (YKJSON)

- (id)yk_JSONString {
  return [self yk_JSONString:nil];
}

- (id)yk_JSONString:(YKError **)error {
  return [self yk_JSONString:error options:0];
}

- (id)yk_JSONString:(YKError **)error options:(NSJSONWritingOptions)options {
  if ([self isKindOfClass:[NSData class]] || [self isKindOfClass:[NSString class]]) {
    return nil;
  }
  return [YKJSON stringFromObject:self options:options encoding:NSUTF8StringEncoding error:error];
}

- (id)yk_JSONObject {
  return [self yk_JSONObject:nil];
}

- (id)yk_JSONObject:(YKError **)error {
  return [self yk_JSONObject:error options:0];
}

- (id)yk_JSONObject:(YKError **)error options:(NSJSONReadingOptions)options {
  if (([self isKindOfClass:[NSData class]])) {
    return [YKJSON objectForData:(NSData*)self error:error options:options];
  } else if ([self isKindOfClass:[NSString class]]) {
    return [YKJSON objectForString:(NSString *)self error:error options:options];
  } else {
    return nil;
  }
}

@end