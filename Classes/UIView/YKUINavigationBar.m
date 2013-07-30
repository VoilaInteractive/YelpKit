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
  _navigationItem = [[UINavigationItem alloc] init];
  [self pushNavigationItem:_navigationItem animated:NO];
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
  [_navigationItem release];
  [super dealloc];
}

- (void)setTopInset:(CGFloat)topInset {
  _topInset = topInset;
  self.frame = YKCGRectSetHeight(self.frame, 44 + (2 * _topInset));
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
    _titleLabel.shadowColor = [UIColor darkGrayColor];
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
  UIView *oldContentView = _contentView;
  _contentView = contentView;
  if (animated) {
    // In order to position the views properly, we get their frames in the titleView (which lies in the NavigationBar) and then put them both into the NavigationBar with centered frames for animating.
    CGRect oldContentFrame = _navigationItem.titleView.frame;
    _navigationItem.titleView = _contentView;
    CGRect newContentFrame = _navigationItem.titleView.frame;
    _contentView.frame = newContentFrame;
    oldContentView.frame = oldContentFrame;
    _contentView.alpha = 0.0;
    [self addSubview:_contentView];
    [self addSubview:oldContentView];
    [UIView animateWithDuration:0.3
                     animations:^{
                       _contentView.alpha = 1.0;
                       oldContentView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                       [oldContentView removeFromSuperview];
                       _navigationItem.titleView = _contentView;
                     }];
  } else {
    _navigationItem.titleView = _contentView;
  }
}

- (void)setLeftButton:(UIView *)leftButton {
  [self setLeftButton:leftButton style:YKUINavigationButtonStyleDefault animated:NO];
}

- (void)setLeftButton:(UIView *)leftButton style:(YKUINavigationButtonStyle)style animated:(BOOL)animated {
  _leftButton = leftButton;
  [_navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:_leftButton] autorelease] animated:animated];
}

- (void)setRightButton:(UIView *)rightButton {
  [self setRightButton:rightButton style:YKUINavigationButtonStyleDefault animated:NO];
}

- (void)setRightButton:(UIView *)rightButton style:(YKUINavigationButtonStyle)style animated:(BOOL)animated {
  _rightButton = rightButton;
  [_navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithCustomView:_rightButton] autorelease] animated:animated];
}

@end
