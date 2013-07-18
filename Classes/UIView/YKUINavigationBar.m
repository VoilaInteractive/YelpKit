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
  [_titleLabel release];
  [super dealloc];
}

- (void)setTopInset:(CGFloat)topInset {
  _topInset = topInset;
  self.frame = YKCGRectSetHeight(self.frame, 44 + (2 * _topInset));
}

- (CGRect)rectForLeftButton:(CGSize)size {
  if (!_leftButton) return CGRectZero;
  CGRect leftCenter = YKCGRectToCenter(_leftButton.frame.size, size);
  return CGRectMake(5, leftCenter.origin.y + self.topInset, _leftButton.frame.size.width, _leftButton.frame.size.height);
}

- (CGRect)rectForRightButton:(CGSize)size {
  if (!_rightButton) return CGRectZero;
  CGRect rightCenter = YKCGRectToCenter(_rightButton.frame.size, size);
  return CGRectMake(size.width - _rightButton.frame.size.width - 5, rightCenter.origin.y + self.topInset, _rightButton.frame.size.width, _rightButton.frame.size.height);
}

- (CGRect)rectForContentView:(CGSize)size {
  if (YKCGSizeIsEqual(size, CGSizeZero)) return CGRectZero;
  CGRect leftRect = [self rectForLeftButton:size];
  CGRect rightRect = [self rectForRightButton:size];
  
  CGFloat maxContentWidth = (size.width - (leftRect.size.width + rightRect.size.width + 20));
  CGSize contentSize = [_contentView sizeThatFits:CGSizeMake(maxContentWidth, size.height)];
  if (contentSize.width > maxContentWidth) contentSize.width = maxContentWidth;
  if (YKCGSizeIsZero(contentSize)) contentSize = _defaultContentViewSize;
  // Let the content center adjust up a tiny bit
  CGRect contentCenter = YKCGRectToCenter(contentSize, CGSizeMake(size.width, size.height - 1));
  contentCenter.origin.y += self.topInset;
  
  // If content view width is more than the max, then left align.
  // If the left position of the content will overlap the left button, then also left align.
  // If the right position of the content will overlap the right button, then right align.
  // If the right position content centered content will overlap the right button, then fill exactly between left and right.
  // Otherwise center it.
  if (contentCenter.origin.x > maxContentWidth || contentCenter.origin.x < leftRect.size.width + 10) {
    return CGRectMake(leftRect.origin.x + leftRect.size.width + 5, contentCenter.origin.y, maxContentWidth, contentSize.height);
  } else if (!_leftButton && _rightButton && contentCenter.origin.x + contentCenter.size.width > (rightRect.origin.x - 10)) {
    return CGRectMake(rightRect.origin.x - maxContentWidth - 10, contentCenter.origin.y, maxContentWidth, contentSize.height);
  } else if (_leftButton && _rightButton && contentCenter.origin.x + contentCenter.size.width > (rightRect.origin.x - 10)) {
    return CGRectMake(leftRect.origin.x + leftRect.size.width + 5, contentCenter.origin.y, maxContentWidth, contentSize.height);
  } else {
    return CGRectMake(contentCenter.origin.x, contentCenter.origin.y, contentSize.width, contentSize.height);
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];  
  _leftButton.frame = [self rectForLeftButton:self.frame.size];
  _rightButton.frame = [self rectForRightButton:self.frame.size];
  _contentView.frame = [self rectForContentView:self.frame.size];
}

- (CGSize)sizeThatFits:(CGSize)size {
  return CGSizeMake(size.width, 44);
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:20];
    _titleLabel.minimumFontSize = 16;
    _titleLabel.numberOfLines = 1;
    _titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.opaque = NO;
    _titleLabel.contentMode = UIViewContentModeCenter;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.userInteractionEnabled = NO;
  }
  return _titleLabel;
}

- (void)setTitle:(NSString *)title animated:(BOOL)animated {
  // For animated title transitions, we need to create a new titleLabel
  // so we can crossfade it with the old one
  if (animated) {
    UILabel *titleLabel = [self.titleLabel yk_copy];
    [_titleLabel release];
    _titleLabel = titleLabel;
  }
  self.titleLabel.text = title;
  [self.titleLabel sizeToFit];
  [self setContentView:self.titleLabel animated:animated];
}

- (void)setContentView:(UIView *)contentView {
  [self setContentView:contentView animated:NO];
}

- (void)setContentView:(UIView *)contentView animated:(BOOL)animated {
  if (contentView) {
    contentView.contentMode = UIViewContentModeCenter;
  }
  
  if (animated) {
    UIView *oldContentView = _contentView;    
    _contentView = contentView;
    if (_contentView) {
      _contentView.alpha = 0.0;
      _defaultContentViewSize = _contentView.frame.size;
      _contentView.frame = [self rectForContentView:self.frame.size];
      [self addSubview:_contentView];
    }
    [UIView animateWithDuration:0.5 animations:^{
      oldContentView.alpha = 0.0;
      _contentView.alpha = 1.0;
    } completion:^(BOOL finished) {
      [oldContentView removeFromSuperview];
      oldContentView.alpha = 1.0;
    }];
  } else {
    CGPoint contentViewOrigin = CGPointZero;
    if (_contentView) contentViewOrigin = _contentView.frame.origin;
    [_contentView removeFromSuperview];
    _contentView = nil;
    if (contentView) {
      _contentView = contentView;
      _defaultContentViewSize = contentView.frame.size;
      _contentView.frame = CGRectMake(contentViewOrigin.x, contentViewOrigin.y, contentView.frame.size.width, contentView.frame.size.height);
      [self addSubview:_contentView];
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
  }
}

- (void)setLeftButton:(UIView *)leftButton {
  [self setLeftButton:leftButton style:YKUINavigationButtonStyleDefault animated:NO];
}

- (void)setLeftButton:(UIView *)leftButton style:(YKUINavigationButtonStyle)style animated:(BOOL)animated {
  if (animated) {
    UIView *oldLeftButton = _leftButton;
    CGFloat startAlpha = leftButton.alpha;
    _leftButton = leftButton;
    if (_leftButton) {
      _leftButton.alpha = 0.0;
      _leftButton.frame = [self rectForLeftButton:self.frame.size];
      [self addSubview:_leftButton];
    }
    [UIView animateWithDuration:0.5 animations:^{
      oldLeftButton.alpha = 0.0;
      _leftButton.alpha = startAlpha;
    } completion:^(BOOL finished) {
      [oldLeftButton removeFromSuperview];
      oldLeftButton.alpha = 1.0;
    }];
  } else {
    [_leftButton removeFromSuperview];
    _leftButton = nil;
    if (leftButton) {
      _leftButton = leftButton;
      [self addSubview:_leftButton];
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
  }
}

- (void)setRightButton:(UIView *)rightButton {
  [self setRightButton:rightButton style:YKUINavigationButtonStyleDefault animated:NO];
}

- (void)setRightButton:(UIView *)rightButton style:(YKUINavigationButtonStyle)style animated:(BOOL)animated {
  if (animated) {
    UIView *oldRightButton = _rightButton;
    CGFloat startAlpha = rightButton.alpha;
    _rightButton = rightButton;
    if (_rightButton) {
      _rightButton.alpha = 0.0;
      _rightButton.frame = [self rectForRightButton:self.frame.size];
      [self addSubview:_rightButton];
    }
    [UIView animateWithDuration:0.5 animations:^{
      oldRightButton.alpha = 0.0;
      _rightButton.alpha = startAlpha;
    } completion:^(BOOL finished) {
      [oldRightButton removeFromSuperview];
      oldRightButton.alpha = 1.0;
    }];
  } else {
    [_rightButton removeFromSuperview];
    _rightButton = nil;
    if (rightButton) {
      _rightButton = rightButton;
      [self addSubview:_rightButton];
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
  }
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
