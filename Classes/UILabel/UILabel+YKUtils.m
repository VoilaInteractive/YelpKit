//
//  UILabel+YKUtils.m
//  YelpKit
//
//  Created by John Boiles on 8/1/12.
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

#import "UILabel+YKUtils.h"
#import "NSString+YKDrawing.h"

@implementation UILabel (YKUtils)

- (UILabel *)yk_copy {
  UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
  label.font = self.font;
  label.minimumFontSize = self.minimumFontSize;
  label.numberOfLines = self.numberOfLines;
  label.lineBreakMode = self.lineBreakMode;
  label.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidth;
  label.shadowColor = self.shadowColor;
  label.shadowOffset = self.shadowOffset;
  label.textColor = self.textColor;
  label.textAlignment = self.textAlignment;
  label.opaque = self.opaque;
  label.contentMode = self.contentMode;
  label.backgroundColor = self.backgroundColor;
  label.userInteractionEnabled = self.userInteractionEnabled;
  label.highlighted = self.highlighted;
  label.highlightedTextColor = self.highlightedTextColor;
  label.enabled = self.enabled;
  label.baselineAdjustment = self.baselineAdjustment;
  label.text = self.text;
  return label;
}

- (CGSize)yk_multilineSizeThatFits:(CGSize)size {
  return [self.text yk_sizeWithFont:self.font constrainedToSize:size lineBreakMode:self.lineBreakMode];
}

- (void)yk_draw {
  [self.text drawInRect:self.frame withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
}

@end
