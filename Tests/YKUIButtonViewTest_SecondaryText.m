//
//  YKUIButtonViewTest_SecondaryText.m
//  YelpKit
//
//  Created by Allen Cheung on 6/24/13.
//  Copyright 2013 Yelp. All rights reserved.
//

#import "YKUIButtonViewTest.h"

@interface YKUIButtonViewTest_SecondaryText : YKUIButtonViewTest {
  UIColor *_defaultSecondaryTitleColor;
  UIFont *_defaultSecondaryTitleFont;
}
@end


@implementation YKUIButtonViewTest_SecondaryText

- (void)setUp {
  [super setUp];
  _defaultSecondaryTitleColor = [[UIColor grayColor] retain];
  _defaultSecondaryTitleFont = [[UIFont systemFontOfSize:14] retain];
}

- (void)tearDown {
  [_defaultSecondaryTitleColor release];
  [_defaultSecondaryTitleFont release];
  [super tearDown];
}

- (YKUIButton *)_buttonWithSecondaryTitle:(NSString *)secondaryTitle position:(YKUIButtonSecondaryTitlePosition)position font:(UIFont *)font color:(UIColor *)color maxLineCount:(NSInteger)maxLineCount alignment:(NSTextAlignment)alignment pressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *button = [self buttonPressed:pressed enabled:enabled];
  button.secondaryTitle = secondaryTitle;
  button.secondaryTitlePosition = position;
  button.secondaryTitleFont = font;
  button.secondaryTitleColor = color;
  button.secondaryTitleMaxLineCount = maxLineCount;
  button.secondaryTitleAlignment = alignment;
  return button;
}

- (YKUIButton *)_buttonWithSecondaryTitle:(NSString *)secondaryTitle position:(YKUIButtonSecondaryTitlePosition)position font:(UIFont *)font color:(UIColor *)color pressed:(BOOL)pressed enabled:(BOOL)enabled {
  return [self _buttonWithSecondaryTitle:secondaryTitle position:position font:font color:color maxLineCount:0 alignment:NSTextAlignmentCenter pressed:pressed enabled:enabled];
}

- (void)testButtonSecondaryTitleCenteredMultiline {
  NSString *title = @"Secondary text, centered, multiline will not ellipsis";
  [_listView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionBottom font:[UIFont systemFontOfSize:13] color:_defaultSecondaryTitleColor pressed:NO enabled:YES]];
  [_pressedListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionBottom font:[UIFont systemFontOfSize:13] color:_defaultSecondaryTitleColor pressed:YES enabled:YES]];
  [_disabledListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionBottom font:[UIFont systemFontOfSize:13] color:_defaultSecondaryTitleColor pressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (void)testButtonSecondaryTitleDefault {
  // TODO(acheung): Secondary text needs insets, using space for now
  // Use these insets per gabe: button6.titleInsets = UIEdgeInsetsMake(0, 0, 0, 6);
  NSString *title = @" Secondary text";
  [_listView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionDefault font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:0 alignment:NSTextAlignmentLeft pressed:NO enabled:YES]];
  [_pressedListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionDefault font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:0 alignment:NSTextAlignmentLeft pressed:YES enabled:YES]];
  [_disabledListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionDefault font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:0 alignment:NSTextAlignmentLeft pressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (void)testButtonSecondaryTitleDefaultEllipsis {
  NSString *title = @" Secondary text. default position, should ellipsis";
  [_listView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionDefault font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:1 alignment:NSTextAlignmentLeft pressed:NO enabled:YES]];
  [_pressedListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionDefault font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:1 alignment:NSTextAlignmentLeft pressed:YES enabled:YES]];
  [_disabledListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionDefault font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:1 alignment:NSTextAlignmentLeft pressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (void)testButtonSecondaryTitleBottomLeft {
  NSString *title = @"Secondary text, bottom left";
  [_listView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionBottom font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:1 alignment:NSTextAlignmentLeft pressed:NO enabled:YES]];
  [_pressedListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionBottom font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:1 alignment:NSTextAlignmentLeft pressed:YES enabled:YES]];
  [_disabledListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionBottom font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:1 alignment:NSTextAlignmentLeft pressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (void)testButtonSecondaryTitleBottomLeftSingleLineEllipsis {
  NSString *title = @"Secondary text, bottom left align single line, will ellipsis";
  [_listView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionBottom font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:1 alignment:NSTextAlignmentLeft pressed:NO enabled:YES]];
  [_pressedListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionBottom font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:1 alignment:NSTextAlignmentLeft pressed:YES enabled:YES]];
  [_disabledListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionBottom font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:1 alignment:NSTextAlignmentLeft pressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (void)testButtonSecondaryTitleRightAlign {
  NSString *title = @"Secondary text, right align";
  [_listView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionDefault font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:0 alignment:NSTextAlignmentRight pressed:NO enabled:YES]];
  [_pressedListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionDefault font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:0 alignment:NSTextAlignmentRight pressed:YES enabled:YES]];
  [_disabledListView addView:[self _buttonWithSecondaryTitle:title position:YKUIButtonSecondaryTitlePositionDefault font:_defaultSecondaryTitleFont color:_defaultSecondaryTitleColor maxLineCount:0 alignment:NSTextAlignmentRight pressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

@end
