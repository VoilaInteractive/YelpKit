//
//  NSDate+YKUtils.m
//  YelpKit
//
//  Created by Nader Akoury on 3/5/13.
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

#import "NSDate+YKUtils.h"

@implementation NSDate(YKUtils)

- (NSInteger)yk_dayDelta:(NSDate *)date {
  return [self yk_dayDelta:date timeZone:nil];
}

- (NSInteger)yk_dayDelta:(NSDate *)date timeZone:(NSTimeZone *)timeZone {
  NSCalendar *cal = [NSCalendar currentCalendar];
  NSUInteger flags = (NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit);
  NSDate *ourDate = [cal dateFromComponents:[self gh_dateComponentsFromFlags:flags timeZone:timeZone]];
  NSDate *theirDate = [cal dateFromComponents:[date gh_dateComponentsFromFlags:flags timeZone:timeZone]];
  
  return [[cal components:NSDayCalendarUnit fromDate:ourDate toDate:theirDate options:0] day];
}

- (BOOL)yk_isSameDay:(NSDate *)date {
  return [self yk_isSameDay:date timeZone:nil];
}

- (BOOL)yk_isSameDay:(NSDate *)date timeZone:(NSTimeZone *)timeZone{
  return [self yk_dayDelta:date timeZone:timeZone] == 0;
}

@end