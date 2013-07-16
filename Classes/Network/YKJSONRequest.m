//
//  YKJSONRequest.m
//  YelpKit
//
//  Created by Gabriel Handford on 5/1/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YKJSONRequest.h"

@implementation YKJSONRequest

- (id)objectForData:(NSData *)data error:(YKError **)error {
  Class JSONSerialization = NSClassFromString(@"NSJSONSerialization");
  if (!JSONSerialization) {
    [NSException raise:NSGenericException format:@"YKJSONRequest only supported for iOS SDK >= 5"];
    return nil;
  }

  NSError *JSONError = nil;
  id obj = [JSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
  if (!obj) {
    if (error) {
      *error = [YKError errorWithError:JSONError];
    }
    return nil;
  }
  return obj;
}

- (YKHTTPError *)errorForHTTPStatus:(NSInteger)HTTPStatus data:(NSData *)data {
  return [[[YKHTTPJSONError alloc] initWithHTTPStatus:HTTPStatus data:data] autorelease];
}

@end

@implementation YKHTTPJSONError

@synthesize JSONDictionary=_JSONDictionary, errorId=_errorId;

+ (NSDictionary *)JSONDictionaryForData:(NSData *)data {
  Class JSONSerialization = NSClassFromString(@"NSJSONSerialization");
  if (!JSONSerialization) {
    [NSException raise:NSGenericException format:@"YKHTTPJSONError only supported for iOS SDK >= 5"];
    return nil;
  }
  
  id JSONDictionary = [JSONSerialization JSONObjectWithData:data options:0 error:nil];
  if ([JSONDictionary isKindOfClass:[NSDictionary class]]) {
    NSDictionary *errorDict = [JSONDictionary gh_objectMaybeNilForKey:@"error"];
    if (errorDict) return errorDict;
  }
  return nil;
}

- (id)initWithHTTPStatus:(NSInteger)HTTPStatus data:(NSData *)data {
  
  NSDictionary *JSONDictionary = [YKHTTPJSONError JSONDictionaryForData:data];
  NSString *localizedDescription = [JSONDictionary gh_objectMaybeNilForKey:@"description"];
  
  if ((self = [super initWithHTTPStatus:HTTPStatus data:data localizedDescription:localizedDescription])) {
    _JSONDictionary = [JSONDictionary retain];
    _errorId = [[JSONDictionary gh_objectMaybeNilForKey:@"id"] retain];
  }
  return self;
}

- (void)dealloc {
  [_JSONDictionary release];
  [_errorId release];
  [super dealloc];
}

@end
