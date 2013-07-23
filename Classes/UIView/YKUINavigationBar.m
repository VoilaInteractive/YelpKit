//
//  YKUINavigationBar.m
//  YelpKit
//
//  Created by Gabriel Handford on 3/31/12.
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

#import "YKUINavigationBar.h"
#import "YKCGUtils.h"
#import "YKUIButton.h"
#import "UILabel+YKUtils.h"

@implementation YKUINavigationBar

- (void)sharedInit { 
  _borderWidth = 0.5;
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self sharedInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [self sharedInit];
  }
  return self;
}

- (void)dealloc {
  [_backgroundColor1 release];
  [_backgroundColor2 release];
  [_topBorderColor release];
  [_bottomBorderColor release];
  [super dealloc];
}

- (void)setTopInset:(CGFloat)topInset {
  _topInset = topInset;
  self.frame = YKCGRectSetHeight(self.frame, 44 + (2 * _topInset));
}

- (CGSize)sizeThatFits:(CGSize)size {
  return CGSizeMake(size.width, 44);
}

- (void)_redrawBackgroundImage {
  UIGraphicsBeginImageContext(self.frame.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  if (_backgroundColor1) {
    YKCGContextDrawShading(context, _backgroundColor1.CGColor, _backgroundColor2.CGColor, NULL, NULL, CGPointZero, CGPointMake(0, self.frame.size.height), YKUIShadingTypeLinear, NO, NO);
  }
  if (_topBorderColor) {
    // Border is actually halved since the top half is cut off (this is on purpose).
    YKCGContextDrawLine(context, 0, 0, self.frame.size.width, 0, _topBorderColor.CGColor, _borderWidth * 2);
  }
  if (_bottomBorderColor) {
    // Border is actually halved since the bottom half is cut off (this is on purpose).
    YKCGContextDrawLine(context, 0, self.frame.size.height, self.frame.size.width, self.frame.size.height, _bottomBorderColor.CGColor, _borderWidth * 2);
  }
  _backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
  [self setBackgroundImage:_backgroundImage forBarMetrics:UIBarMetricsDefault];
  UIGraphicsEndImageContext();
}

- (void)setTopBorderColor:(UIColor *)topBorderColor {
  [topBorderColor retain];
  [_topBorderColor release];
  _topBorderColor = topBorderColor;
  [self _redrawBackgroundImage];
}

- (void)setBottomBorderColor:(UIColor *)bottomBorderColor {
  [bottomBorderColor retain];
  [_bottomBorderColor release];
  _bottomBorderColor = bottomBorderColor;
  [self _redrawBackgroundImage];
}

- (void)setBackgroundColor1:(UIColor *)backgroundColor1 {
  [backgroundColor1 retain];
  [_backgroundColor1 release];
  _backgroundColor1 = backgroundColor1;
  [self _redrawBackgroundImage];
}

- (void)setBackgroundColor2:(UIColor *)backgroundColor2 {
  [backgroundColor2 retain];
  [_backgroundColor2 release];
  _backgroundColor2 = backgroundColor2;
  [self _redrawBackgroundImage];
}

- (void)setNoShadow {
  self.shadowImage = [[[UIImage alloc] init] autorelease];
}

@end
