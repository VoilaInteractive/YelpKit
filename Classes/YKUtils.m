//
//  YKUtils.m
//  YelpKit
//
//  Created by Gabriel Handford on 12/11/09.
//  Copyright 2009 Yelp. All rights reserved.
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

#import "YKUtils.h"
#import <mach/mach.h>
#import "YKDefines.h"

id YKRandomChoice(id object, ...) {
  GHConvertVarArgs(object);
  return YKRandomChoiceFromArray(arguments);
}

id YKRandomChoiceFromArray(NSArray *array) {
  srand(time(0));
  int index = arc4random() % [array count];
  return array[index];
}

static const void *YKRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void YKReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray *YKCreateNonRetainingArray(void) {
  CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
  callbacks.retain = YKRetainNoOp;
  callbacks.release = YKReleaseNoOp;
  return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

NSMutableSet *YKCreateNonRetainingSet(void) {
  CFSetCallBacks callbacks = kCFTypeSetCallBacks;
  callbacks.retain = YKRetainNoOp;
  callbacks.release = YKReleaseNoOp;
  return (NSMutableSet*)CFSetCreateMutable(nil, 0, &callbacks);
}

// Based on code snippet from http://stackoverflow.com/questions/787160/programmatically-retrieve-memory-usage-on-iphone
NSUInteger YKReportMemory(void) {
  struct task_basic_info info;
  mach_msg_type_number_t size = sizeof(info);
  kern_return_t kerr = task_info(mach_task_self(),
                                 TASK_BASIC_INFO,
                                 (task_info_t)&info,
                                 &size);
  if (kerr == KERN_SUCCESS) {
    YKDebug(@"Memory in use (in bytes): %u", info.resident_size);
    return info.resident_size;
  } else {
    YKDebug(@"Error with task_info(): %s", mach_error_string(kerr));
  }
  return 0;
}

NSString *YKNSStringFromNSTimeInterval(NSTimeInterval timeInterval) {
  NSString *hourString = ((NSInteger)(timeInterval / 3600) > 0) ? [NSString stringWithFormat:@"%d:", (NSInteger)(timeInterval / 3600)] : @"";
  NSInteger minute = ((NSInteger)timeInterval % 3600) / 60;
  NSInteger second = (NSInteger)timeInterval % 60;
  return [NSString stringWithFormat:@"%@%02d:%02d", hourString, minute, second];
}

NSString *YKNSStringFromCurrencyAmountInCentsAndCode(NSInteger cents, NSString *currencyCode) {
  static NSNumberFormatter *CurrencyFormatter = NULL;
  if (CurrencyFormatter == NULL) {
    CurrencyFormatter = [[NSNumberFormatter alloc] init];
    [CurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  }
  [CurrencyFormatter setCurrencyCode:currencyCode];
  
  // If price has no cents (only dollars) don't show .00 decimal in string (12 instead of 12.00)
  if ((cents % 100) == 0) {
    [CurrencyFormatter setMaximumFractionDigits:0];
  }

  return [CurrencyFormatter stringForObjectValue:@((double)cents/100.0)];
}

typedef void (^YKEmptyBlock)();

void YKDispatch(dispatch_block_t block) {
  dispatch_async(dispatch_get_current_queue(), block);
}

void YKDispatchAfter(NSTimeInterval seconds, dispatch_block_t block) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_current_queue(), block);
}
