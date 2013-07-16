//
//  YKJSONRequest.m
//  YelpKit
//
//  Created by Gabriel Handford on 5/1/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YKJSONRequest.h"
#import "YKJSON.h"

@implementation YKJSONRequest

- (id)objectForData:(NSData *)data error:(YKError **)error {
  return [YKJSON objectForData:data error:error];
}

- (YKHTTPError *)errorForHTTPStatus:(NSInteger)HTTPStatus data:(NSData *)data {
  return [[[YKHTTPJSONError alloc] initWithHTTPStatus:HTTPStatus data:data] autorelease];
}

@end

@implementation YKHTTPJSONError

@synthesize JSONDictionary=_JSONDictionary, errorId=_errorId;

- (id)initWithHTTPStatus:(NSInteger)HTTPStatus data:(NSData *)data {
  
  NSDictionary *JSONDictionary = [YKJSON JSONDictionaryForData:data];
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
