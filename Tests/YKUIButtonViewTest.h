//
//  YKUIButtonViewTest.h
//  YelpKit
//
//  Created by Allen Cheung on 6/24/13.
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

#import "YKViewTestCase.h"
#import <YelpKit/YelpKit.h>

@interface YKUIButtonViewTest : YKViewTestCase {
  UIView *_superView;
  YKUIListView *_listView;
  YKUIListView *_pressedListView;
  YKUIListView *_disabledListView;
}

- (YKUIButton *)buttonPressed:(BOOL)pressed enabled:(BOOL)enabled;
- (YKUIButton *)buttonWithIcon:(BOOL)icon accessoryImage:(BOOL)accessoryImage alignment:(NSTextAlignment)alignment titleInsets:(UIEdgeInsets)titleInsets pressed:(BOOL)pressed enabled:(BOOL)enabled;

@end
