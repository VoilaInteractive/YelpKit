//
//  YKJSONTest.m
//  YelpKit
//
//  Created by Alexander Haefner on 7/16/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
//

#import "YKJSONTest.h"
#import "NSObject+YKJSON.h"

@interface YKJSONTestSerializeable : NSObject
{
  NSString *_identifier;
}

- (id)initWithIdentifier:(NSString *)identifier;
@end

@implementation YKJSONTestSerializeable

- (id)initWithIdentifier:(NSString *)identifier {
  if ((self = [super init])) {
    _identifier = [identifier copy];
  }
  return self;
}

- (id)JSON {
  return @{[NSString stringWithFormat:@"SerializedKey%@", _identifier]: @"SerializedValue"};
}

@end

@implementation YKJSONTest

- (void)setUp {
  _testArrayOne = @[@"one", @"two", @"three", @"four"];
  _testMutableArrayOne = [[NSMutableArray alloc] initWithObjects:@"one", @"two", @"three", @"four", nil];
  _testDictOne = @{@"keyOne": @"valueOne", @"keyTwo": @"valueTwo"};
  _testMutableDictionaryOne = [[NSMutableDictionary alloc] initWithObjects:@[@"valueOne", @"valueTwo"] forKeys:@[@"keyOne", @"keyTwo"]];
}

- (void)testDictionaryEqual {
  NSString *dictOne = [_testDictOne yk_JSON];
  NSString *dictTwo = [_testMutableDictionaryOne yk_JSON];
  GHAssertEqualStrings(dictOne, dictTwo, @"Serialized Dicts are not equal");
}

- (void)testArrayEqual {
  NSString *arrayOne = [_testArrayOne yk_JSON];
  NSString *arrayTwo = [_testMutableArrayOne yk_JSON];
  GHAssertEqualStrings(arrayOne, arrayTwo, @"Serialized Arrays are not equal");
}

- (void)testArrayOfSerializeableCustomObjects {
  YKJSONTestSerializeable *serializeableObjectOne = [[YKJSONTestSerializeable alloc] initWithIdentifier:@"1"];
  YKJSONTestSerializeable *serializeableObjectTwo = [[YKJSONTestSerializeable alloc] initWithIdentifier:@"2"];
  NSArray *arrayOne = @[serializeableObjectOne, serializeableObjectTwo];
  NSArray *arrayTwo = @[@{@"SerializedKey1": @"SerializedValue"}, @{@"SerializedKey2": @"SerializedValue"}];
  GHAssertEqualStrings([arrayOne yk_JSON], [arrayTwo yk_JSON], @"Custom object serialization is not equal to the raw array");
  [serializeableObjectOne release];
  [serializeableObjectTwo release];
}

- (void)testDictionaryWithArrayOfCustomObjects {
  YKJSONTestSerializeable *serializeableObjectOne = [[YKJSONTestSerializeable alloc] initWithIdentifier:@"3"];
  YKJSONTestSerializeable *serializeableObjectTwo = [[YKJSONTestSerializeable alloc] initWithIdentifier:@"4"];
  NSDictionary *dictOne = @{@"keyOne": @"value1", @"keyTwo": @[serializeableObjectOne, serializeableObjectTwo]};
  NSDictionary *dictTwo = @{@"keyOne": @"value1", @"keyTwo": @[@{@"SerializedKey3": @"SerializedValue"}, @{@"SerializedKey4": @"SerializedValue"}]};
  NSString *dictOneString = [dictOne yk_JSON];
  NSString *dictTwoString = [dictTwo yk_JSON];
  GHAssertEqualStrings(dictOneString, dictTwoString, @"Serialization Problem: The dicts with arraays of custom objects are not equal to the raw dict with arrays of literals");
  [serializeableObjectOne release];
  [serializeableObjectTwo release];
}

- (void)testArrayWithDictionaryOfCustomObjects {
  YKJSONTestSerializeable *serializeableObjectOne = [[YKJSONTestSerializeable alloc] initWithIdentifier:@"5"];
  YKJSONTestSerializeable *serializeableObjectTwo = [[YKJSONTestSerializeable alloc] initWithIdentifier:@"6"];
  NSArray *arrayOne = @[@{@"keyOne": serializeableObjectTwo, @"keyTwo": serializeableObjectOne}];
  NSArray *arrayTwo = @[@{@"keyOne": @{@"SerializedKey6": @"SerializedValue"}, @"keyTwo": @{@"SerializedKey5": @"SerializedValue"}}];
  NSString *arrayOneString = [arrayOne yk_JSON];
  NSString *arrayTwoString = [arrayTwo yk_JSON];
  GHAssertEqualStrings(arrayOneString, arrayTwoString, @"Serialization Problem: The arrays iwth dicts of custom objects are not equal to the raw dict with arrays of literals");
  [serializeableObjectOne release];
  [serializeableObjectTwo release];
}

- (void)testComments {
  NSDictionary *dictOne = @{@"Key": @"value"};
  NSString *result = [dictOne yk_JSON];
  result = [[NSString alloc] initWithFormat:@"%@ //hi", result];
  YKError *error = nil;
  NSDictionary *dictTwo = [result yk_JSON:&error options:NSJSONWritingPrettyPrinted];
  GHAssertNil(dictTwo, @"Somehow NSJSONSerialization parsed a comment");
  GHAssertNotNil(dictOne, @"NSJSONSerialization failed to parse dictOne");
  [result release];
}

@end
