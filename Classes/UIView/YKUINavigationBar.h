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

extern CGFloat const kYKUINavigationBarTitleAnimationDuration;
@class YKUIButtons;

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

extern CGFloat const kYKUINavigationBarTitelAnimationDuration;

@interface YKUINavigationBar : UINavigationBar {
  UILabel *_titleLabel;
  
  UINavigationItem *_navigationItem;
  
  CGSize _defaultContentViewSize;
}

@property (retain, nonatomic) YKUIButtons *leftButton;
@property (retain, nonatomic) YKUIButtons *rightButton;
@property (retain, nonatomic) UIView *contentView;
@property (retain, nonatomic) UINavigationItem *navigationItem;

@property (retain, nonatomic) UIColor *backgroundColor1;
@property (retain, nonatomic) UIColor *backgroundColor2;
@property (retain, nonatomic) UIColor *topBorderColor;
@property (retain, nonatomic) UIColor *bottomBorderColor;
@property (assign, nonatomic) CGFloat borderWidth;

/*!
 Amount to inset the top of the views by.
 
 Note that the views are, by default, centered vertically. So, for iOS7, to account for the height of the status bar (20), this has to be set to 10.
 */
@property (assign, nonatomic) CGFloat topInset;

/*!
 Set the content view to a UILabel with title.
 @param title
 @param animated
 */
- (void)setTitle:(NSString *)title animated:(BOOL)animated;

/*!
 @result Title label
 */
- (UILabel *)titleLabel;

/*!
 Set the content view.
 Content view must return a valid sizeThatFits: method.
 @param contentView
 @param animated
 */
- (void)setContentView:(UIView *)contentView animated:(BOOL)animated;

/*!
 Set right button.
 @param rightButton
 @param animated
 */
- (void)setRightButton:(YKUIButtons *)rightButton style:(YKUINavigationButtonStyle)style animated:(BOOL)animated;

/*!
 Set left button.
 @param leftButton
 @param animated
 */
- (void)setLeftButton:(YKUIButtons *)leftButton style:(YKUINavigationButtonStyle)style animated:(BOOL)animated;

@end
