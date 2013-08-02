//
//  YKLText.m
//  YelpKit
//
//  Created by Gabriel Handford on 4/11/12.
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

#import "YKLText.h"
#import "YKCGUtils.h"
#import "YKLImage.h"
#import "NSString+Drawing.h"

@implementation YKLText

@synthesize shadowColor=_shadowColor, shadowOffset=_shadowOffset, font=_font, textColor=_textColor, text=_text, lineBreakMode=_lineBreakMode, textAlignment=_textAlignment, constrainedToSize=_constrainedToSize;

- (id)init {
  if ((self = [super init])) {
    _sizeThatFits = YKCGSizeNull;
    _sizeForSizeThatFits = YKCGSizeNull;
    _constrainedToSize = CGSizeZero;
  }
  return self;
}

- (id)initWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineBreakMode:(UILineBreakMode)lineBreakMode textAligment:(UITextAlignment)textAlignment {
  if ((self = [self init])) {
    _text = [text retain];
    _font = [font retain];
    _textColor = [textColor retain];
    _lineBreakMode = lineBreakMode;
    _textAlignment = textAlignment;
  }
  return self;
}

- (void)dealloc {
  [_text release];
  [_font release];
  [_textColor release];
  [_shadowColor release];
  [_imageView release];
  [super dealloc];
}

+ (YKLText *)text:(NSString *)text font:(UIFont *)font {
  return [self text:text font:font textColor:nil lineBreakMode:-1];
}

+ (YKLText *)text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor {
  return [self text:text font:font textColor:textColor lineBreakMode:-1];
}

+ (YKLText *)text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineBreakMode:(UILineBreakMode)lineBreakMode {
  return [[[YKLText alloc] initWithText:text font:font textColor:textColor lineBreakMode:lineBreakMode textAligment:UITextAlignmentLeft] autorelease];
}

+ (YKLText *)text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineBreakMode:(UILineBreakMode)lineBreakMode textAligment:(UITextAlignment)textAlignment {
  return [[[YKLText alloc] initWithText:text font:font textColor:textColor lineBreakMode:lineBreakMode textAligment:textAlignment] autorelease];
}

- (void)_reset {
  _sizeThatFits = YKCGSizeNull;
  _sizeForSizeThatFits = YKCGSizeNull;
}

- (void)setImage:(UIImage *)image insets:(UIEdgeInsets)insets {
  [_imageView release];
  _imageView = [[YKLImage alloc] initWithImage:image];
  _imageView.insets = insets;
  [self _reset];
}

- (void)setFont:(UIFont *)font {
  [font retain];
  [_font release];
  _font = font;
  [self _reset];
}

- (void)setText:(NSString *)text {
  [text retain];
  [_text release];
  _text = text;
  [self _reset];
}

- (NSString *)description {
  return _text;
}

- (BOOL)isSingleLine {
  return YKCGSizeIsZero(_constrainedToSize);
}

- (CGSize)sizeThatFits:(CGSize)size {
  if (size.width == 0) return size;
  
  if (YKCGSizeIsEqual(size, _sizeForSizeThatFits) && !YKCGSizeIsNull(_sizeThatFits)) return _sizeThatFits;
  
  CGSize constrainedToSize = _constrainedToSize;
  if (![self isSingleLine]) {
    if (constrainedToSize.width == 0) constrainedToSize.width = size.width;
    if (constrainedToSize.height == 0) constrainedToSize.height = size.height;
  }

  if (YKCGSizeIsZero(constrainedToSize)) {
    if ((NSInteger)_lineBreakMode == -1) {
      _sizeThatFits = [_text yk_sizeWithFont:_font];
    } else {
      _sizeThatFits = [_text yk_sizeWithFont:_font forWidth:size.width lineBreakMode:_lineBreakMode];
    }
  } else {
    if ((NSInteger)_lineBreakMode == -1) {
      _sizeThatFits = [_text yk_sizeWithFont:_font constrainedToSize:constrainedToSize];
    } else {
      _sizeThatFits = [_text yk_sizeWithFont:_font constrainedToSize:constrainedToSize lineBreakMode:_lineBreakMode];
    }
  }
  
  if (_imageView) {
    CGSize imageSize = [_imageView sizeThatFits:size];
    _sizeThatFits.width += imageSize.width;
    _sizeThatFits.height = MAX(_sizeThatFits.height, imageSize.height);
  }
  
  _sizeForSizeThatFits = size;
  return _sizeThatFits;
}

- (void)drawInRect:(CGRect)rect {
  if (_imageView) {
    CGSize imageViewSize = [_imageView sizeThatFits:rect.size];
    [_imageView drawInRect:rect];
    rect.origin.x += imageViewSize.width;
  }

  if (_textColor) [_textColor setFill];
  if (_shadowColor) {
    CGContextRef context = UIGraphicsGetCurrentContext();	
    CGContextSetShadowWithColor(context, _shadowOffset, 0, _shadowColor.CGColor);
  }
  if (_textAlignment != UITextAlignmentLeft) {
    // TODO: Single line with non-left alignment?
    [_text drawInRect:rect withFont:_font lineBreakMode:_lineBreakMode alignment:_textAlignment];
  } else if (_lineBreakMode == NSUIntegerMax) {
    if ([self isSingleLine]) {
      [_text drawAtPoint:rect.origin withFont:_font];
    } else {
      [_text drawInRect:rect withFont:_font];
    }
  } else {
    if ([self isSingleLine]) {
      [_text drawAtPoint:rect.origin forWidth:rect.size.width withFont:_font lineBreakMode:_lineBreakMode];
    } else {
      [_text drawInRect:rect withFont:_font lineBreakMode:_lineBreakMode];
    }
  }
}

@end
