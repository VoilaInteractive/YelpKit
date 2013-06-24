//
//  YKUIButtonViewTest.m
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

@implementation YKUIButtonViewTest

- (void)setUp {
  [super setUp];
  _superView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
  
  _listView = [[YKUIListView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
  _listView.insets = UIEdgeInsetsMake(10, 10, 10, 10);
  [_superView addSubview:_listView];
  [_listView release];
  
  _pressedListView = [[YKUIListView alloc] initWithFrame:CGRectMake(0, 100, 320, 100)];
  _pressedListView.insets = UIEdgeInsetsMake(10, 10, 10, 10);
  [_superView addSubview:_pressedListView];
  [_pressedListView release];
  
  _disabledListView = [[YKUIListView alloc] initWithFrame:CGRectMake(0, 200, 320, 100)];
  _disabledListView.insets = UIEdgeInsetsMake(10, 10, 10, 10);
  [_superView addSubview:_disabledListView];
  [_disabledListView release];
}

- (void)tearDown {
  [_superView release];
  [super tearDown];
}

- (YKUIButton *)buttonPressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *button = [[YKUIButton alloc] init];
  button.title = @"Button";
  button.titleColor = [UIColor darkGrayColor];
  button.titleFont = [UIFont boldSystemFontOfSize:15];
  button.color = [UIColor whiteColor];
  button.borderColor = [UIColor darkGrayColor];
  button.insets = UIEdgeInsetsMake(10, 10, 10, 10);
  button.borderStyle = YKUIBorderStyleRounded;
  button.cornerRadius = 10.0f;
  button.borderWidth = 1.0f;
  button.highlightedColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
  button.shadingType = YKUIShadingTypeLinear;
  button.highlightedShadingType = YKUIShadingTypeLinear;
  button.disabledShadingType = YKUIShadingTypeNone;
  button.disabledTitleShadowColor = [UIColor colorWithWhite:0 alpha:0]; // Disables title shadow if set
  button.disabledColor = [UIColor colorWithWhite:239.0f/255.0f alpha:1.0f];
  button.disabledTitleColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
  button.disabledBorderColor = [UIColor colorWithWhite:216.0f/255.0f alpha:1.0f];
  [button setTarget:self action:@selector(_buttonSelected:)];
  button.selected = pressed;
  button.enabled = enabled;
  return [button autorelease];
}

- (NSString *)_stringFromAlignment:(NSTextAlignment)alignment {
  switch (alignment) {
    case NSTextAlignmentCenter:
      return @"center";
    case NSTextAlignmentJustified:
      return @"justified";
    case NSTextAlignmentLeft:
      return @"left";
    case NSTextAlignmentNatural:
      return @"natural";
    case NSTextAlignmentRight:
      return @"right";
    default:
      return @"";
  }
}

- (YKUIButton *)buttonWithIcon:(BOOL)icon accessoryImage:(BOOL)accessoryImage alignment:(NSTextAlignment)alignment titleInsets:(UIEdgeInsets)titleInsets pressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *button = [self buttonPressed:pressed enabled:enabled];
  NSMutableString *buttonTitle = [NSMutableString stringWithFormat:@"Button (%@ alignment", [self _stringFromAlignment:alignment]];
  if (icon) {
    [buttonTitle appendString:@", icon"];
    button.iconImage = [UIImage imageNamed:@"button_icon.png"];
  }
  if (accessoryImage) {
    [buttonTitle appendString:@", accessory"];
    button.accessoryImage = [UIImage imageNamed:@"button_accessory_image.png"];
    button.highlightedAccessoryImage = [UIImage imageNamed:@"button_accessory_image_selected.png"];
  }
  [buttonTitle appendString:@")"];
  button.title = buttonTitle;
  button.titleInsets = titleInsets;
  return button;
}

@end
