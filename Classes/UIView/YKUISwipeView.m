//
//  YKUISwipeView.m
//  YelpKit
//
//  Created by Gabriel Handford on 3/26/12.
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

#import "YKUISwipeView.h"
#import "YKDefines.h"

@interface YKUISwipeScrollView : UIScrollView
@end

@implementation YKUISwipeScrollView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  // Since the scroll view won't clip to its bounds, it should contain any point in its superview;
  // otherwise it won't receive touches outside of its bounds although its content may be visible.
  return [self.superview pointInside:[self.superview convertPoint:point fromView:self] withEvent:event];
}

@end

@implementation YKUISwipeView

@synthesize currentViewDidChangeBlock=_changeBlock;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _scrollView = [[YKUISwipeScrollView alloc] init];
    _scrollView.pagingEnabled = YES;
    _scrollView.clipsToBounds = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    [_scrollView release];
    
    _peekWidth = 20;
    _insets = UIEdgeInsetsMake(0, 10, 0, 10);
  }
  return self;
}

- (void)dealloc {
  [_views release];
  _scrollView.delegate = nil;
  Block_release(_changeBlock);
  [super dealloc];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  // Disable swipe when we only have 1 view.
  // Otherwise setup the peek.
  if ([_views count] == 1) {
    UIView *view = _views[0];
    view.frame = CGRectMake(_insets.left, _insets.top, self.frame.size.width - _insets.left - _insets.right, self.frame.size.height - _insets.top - _insets.bottom);
    [view setNeedsLayout];
    _scrollView.alwaysBounceHorizontal = NO;    
    _scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    
  } else {
    __block CGFloat x = 0;
    [_views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger viewIndex, BOOL *stop) {
      CGFloat viewWidth = [self _viewWidth:self.frame.size.width forViewIndex:viewIndex];
      view.frame = CGRectMake(x, _insets.top, viewWidth, self.frame.size.height - _insets.top - _insets.bottom);
      [view setNeedsLayout];
      x += viewWidth + _insets.right;
    }];

    // ScrollView frame width defines the page width, so it must be view width + separation.
    CGFloat scrollViewWidth = [self _usableWidth:self.frame.size.width] + _insets.right;

    // Subtract peekWidth so the last page doesn't leave room to peek a nonexistant view.
    CGFloat scrollContentWidth = x - _peekWidth;

    if (_peekPrevious) {
      // Since we are peeking both ways we need to further shrink our content
      scrollViewWidth -= _peekWidth;
      scrollContentWidth -= _peekWidth;
    }
    
    _scrollView.alwaysBounceHorizontal = YES;
    // ScrollView frame width defines the page width, so it must be view width + separation.
    _scrollView.frame = CGRectMake(_insets.left, 0, scrollViewWidth, self.frame.size.height);
    // Subtract peekWidth so the last page doesn't leave room to peek a nonexistant view.
    _scrollView.contentSize = CGSizeMake(scrollContentWidth, self.frame.size.height);
  }
}

- (void)setViews:(NSArray *)views {
  [views retain];
  for (UIView *view in _views) {
    [view removeFromSuperview];
  }
  [_views release];
  _views = views;
  
  for (UIView *view in _views) {
    [_scrollView addSubview:view];
  }
  // Reset scroll view content offset
  _scrollView.contentOffset = CGPointZero;
  _currentViewIndex = 0;
  [self setNeedsDisplay];
  [self setNeedsLayout];
}

- (UIView *)currentView {
  return (UIView *)[_views gh_objectAtIndex:self.currentViewIndex];
}

- (void)setCurrentViewIndex:(NSUInteger)index {
  [self setCurrentViewIndex:index animated:NO];
}

- (void)setCurrentViewIndex:(NSUInteger)index animated:(BOOL)animated {
  if (index >= _views.count || index == _currentViewIndex) return;

  CGFloat offsetX = index * _scrollView.frame.size.width;
  // Account for peekwidth if this is the last view (and not the only view)
  if (_views.count > 1 && index == _views.count - 1) {
    offsetX -= _peekWidth;
  }
  CGPoint offset = CGPointMake(offsetX, _scrollView.contentOffset.y);

  if (animated) {
    [UIView animateWithDuration:0.5 animations:^{
      _scrollView.contentOffset = offset;
    } completion:^(BOOL finished){
      _currentViewIndex = index;
      [self currentViewDidChangeSwiped:NO];
    }];
  } else {
    _scrollView.contentOffset = offset;
    _currentViewIndex = index;
    [self currentViewDidChangeSwiped:NO];
  }
}

- (void)currentViewDidChangeSwiped:(BOOL)swiped {
  if (_changeBlock) _changeBlock(self, swiped);
}

- (CGFloat)_usableWidth:(CGFloat)width {
  return width - _insets.left - _insets.right - _peekWidth;
}

- (CGFloat)_viewWidth:(CGFloat)width forViewIndex:(NSUInteger)viewIndex {
  CGFloat viewWidth = [self _usableWidth:width];
  if (_peekPrevious && viewIndex > 0 && viewIndex < _views.count - 1) {
    // If our swipe view is a sandwich then the two end pieces of toast are squishing the tasty filling views inside. The filling views need to be a bit smaller to peek part of the previous view as well as the next view.
    viewWidth -= _peekWidth;
  }
  
  return viewWidth;
}

- (CGSize)sizeThatFits:(CGSize)size {
  __block CGSize sizeThatFits = CGSizeMake(size.width, 0);
  [_views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger viewIndex, BOOL *stop) {
    CGSize sizeThatFitsView = [view sizeThatFits:CGSizeMake([self _viewWidth:size.width forViewIndex:viewIndex], size.height)];
    sizeThatFits.height = MAX(sizeThatFits.height, sizeThatFitsView.height);
  }];
  return sizeThatFits;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  CGFloat nearIndex = _scrollView.contentOffset.x / _scrollView.frame.size.width;
  // Round up to an integer, or if nearly integral round to the nearest integer.
  nearIndex = YKIsEqualWithAccuracy(fmodf(nearIndex, 1), 0, 0.01) ? roundf(nearIndex) : ceilf(nearIndex);
  if (nearIndex >= 0 && nearIndex < _views.count) {
    NSUInteger index = (NSUInteger)nearIndex;
    if (index != _currentViewIndex) {
      _currentViewIndex = index;
      [self currentViewDidChangeSwiped:YES];
    }
  }
}

@end
