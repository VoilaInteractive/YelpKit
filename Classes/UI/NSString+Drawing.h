//
//  NSString+Drawing.h
//  YelpKit
//
//  Created by Allen Cheung on 8/2/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
//

@interface NSString (Drawing)

- (CGSize)yk_sizeWithFont:(UIFont *)font;

- (CGSize)yk_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (CGSize)yk_sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)yk_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
