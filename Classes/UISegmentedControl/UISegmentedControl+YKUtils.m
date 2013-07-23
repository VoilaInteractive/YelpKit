//
//  UISegmentedControl+YKUtils.m
//  YelpKit
//
//  Created by Alexander Haefner on 7/22/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
//

#import "UISegmentedControl+YKUtils.h"

@implementation UISegmentedControl (YKUtils)

- (NSUInteger)indexForTitle:(NSString *)title {
  for (NSUInteger index = 0; index < [self numberOfSegments]; index++) {
    if ([[self titleForSegmentAtIndex:index] isEqualToString:title]) {
      return index;
    }
  }
  return NSNotFound;
}


@end
