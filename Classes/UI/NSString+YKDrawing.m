//
//  NSString+YKDrawing.m
//  YelpKit
//
//  Created by Allen Cheung on 8/2/13.
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

#import "NSString+YKDrawing.h"
#import "YKCGUtils.h"

// Only need to declare if buildng agains iOS 6 SDK on Xcode4
#if !(__IPHONE_OS_VERSION_MAX_ALLOWED >= 70000)
@interface NSString ()
- (CGSize)sizeWithAttributes:(NSDictionary *)attrs;
- (CGRect)boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes context:(NSStringDrawingContext *)context;
@end
#endif

@implementation NSString (YKDrawing)

- (CGSize)yk_sizeWithFont:(UIFont *)font {
  CGSize retSize;
  if ([self respondsToSelector:@selector(sizeWithAttributes:)]) {
    retSize = [self sizeWithAttributes:@{NSFontAttributeName: font}];
  } else {
    // If running on iOS 6, call the deprecated method
    retSize = [self sizeWithFont:font];
  }
  return YKCGSizeCeil(retSize);
}

- (CGSize)yk_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
  // From Apple's docs on sizeWithFont:constrainedToSize:  "This method computes the metrics needed to draw the specified string. This method lays out the receiver’s text and attempts to make it fit the specified size using the specified font and the NSLineBreakByWordWrapping line break option."
  return [self yk_sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)yk_sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode {
  // Use CGFLOAT_MAX as the height when the user only specifies width
  return [self yk_sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:lineBreakMode];
}

- (CGSize)yk_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
  CGSize retSize;
  if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
    // It should be sufficient to leave the rest of the paragraph style attributes uninitialized, text alignment for example doesn't matter, because we are only using the returned size, not the rect itself
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    retSize = [self boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine) attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: style} context:nil].size;
    [style release];
  } else {
    // If running on iOS 6, call the deprecated method
    retSize = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
  }
  return YKCGSizeCeil(retSize);
}

@end
