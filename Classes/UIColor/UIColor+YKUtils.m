//
//  UIColor+YKUtils.m
//  YelpKit
//
//  Created by John Boiles on 2/13/12.
//  Copyright 2012 Yelp. All rights reserved.
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

#import "UIColor+YKUtils.h"
#import "YKDefines.h"

YKRGBAColor YKRGBAColorMake(uint8_t red, uint8_t green, uint8_t blue, CGFloat alpha) {
  YKRGBAColor color = { .red = red, .green = green, .blue = blue, .alpha = alpha };
  return color;
}

YKRGBAColor YKRGBAColorMakeWithWhite(uint8_t white, CGFloat alpha) {
  YKRGBAColor color = { .red = white, .green = white, .blue = white, .alpha = alpha };
  return color;
}

@implementation UIColor (YKUtils)

- (UIColor *)yk_colorByAddingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
  const CGFloat* components = CGColorGetComponents(self.CGColor);
  CGFloat originalRed = components[0];
  CGFloat originalGreen = components[1];
  CGFloat originalBlue = components[2];
  CGFloat originalAlpha = CGColorGetAlpha(self.CGColor);
  red = YKConstrain(originalRed + red, 0, 1.0);
  green = YKConstrain(originalGreen + green, 0, 1.0);
  blue = YKConstrain(originalBlue + blue, 0, 1.0);
  alpha = YKConstrain(originalAlpha + alpha, 0, 1.0);
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)yk_colorByMultiplyingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
  const CGFloat* components = CGColorGetComponents(self.CGColor);
  CGFloat originalRed = components[0];
  CGFloat originalGreen = components[1];
  CGFloat originalBlue = components[2];
  CGFloat originalAlpha = CGColorGetAlpha(self.CGColor);
  red = YKConstrain(originalRed * red, 0, 1.0);
  green = YKConstrain(originalGreen * green, 0, 1.0);
  blue = YKConstrain(originalBlue * blue, 0, 1.0);
  alpha = YKConstrain(originalAlpha * alpha, 0, 1.0);
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)yk_colorWithRGBA:(YKRGBAColor)color {
  return [UIColor colorWithRed:color.red / 255.0 green:color.green / 255.0 blue:color.blue / 255.0 alpha:color.alpha];
}

@end
