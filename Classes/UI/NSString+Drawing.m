//
//  NSString+Drawing.m
//  YelpKit
//
//  Created by Allen Cheung on 8/2/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
//

#import "NSString+Drawing.h"

@implementation NSString (Drawing)

- (CGSize)yk_sizeWithFont:(UIFont *)font {
  CGSize retSize;
  if ([self respondsToSelector:@selector(sizeWithAttributes:)]) {
    // iOS7 only
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    retSize = [self sizeWithAttributes:@{NSFontAttributeName: font}];
#endif
  } else {
    retSize = [self sizeWithFont:font];
  }
  retSize.width = ceilf(retSize.width);
  retSize.height = ceilf(retSize.height);
  return retSize;
}

- (CGSize)yk_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
  // Passing -1 as a "special" flag not to use lineBreakMode
  return [self yk_sizeWithFont:font constrainedToSize:size lineBreakMode:-1];
}

- (CGSize)yk_sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode {
  // Use CGFLOAT_MAX as a flag for size with width
  return [self yk_sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:lineBreakMode];
}

- (CGSize)yk_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
  CGSize retSize;
  if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
    // iOS7 only
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    retSize = [self boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine) attributes:@{NSFontAttributeName: font} context:nil].size;
#endif
  } else {
    if ((NSInteger)lineBreakMode == -1) {
      retSize = [self sizeWithFont:font constrainedToSize:size];
    } else {
      retSize = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
    }
  }
  retSize.width = ceilf(retSize.width);
  retSize.height = ceilf(retSize.height);
  return retSize;
}

@end
