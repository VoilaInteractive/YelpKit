//
//  YKJSON.m
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

#import "YKJSON.h"
#import "YKError.h"

@implementation YKJSON

+ (NSString *)JSONFromObject:(id)obj options:(NSJSONWritingOptions)options encoding:(NSStringEncoding)encoding error:(YKError **)error {
  NSString *result = nil;
  @autoreleasepool {
      result = [[self _JSONFromObject:obj options:options encoding:encoding error:error] retain];
  }
  return [result autorelease];
}

+ (NSString *)_serialize:(id)obj options:(NSJSONWritingOptions)options error:(YKError **)error {
  NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:options error:error];
  return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

+ (NSString *)_JSONFromObject:(id)obj options:(NSJSONWritingOptions)options encoding:(NSStringEncoding)encoding error:(YKError **)error {
  return [self _serialize:[self _JSONObjectFromObject:obj] options:options error:error];
}

+ (id)_JSONObjectFromObject:(id)obj {
  // Given an object (obj) that may or may not be serializable, we will try and turn it into an object that is serializable.  Objects that respond to the JSON selector can return JSON representations of themselves.
 
 if ([NSJSONSerialization isValidJSONObject:obj]) {
   return obj;
 }
 if ([obj respondsToSelector:@selector(JSON)]) {
   obj = [obj JSON];
 }
 id newJSONSerializableParent = obj;
 BOOL isDictionary = NO;
 if ([obj isKindOfClass:[NSDictionary class]]) {
   isDictionary = YES;
   newJSONSerializableParent = [[NSMutableDictionary alloc] initWithCapacity:[obj count]];
 } else if ([obj isKindOfClass:[NSArray class]]) {
   newJSONSerializableParent = [[NSMutableArray alloc] init];
 }
 for (id key in obj) {
   id value = key;
   if (isDictionary) {
     value = [obj objectForKey:key];
   }
   if ([NSJSONSerialization isValidJSONObject:@[value]]) {
     if (isDictionary) {
       [newJSONSerializableParent setValue:value forKey:key];
     } else {
       [newJSONSerializableParent addObject:value];
     }
   } else if ([value respondsToSelector:@selector(JSON)]) {
     if (isDictionary) {
       [newJSONSerializableParent setValue:[self _JSONObjectFromObject:[value JSON]] forKey:key];
     } else {
       [newJSONSerializableParent addObject:[value JSON]];
     }
   } else {
     // We probably have a dictionary or array with objects that are unserializable or will respond to JSON method calls
     NSString *result = [self _JSONObjectFromObject:value];
     if (isDictionary) {
       [newJSONSerializableParent setValue:result forKey:key];
     } else {
       [newJSONSerializableParent addObject:result];
     }
   }
 }
 if (![NSJSONSerialization isValidJSONObject:newJSONSerializableParent]) {
   [NSException raise:NSInvalidArgumentException format:@"YKJSON cannot serialize the object of class %@", NSStringFromClass([newJSONSerializableParent class])];
   return nil;
 }
 return [newJSONSerializableParent autorelease];

}

+ (id)objectForData:(NSData *)data error:(YKError **)error {
  NSError *JSONError = nil;
  id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
  if (!obj) {
    if (error) {
      *error = [YKError errorWithError:JSONError];
    }
    return nil;
  }
  return obj;
}

+ (id)objectForString:(NSString *)string error:(YKError **)error {
  return [self objectForData:[string dataUsingEncoding:NSUTF8StringEncoding] error:error];
}

+ (NSDictionary *)JSONDictionaryForData:(NSData *)data {
  id JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  if ([JSONDictionary isKindOfClass:[NSDictionary class]]) {
    NSDictionary *errorDict = [JSONDictionary gh_objectMaybeNilForKey:@"error"];
    if (errorDict) return errorDict;
  }
  return nil;
}

+ (NSDictionary *)JSONDictionaryForString:(NSString *)string {
  return [self JSONDictionaryForData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
