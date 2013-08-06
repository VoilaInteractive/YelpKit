//
//  NSString+YKDrawing.h
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

/*!
 NSString category wrapping deprecated (in iOS7) sizing methods.  Calls the 
 recommended method if the receiver responds to the selector, otherwise calls
 the old method.  The recommended methods are only available in iOS7 which adds
 some complications.
 
 In addition sizes are ceilf to fix the issue where fractional sizes cause UI
 glitches.
 
 The logic needs to follow like this:
 
    -  On iOS 6, call the old method, no matter which SDK we are building against.
       Use respondsToSelector: to make this happen.
 
    -  On iOS 7, call the new method
 
    -  To build on Xcode4, declare the new methods in a category.
 
 Needless to say, this should all be cleaned up once iOS7 and Xcode5 are released.
 
 */

@interface NSString (YKDrawing)

- (CGSize)yk_sizeWithFont:(UIFont *)font;

- (CGSize)yk_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (CGSize)yk_sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)yk_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
