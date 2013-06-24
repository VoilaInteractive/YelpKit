//
//  YKUIButtonViewTest_Borders.m
//  YelpKit
//
//  Created by Allen Cheung on 6/24/13.
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

#import "YKUIButtonViewTest.h"

@interface YKUIButtonViewTest_Borders : YKUIButtonViewTest
@end


@implementation YKUIButtonViewTest_Borders

- (NSString *)_stringFromBorderStyle:(YKUIBorderStyle)borderStyle {
  switch (borderStyle) {
    case YKUIBorderStyleNone:
      return @"None";
    case YKUIBorderStyleRoundedTop:
      return @"Rounded top";
    case YKUIBorderStyleTopLeftRight:
      return @"Top left right";
    case YKUIBorderStyleRoundedBottom:
      return @"Rounded bottom";
    default:
      return @"Unsupported";
  }
}

- (YKUIButton *)_buttonWithBorderStyle:(YKUIBorderStyle)borderStyle pressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *button = [self buttonPressed:pressed enabled:enabled];
  button.title = [NSString stringWithFormat:@"Button (%@)", [self _stringFromBorderStyle:borderStyle]];
  button.borderStyle = borderStyle;
  button.cornerRadius = 6.0f;
  button.borderWidth = 1.0f;
  return button;
}

- (void)testRoundedTopButton {
  [_listView addView:[self _buttonWithBorderStyle:YKUIBorderStyleRoundedTop pressed:NO enabled:YES]];
  [_pressedListView addView:[self _buttonWithBorderStyle:YKUIBorderStyleRoundedTop pressed:YES enabled:YES]];
  [_disabledListView addView:[self _buttonWithBorderStyle:YKUIBorderStyleRoundedTop pressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (void)testTopLeftRightButton {
  [_listView addView:[self _buttonWithBorderStyle:YKUIBorderStyleTopLeftRight pressed:NO enabled:YES]];
  [_pressedListView addView:[self _buttonWithBorderStyle:YKUIBorderStyleTopLeftRight pressed:YES enabled:YES]];
  [_disabledListView addView:[self _buttonWithBorderStyle:YKUIBorderStyleTopLeftRight pressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (void)testRoundedBottomButton {
  [_listView addView:[self _buttonWithBorderStyle:YKUIBorderStyleRoundedBottom pressed:NO enabled:YES]];
  [_pressedListView addView:[self _buttonWithBorderStyle:YKUIBorderStyleRoundedBottom pressed:YES enabled:YES]];
  [_disabledListView addView:[self _buttonWithBorderStyle:YKUIBorderStyleRoundedBottom pressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

@end
