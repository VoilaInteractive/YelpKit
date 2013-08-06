//
//  NSObject+YKJSON.h
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

#import <Foundation/Foundation.h>
@class YKError;

/*!
 Methods for converting objects to/from different JSON representations.
 
 Objects that wish to return their own JSON representations (e.g. custom classes) should implement the selector (id)JSON and return the object that is their JSON representation (an NSDictionary, for example).
 */
@interface NSObject (YKJSON)

/*!
 Convert a JSON object representation (NSDictionary, NSArray, etc.) to a JSON string representation.
 */
- (NSString *)yk_JSONString;

/*!
 Same as (id)yk_JSON, except that it allows you to pass in an error and receive data about an error in conversion of the object provided to a different representation.
 @param error An error object that will be modified if there are errors in JSON conversion
 */
- (NSString *)yk_JSONString:(YKError **)error;

/*!
 Same as (id)yk_JSON, except that it will change the string written in conversion from an object representation to a string.
 @param error An error object that will be modified if there are errors in JSON conversion
 @param options Options for how NSJSONSerialization should write the JSON String. i.e. NSJSONWritingPrettyPrinted generates a string with newlines
 */
- (NSString *)yk_JSONString:(YKError **)error options:(NSJSONWritingOptions)options;

/*!
 Converts NSString and NSData to object representation (i.e. NSDictionary, NSArray)
 */

- (id)yk_JSONObject;

/*!
 Converts NSString and NSData to object representation (i.e. NSDictionary, NSArray)
 @param error An error object that will be modified if there are errors in conversion of the JSON object to a string
 */

- (id)yk_JSONObject:(YKError **)error;

/*!
 Converts NSString and NSData to object representation (i.e. NSDictionary, NSArray)
 @param error An error object that will be modified if there are errors in conversion of the JSON object to a string
 @param options NSJSONReadingOptions that are applied during conversion of the string or data to an object representation
 */

- (id)yk_JSONObject:(YKError **)error options:(NSJSONReadingOptions)options;

@end