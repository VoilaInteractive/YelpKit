//
//  YKTableIndexedView.m
//  YelpKit
//
//  Created by Gabriel Handford on 5/27/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
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

#import "YKTableIndexedView.h"

@implementation YKTableIndexedView

- (void)sharedInit {
  [super sharedInit];
  
  // Default header titles
  [self setSectionIndexTitles:@[UITableViewIndexSearch, @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"] sectionHeadersEnabled:YES];

  self.sectionIndexMinimumDisplayRowCount = 10;
  self.decelerationRate = UIScrollViewDecelerationRateNormal * 10;
}

- (void)setSectionIndexTitles:(NSArray *)sectionIndexTitles sectionHeadersEnabled:(BOOL)sectionHeadersEnabled {
  [sectionIndexTitles retain];
  [_sectionIndexTitles release];
  _sectionIndexTitles = sectionIndexTitles;
  [self.dataSource setSectionIndexTitles:_sectionIndexTitles];
  if (sectionHeadersEnabled) {
    [self.dataSource setSectionHeaderTitles:_sectionIndexTitles];
  }
}

- (void)addCellDataSource:(id<YKTableViewCellDataSource>)cellDataSource label:(NSString *)label {
  NSString *sectionKey = [[label substringToIndex:1] uppercaseString];
  NSUInteger section = [_sectionIndexTitles indexOfObject:sectionKey];
  if (section == NSNotFound) section = 26;  
  [self.dataSource addCellDataSource:cellDataSource section:section];
}

@end
