//
//  UINavigationBar+ShadowButtons.m
//  YelpKit
//
//  Created by Alexander Haefner on 8/12/13.
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

#import "UINavigationBar+ShadowButtons.h"

@implementation UINavigationBar (ShadowButtons)

- (void)applyButtonShadow:(UIColor *)shadow offset:(CGSize)offset radius:(CGFloat)radius opacity:(CGFloat)opacity {
  NSMutableArray *viewArray = [NSMutableArray array];
  NSMutableArray *buttonSubviews = [self recurseSubviews:self intoArray:viewArray];
  for (UIView *view in buttonSubviews) {
    view.layer.shadowColor = shadow.CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowRadius = radius;
    view.layer.shadowOpacity = opacity;
  }
}

- (NSMutableArray *)recurseSubviews:(UIView *)containerView intoArray:(NSMutableArray *)viewArray {
  for (UIView *view in containerView.subviews) {
    viewArray = [self recurseSubviews:view intoArray:viewArray];
    if ([NSStringFromClass([view class]) isEqualToString:@"UINavigationButton"]) {
      [viewArray addObject:view];
    }
  }
  return viewArray;
}
@end
