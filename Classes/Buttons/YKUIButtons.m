//
//  YKUIButtons.m
//  YelpKit
//
//  Created by Gabriel Handford on 3/22/12.
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

#import "YKUIButtons.h"
#import "YKUIButton.h"
#import "YKUIButtonStyles.h"

@implementation YKUIButtons

@synthesize selectionMode=_selectionMode, insets=_insets, delegate=_delegate;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.backgroundColor = [UIColor whiteColor];
    self.layout = [YKLayout layoutForView:self];
    _insets = UIEdgeInsetsZero;
  }
  return self;
}

- (id)initWithCount:(NSInteger)count style:(YKUIButtonsStyle)style apply:(YKUIButtonsApplyBlock)apply {
  NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:count];
  for (NSInteger i = 0; i < count; i++) {
    [buttons addObject:[[[YKUIButton alloc] init] autorelease]];
  }
  return [self initWithButtons:buttons style:style apply:apply];
}

- (id)initWithTitles:(NSArray *)titles style:(YKUIButtonsStyle)style apply:(YKUIButtonsApplyBlock)apply {
  NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:[titles count]];
  for (NSString *title in titles) {
    YKUIButton *button = [[YKUIButton alloc] init];
    button.title = title;
    [buttons addObject:button];
    [button release];
  }
  return [self initWithButtons:buttons style:style apply:apply];
}

- (id)initWithStyle:(YKUIButtonsStyle)style {
  return [self initWithButtons:nil style:style apply:nil];
}

- (id)initWithButtons:(NSArray *)buttons style:(YKUIButtonsStyle)style apply:(YKUIButtonsApplyBlock)apply {
  if ((self = [self initWithFrame:CGRectZero])) {
    _style = style;
    _applyBlock = [apply copy];
    [self setButtons:buttons apply:apply];
  }
  return self;
}

- (void)dealloc {
  [_buttons release];
  Block_release(_applyBlock);
  [super dealloc];
}

- (CGSize)layout:(id<YKLayout>)layout size:(CGSize)size {
  CGFloat y = _insets.top;
  
  CGSize sizeInset = CGSizeMake(size.width - _insets.left - _insets.right, size.height - _insets.top - _insets.bottom);

  switch (_style) {
    case YKUIButtonsStyleHorizontal:
    case YKUIButtonsStyleHorizontalRounded:{
      CGFloat x = _insets.left;
      CGFloat buttonWidth = roundf(sizeInset.width / (CGFloat)[_buttons count]);
      NSInteger i = 0;
      for (YKUIButton *button in _buttons) {
        CGFloat padding = (i == [_buttons count] - 1 ? 0 : 1);
        [layout setFrame:CGRectMake(x, y, buttonWidth + padding, sizeInset.height) view:button];
        x += buttonWidth;
        i++;
      }
      y = size.height;
      break;
    }
    case YKUIButtonsStyleVertical:
    case YKUIButtonsStyleVerticalRounded: {
      for (YKUIButton *button in _buttons) {
        CGRect buttonFrame = [layout setFrame:CGRectMake(_insets.left, y, sizeInset.width, button.frame.size.height) view:button sizeToFit:YES];
        y += buttonFrame.size.height;
      }
      y += _insets.bottom;
      break;
    }
  }
  
  return CGSizeMake(size.width, y);
}

- (void)_applyButton {
  for (NSInteger i = 0, count = [_buttons count]; i < count; i++) {
    YKUIButton *button = _buttons[i];
    [button removeTarget:self action:@selector(_didSelect:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(_didSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    if (count == 1) {
      switch (_style) {
        case YKUIButtonsStyleHorizontalRounded:
        case YKUIButtonsStyleVerticalRounded:
          button.borderStyle = YKUIBorderStyleRounded;
          break;
        default:
          break;
      }
    } else {
      if (i == 0) {
        switch (_style) {
          case YKUIButtonsStyleHorizontalRounded:
            button.borderStyle = YKUIBorderStyleRoundedLeftCap;
            break;
          case YKUIButtonsStyleVerticalRounded:
            button.borderStyle = YKUIBorderStyleRoundedTop;
            break;
          default:
            break;
        }
      } else if (i == count - 1) {
        switch (_style) {
          case YKUIButtonsStyleHorizontalRounded:
            button.borderStyle = YKUIBorderStyleRoundedRightCap;
            break;
          case YKUIButtonsStyleVerticalRounded:
            button.borderStyle = YKUIBorderStyleRoundedBottom;
            break;
          default:
            break;
        }
      } else {
        switch (_style) {
          case YKUIButtonsStyleHorizontalRounded:
            button.borderStyle = YKUIBorderStyleNormal;
            break;
          case YKUIButtonsStyleVerticalRounded:
            button.borderStyle = YKUIBorderStyleTopLeftRight;
            break;
          default:
            break;
        }          
      }
      [button setNeedsDisplay];
    }
  }
}

- (void)addButton:(YKUIButton *)button {
  if (!_buttons) _buttons = [[NSMutableArray alloc] init];
  [_buttons addObject:button];
  [self addSubview:button];
  if (_applyBlock != NULL) _applyBlock(button, [_buttons count] - 1);
  [self _applyButton];
  [self setNeedsDisplay];
  [self setNeedsLayout];
}

- (void)removeButton:(YKUIButton *)button {
  [_buttons removeObject:button];
  [self _applyButton];
  [self setNeedsDisplay];
  [self setNeedsLayout];
}

- (BOOL)removeButtonWithTitle:(NSString *)title {
  YKUIButton *button = [self buttonWithTitle:title];
  if (!button) return NO;
  [self removeButton:button];
  return YES;
}

- (void)removeAllButtons {
  for (UIView *button in _buttons) {
    [button removeFromSuperview];
  }
  [_buttons removeAllObjects];
}

- (void)setButton:(YKUIButton *)button index:(NSInteger)index animated:(BOOL)animated {
  YKUIButton *buttonToRemove = [_buttons gh_objectAtIndex:index];
  if (index == [_buttons count]) {
    [_buttons addObject:button];
  } else {
    _buttons[index] = button;
  }
  [self addSubview:button];
  [self _applyButton];

  if (animated) {
    button.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^(void) {
      buttonToRemove.alpha = 0.0;
      button.alpha = 1.0;
    } completion:^(BOOL finished) {
      [self removeButton:buttonToRemove];
      buttonToRemove.alpha = 1.0;
    }];
  } else {
    [self setNeedsDisplay];
    [self setNeedsLayout];
  }
}

- (NSInteger)count {
  return [_buttons count];
}

- (void)setButtons:(NSArray *)buttons apply:(YKUIButtonsApplyBlock)apply {
  for (UIView *button in _buttons) {
    [button removeFromSuperview];
  }
  [_buttons release];
  _buttons = [buttons mutableCopy];
  [self _applyButton];
  NSInteger index = 0;
  for (YKUIButton *button in _buttons) {  
    [self addSubview:button];
    if (apply != NULL) {
      apply(button, index);
    }
    index++;    
  }
  [self setNeedsDisplay];
  [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)enabled index:(NSInteger)index {
  YKUIButton *button = [_buttons gh_objectAtIndex:index];
  [button setEnabled:enabled];
}

- (void)setEnabled:(BOOL)enabled {
  for (YKUIButton *button in _buttons) {
    [button setEnabled:enabled];
  }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
  YKUIButton *button = [_buttons gh_objectAtIndex:selectedIndex];
  [self setSelected:YES button:button];
}

- (void)setSelected:(BOOL)selected button:(YKUIButton *)button {  
  if (_selectionMode == YKUIButtonsSelectionModeSingle || _selectionMode == YKUIButtonsSelectionModeSingleToggle) {
    for (YKUIButton *b in _buttons) {
      if (b != button) {
        [b setSelected:NO];
      }
    }
  }
  [button setSelected:selected];
}

- (YKUIButton *)selectedButton {
  for (YKUIButton *button in _buttons) {
    if (button.isSelected) return button;
  }
  return nil;
}

- (void)setSelected:(BOOL)selected index:(NSInteger)index {
  YKUIButton *button = [_buttons gh_objectAtIndex:index];
  if (!button) return;
  [self setSelected:selected button:button];
}

- (BOOL)setSelected:(BOOL)selected title:(NSString *)title {
  NSInteger index = [self indexOfTitle:title];
  if (index == NSNotFound) return NO;
  [self setSelected:selected index:index];
  return YES;
}

- (BOOL)isSelectedAtIndex:(NSInteger)index {
  YKUIButton *button = [_buttons gh_objectAtIndex:index];
  if (!button) return NO;
  return button.isSelected;
}

- (NSInteger)selectedIndex {
  NSInteger index = 0;
  for (YKUIButton *button in _buttons) {
    if (button.isSelected) return index;
    index++;
  }
  return NSNotFound;
}

- (NSString *)selectedTitle {
  return [self selectedButton].title;
}

- (NSArray *)selectedIndices {
  NSMutableArray *selectedIndices = [NSMutableArray array];
  NSInteger index = 0;
  for (YKUIButton *button in _buttons) {
    if (button.isSelected) [selectedIndices addObject:@(index)];
    index++;
  }
  return selectedIndices;
}

- (void)setSelectedIndices:(NSArray *)selectedIndices {
  for (NSNumber *index in selectedIndices) {
    [self setSelectedIndex:[index integerValue]];
  }
}

- (void)setTitles:(NSArray *)titles {
  NSInteger index = 0;
  for (NSString *title in titles) {
    YKUIButton *button = _buttons[index++];
    button.title = title;
  }
}

- (YKUIButton *)buttonWithTitle:(NSString *)title {
  for (YKUIButton *button in _buttons) {
    if ([[button title] isEqualToString:title]) return button;
  }
  return nil;
}

- (NSInteger)indexOfTitle:(NSString *)title {
  NSInteger index = 0;
  for (YKUIButton *button in _buttons) {
    if ([[button title] isEqualToString:title]) return index;
    index++;
  }
  return NSNotFound;
}

- (void)_didSelect:(id)sender {
  NSInteger index = [_buttons indexOfObject:sender];
  if ([_delegate respondsToSelector:@selector(buttons:shouldSelectButton:index:)]) {
    if (![_delegate buttons:self shouldSelectButton:sender index:index]) return;
  }
  
  YKUIButton *previousButton = [self selectedButton];
  
  switch (_selectionMode) {
    case YKUIButtonsSelectionModeSingleToggle:
      if ([self selectedIndex] == index) {
        [self setSelected:NO button:sender];
      } else {
        [self setSelected:YES button:sender];  
      }
      break;
    case YKUIButtonsSelectionModeSingle:
      [self setSelected:YES button:sender];
      break;
    case YKUIButtonsSelectionModeMultiple:
      [self setSelected:![sender isSelected] button:sender];
      break;
    case YKUIButtonsSelectionModeNone:
      break;
  }

  if ([_delegate respondsToSelector:@selector(buttons:didSelectButton:index:previousButton:)]) {
    [_delegate buttons:self didSelectButton:sender index:index previousButton:previousButton];
  }
}

- (void)clearSelected {
  for (YKUIButton *button in _buttons) {
    [button setSelected:NO];
  }
}

- (NSArray *)buttons {
  return _buttons;
}

@end
