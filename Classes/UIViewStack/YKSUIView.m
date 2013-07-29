//
//  YKSUIView.m
//  YelpKit
//
//  Created by Gabriel Handford on 7/5/12.
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

#import "YKSUIView.h"
#import "YKUIViewStack.h"

@implementation YKSUIView

@synthesize navigationBar=_navigationBar, visible=_visible, needsRefresh=_needsRefresh, stack=_stack, view=_view;

- (void)sharedInit {
  [super sharedInit];
  self.layout = [YKLayout layoutForView:self];
  self.backgroundColor = [UIColor blackColor];
  self.opaque = YES;
  self.layout = [YKLayout layoutForView:self];
  _navigationItem = [[UINavigationItem alloc] init];
}

- (void)dealloc {
  [_navigationBar release];
  [_navigationItem release];
  [super dealloc];
}

- (NSString *)description {
  return GHDescription(@"view");
}

- (CGSize)layout:(id<YKLayout>)layout size:(CGSize)size {
  _view.frame = CGRectMake(0, 0, size.width, size.height);
  return size;
}

+ (YKSUIView *)viewWithView:(UIView *)view {
  return [self viewWithView:view title:nil];
}

+ (YKSUIView *)viewWithView:(UIView *)view title:(NSString *)title {
  YKSUIView *viewForStack = [[[YKSUIView alloc] init] autorelease];
  viewForStack.view = view;
  [viewForStack.navigationBar setTitle:title];
  return viewForStack;
}

- (void)setView:(UIView *)view {
  [view retain];
  [_view removeFromSuperview];
  _view = view;
  if (_view) {
    [self addSubview:_view];
  }
  [view release];
}

- (YKUINavigationBar *)navigationBar {
  if (!_navigationBar) {
    _navigationBar = [[YKUINavigationBar alloc] init];
    [_navigationBar pushNavigationItem:_navigationItem animated:NO];
    [self applyStyleForNavigationBar:_navigationBar];
  }
  return _navigationBar;
}

- (void)pushView:(YKSUIView *)view animated:(BOOL)animated {
  [_stack pushView:view animated:animated];
}

- (void)popViewAnimated:(BOOL)animated {
  [_stack popView:self animated:animated];
}

- (void)pushView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  [_stack pushView:view duration:duration options:options];
}

- (void)popViewWithDuration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  [_stack popView:self duration:duration options:options];
}

- (void)setView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  [_stack setView:view duration:duration options:options];
}

- (void)swapView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  [_stack swapView:view duration:duration options:options];
}

- (void)popToView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  [_stack popToView:view duration:duration options:options];
}

- (BOOL)isRootView {
  return [_stack isRootView:self];
}

- (BOOL)isVisibleView {
  return [_stack isVisibleView:self];
}

- (YKUIButton *)setNavigationButtonWithTitle:(NSString *)title iconImage:(UIImage *)iconImage position:(YKUINavigationPosition)position style:(YKUINavigationButtonStyle)style animated:(BOOL)animated target:(id)target action:(SEL)action {
  YKUIButton *button = [[YKUIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
  button.title = title;
  button.iconImage = iconImage;
  [button setTarget:target action:action];
  [self applyStyleForNavigationButton:button style:style];
  switch (position) {
    case YKUINavigationPositionLeft:
      _navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
      break;
    case YKUINavigationPositionRight:
      _navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
      break;
  }
  
  return [button autorelease];
}

- (void)_updateBackButton {
  // Set back button on navigation bar if not left button
  if (_navigationBar && !_navigationItem.leftBarButtonItem) {
    NSUInteger index = [_stack indexOfView:self];
    if (index > 0 && index != NSNotFound) {      
      
      // TODO(gabe): Back title?
      NSString *backTitle = NSLocalizedString(@"Back", nil);
      if (!backTitle || [backTitle length] > 8) backTitle = NSLocalizedString(@"Back", nil);
      YKUIButton *backButton = [[[YKUIButton alloc] init] autorelease];
      backButton.title = backTitle;
      backButton.borderStyle = YKUIBorderStyleRoundedBack;
      [self applyStyleForNavigationButton:backButton style:YKUINavigationButtonStyleBack];
      [backButton setTarget:self action:@selector(_back)];
      _navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    }
  }
}

- (void)_back {
  [self popViewAnimated:YES];
}

- (void)_viewWillAppear:(BOOL)animated { 
  _visible = YES;
  [self _updateBackButton];
  [self refreshIfNeeded];
  [self viewWillAppear:animated];
}

- (void)_viewDidAppear:(BOOL)animated {
  [self viewDidAppear:animated];
}

- (void)_viewWillDisappear:(BOOL)animated {
  [self viewWillDisappear:animated];
  _visible = NO;
}

- (void)_viewDidDisappear:(BOOL)animated {
  [self _viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated { }

- (void)viewDidAppear:(BOOL)animated { }

- (void)viewWillDisappear:(BOOL)animated { }

- (void)viewDidDisappear:(BOOL)animated { }

- (void)refresh { }

- (void)refreshIfNeeded {
  if (_needsRefresh) {
    _needsRefresh = NO;
    [self refresh];
  }
}

- (void)setNeedsRefresh {
  _needsRefresh = YES;
  if (_visible) {
    [self refreshIfNeeded];
  }
}

#pragma mark Style

- (void)applyStyleForNavigationButton:(YKUIButton *)button style:(YKUINavigationButtonStyle)style {
  button.titleFont = [UIFont boldSystemFontOfSize:12];
  button.insets = UIEdgeInsetsMake(0, 8, 0, 8);
  button.titleColor = [UIColor whiteColor];
  button.margin = UIEdgeInsetsMake(6, 0, 6, 0);
  button.cornerRadius = 4.0;
  button.borderWidth = 0.5;
  button.titleShadowColor = [UIColor colorWithWhite:0 alpha:0.5];
  button.titleShadowOffset = CGSizeMake(0, -1);
  button.shadingType = YKUIShadingTypeLinear;
  button.color = [UIColor colorWithRed:98.0f/255.0f green:120.0f/255.0f blue:170.0f/255.0f alpha:1.0];
  button.color2 = [UIColor colorWithRed:64.0f/255.0f green:90.0f/255.0f blue:136.0f/255.0f alpha:1.0];
  button.highlightedShadingType = YKUIShadingTypeLinear;
  button.highlightedColor = [UIColor colorWithRed:70.0f/255.0f green:92.0f/255.0f blue:138.0f/255.0f alpha:1.0];
  button.highlightedColor2 = [UIColor colorWithRed:44.0f/255.0f green:70.0f/255.0f blue:126.0f/255.0f alpha:1.0];
  button.borderColor = [UIColor colorWithRed:87.0f/255.0f green:100.0f/255.0f blue:153.0f/255.0f alpha:1.0];
  
  CGSize size = [button sizeThatFitsTitle:CGSizeMake(120, 999) minWidth:55];
  button.frame = CGRectMake(0, 0, size.width, 30 + button.margin.top + button.margin.bottom);
}

- (void)applyStyleForNavigationBar:(YKUINavigationBar *)navigationBar {
  //TODO(ahaefner): FIX THIS.  It no longer applies
  navigationBar.backgroundColor = [UIColor colorWithRed:98.0f/255.0f green:120.0f/255.0f blue:170.0f/255.0f alpha:1.0];
  //navigationBar.topBorderColor = [UIColor colorWithRed:87.0f/255.0f green:100.0f/255.0f blue:153.0f/255.0f alpha:1.0];
  //navigationBar.bottomBorderColor = [UIColor colorWithRed:87.0f/255.0f green:100.0f/255.0f blue:153.0f/255.0f alpha:1.0];
}

@end
