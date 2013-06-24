//
//  YKLText.h
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

#import "YKLBaseView.h"
@class YKLImage;

@interface YKLText : YKLBaseView {
  NSString *_text;
  UIFont *_font;
  UIColor *_textColor;
  UILineBreakMode _lineBreakMode;
  NSTextAlignment _textAlignment;
  
  CGSize _constrainedToSize;
  
  UIColor *_shadowColor;
  CGSize _shadowOffset;
  
  YKLImage *_imageView;
  
  // Cached sizing
  CGSize _sizeThatFits;
  CGSize _sizeForSizeThatFits;
}

@property (retain, nonatomic) UIColor *shadowColor;
@property (assign, nonatomic) CGSize shadowOffset;
@property (retain, nonatomic) UIFont *font;
@property (retain, nonatomic) NSString *text;
@property (retain, nonatomic) UIColor *textColor;
@property (assign, nonatomic) UILineBreakMode lineBreakMode;
@property (assign, nonatomic) NSTextAlignment textAlignment;

/*!
 Constrained to size.
 For unlimited height, set to CGSizeMake(0, FLT_MAX).
 Defaults to CGSizeZero which means a single line.
 */
@property (assign, nonatomic) CGSize constrainedToSize;

- (id)initWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineBreakMode:(UILineBreakMode)lineBreakMode textAligment:(NSTextAlignment)textAlignment;

+ (YKLText *)text:(NSString *)text font:(UIFont *)font;
+ (YKLText *)text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor;
+ (YKLText *)text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineBreakMode:(UILineBreakMode)lineBreakMode;
+ (YKLText *)text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineBreakMode:(UILineBreakMode)lineBreakMode textAligment:(NSTextAlignment)textAlignment;

/*!
 Set image. The image is drawn on the left side of the text by default.
 @param image
 @param insets
 */
- (void)setImage:(UIImage *)image insets:(UIEdgeInsets)insets;

@end
