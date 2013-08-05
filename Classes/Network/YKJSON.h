//
//  YKJSON.h
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

@protocol YKJSONSerializable <NSObject>
- (id)JSON;
@end

/*!
 A class that wraps NSJSONSerialization and makes conversion of objects between different JSON representations straightforward.  Objects that wish to control their own JSON representation that is returned when they are parsed by YKJSON should implement the (id)JSON selector and return an object representation (e.g. NSDictionary) that represents their JSON structure.
 */
@interface YKJSON : NSObject {}

/*!
 @param obj The object to be serialized
 @param options Writing options for the string output styling
 @param encoding String output styling.  NOTE: NSJSONSerialization internally stores data as UTF8 string representation
 
 Note that some objects may not be able to be serialized.  Custom objects that want to be serialized should implement the (id)JSON selector and return an object representation of themselves, which YKJSON will serialize
 
 @result JSON NSString representation of obj
 */
+ (NSString *)stringFromObject:(id)obj options:(NSJSONWritingOptions)options encoding:(NSStringEncoding)encoding error:(YKError **)error;

/*!
 @param data The NSData to be converted to an object representation.  e.g. NSData from a YKURLRequest
 @param error Error that will be modified if there is a problem parsing data
 @param options NSJSONReading options when reading the json data
 
 @result An object representation of NSData's JSON contents
 */
+ (id)objectForData:(NSData *)data error:(YKError **)error options:(NSJSONReadingOptions)options;

/*!
 @param data The NSData to be converted to an object representation.  e.g. NSData from a YKURLRequest
 @param error Error that will be modified if there is a problem parsing data
 @param options NSJSONReading options when reading the json data
 
 @result An object representation of NSData's JSON contents
 */
+ (id)objectForString:(NSString *)string error:(YKError **)error options:(NSJSONReadingOptions)options;

/*!
@param data The NSData to be converted to an NSDictionary

@result An object representation of NSData's JSON contents, or a dictionary containing the error
*/
+ (NSDictionary *)dictionaryForData:(NSData *)data;

/*!
 @param data The NSString to be converted to an NSDictionary
 
 @result An object representation of NSString's JSON contents, or a dictionary containing the error
 */
+ (NSDictionary *)dictionaryForString:(NSData *)data;

@end
