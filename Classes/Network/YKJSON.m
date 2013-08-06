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

+ (NSString *)stringFromObject:(id)obj options:(NSJSONWritingOptions)options encoding:(NSStringEncoding)encoding error:(YKError **)error {
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
  // Given an object (obj) that may or may not be serializable, we will try and turn it into an object that is serializable.  Objects that implement YKJSONSerializableObject protocl can return JSON representations of themselves.
 
 if ([NSJSONSerialization isValidJSONObject:obj]) {
   return obj;
 }
 if ([obj conformsToProtocol:@protocol(YKJSONSerializableObject)]) {
   obj = [obj JSONSerializableObject];
   if ([NSJSONSerialization isValidJSONObject:obj]) {
     return obj;
   }
 }
 id newJSONSerializableParent = obj;
 BOOL isDictionary = NO;
 if ([obj isKindOfClass:[NSDictionary class]]) {
   isDictionary = YES;
   newJSONSerializableParent = [[NSMutableDictionary alloc] initWithCapacity:[obj count]];
 } else if ([obj isKindOfClass:[NSArray class]]) {
   newJSONSerializableParent = [[NSMutableArray alloc] initWithCapacity:[obj count]];
 } else {
   [NSException raise:NSInvalidArgumentException format:@"YKJSON cannot serialize the object of class %@", NSStringFromClass([newJSONSerializableParent class])];
 }
 for (id key in obj) {
   if (isDictionary) {
     // NSMutableDictionary
     id value = [obj objectForKey:key];
     if (![NSJSONSerialization isValidJSONObject:@[key]]) {
     // Although perhaps uncommon for dictionaries, keys could be custom objects
      key = [self _JSONObjectFromObject:key];
     }
     if ([NSJSONSerialization isValidJSONObject:@[value]]) {
       [newJSONSerializableParent setValue:value forKey:key];
     } else {
       [newJSONSerializableParent setValue:[self _JSONObjectFromObject:value] forKey:key];
     }
   } else {
     id value = key;
     // NSMutableArray
     if ([NSJSONSerialization isValidJSONObject:@[value]]) {
       [newJSONSerializableParent addObject:value];
     } else {
       // We need to try custom serialization of value
       [newJSONSerializableParent addObject:[self _JSONObjectFromObject:value]];
     }
   }
 }
 if (![NSJSONSerialization isValidJSONObject:newJSONSerializableParent]) {
   [NSException raise:NSInvalidArgumentException format:@"YKJSON cannot serialize the object of class %@", NSStringFromClass([newJSONSerializableParent class])];
   return nil;
 }
 return [newJSONSerializableParent autorelease];

}

+ (id)objectForData:(NSData *)data error:(YKError **)error options:(NSJSONReadingOptions)options {
  NSError *JSONError = nil;
  id obj = [NSJSONSerialization JSONObjectWithData:data options:options error:&JSONError];
  if (!obj) {
    if (error) {
      *error = [YKError errorWithError:JSONError];
    }
    return nil;
  }
  return obj;
}

+ (id)objectForString:(NSString *)string error:(YKError **)error options:(NSJSONReadingOptions)options {
  return [self objectForData:[string dataUsingEncoding:NSUTF8StringEncoding] error:error options:options];
}

+ (NSDictionary *)dictionaryForData:(NSData *)data {
  id JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  if ([JSONDictionary isKindOfClass:[NSDictionary class]]) {
    NSDictionary *errorDict = [JSONDictionary gh_objectMaybeNilForKey:@"error"];
    if (errorDict) return errorDict;
  }
  return nil;
}

+ (NSDictionary *)dictionaryForString:(NSString *)string {
  return [self dictionaryForData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end