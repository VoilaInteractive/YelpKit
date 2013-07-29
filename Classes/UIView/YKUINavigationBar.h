//
//  YKUINavigationBar.h
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

typedef enum {
  YKUINavigationButtonStyleDefault = 0,
  YKUINavigationButtonStyleClose,
  YKUINavigationButtonStyleBack,
  YKUINavigationButtonStyleDone,
  YKUINavigationButtonStyleTranslucentBlack,
  YKUINavigationButtonStyleNone,
} YKUINavigationButtonStyle;

typedef enum {
  YKUINavigationPositionLeft = 0,
  YKUINavigationPositionRight = 1,
} YKUINavigationPosition;

@interface YKUINavigationBar : UINavigationBar {
  
  CGSize _defaultContentViewSize;
}
@property (assign, nonatomic) CGFloat borderWidth;

/*!
 Amount to inset the top of the views by.
 
 Note that the views are, by default, centered vertically. So, for iOS7, to account for the height of the status bar (20), this has to be set to 10.
 */
@property (assign, nonatomic) CGFloat topInset;

@end
