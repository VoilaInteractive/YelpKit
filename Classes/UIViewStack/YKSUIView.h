//
//  YKSUIView.h
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

#import "YKUILayoutView.h"
#import "YKUINavigationBar.h"
#import "YKUIButton.h"

@class YKUIViewStack;
@class YKTUIViewController;

enum {
  YKSUIViewAnimationOptionCurveEaseInOut = 1 << 0,
  YKSUIViewAnimationOptionCurveEaseIn = 1 << 1,
  YKSUIViewAnimationOptionCurveEaseOut = 1 << 2,
  YKSUIViewAnimationOptionCurveLinear = 1 << 3,
  
  YKSUIViewAnimationOptionTransitionFlipFromLeft = 1 << 5,
  YKSUIViewAnimationOptionTransitionFlipFromRight = 1 << 6,
  YKSUIViewAnimationOptionTransitionCurlUp = 1 << 7,
  YKSUIViewAnimationOptionTransitionCurlDown = 1 << 8,
  YKSUIViewAnimationOptionTransitionCrossDissolve = 1 << 9,
  YKSUIViewAnimationOptionTransitionFlipFromTop = 1 << 10,
  YKSUIViewAnimationOptionTransitionFlipFromBottom = 1 << 11,
  YKSUIViewAnimationOptionTransitionSlide = 1 << 12,
  YKSUIViewAnimationOptionTransitionSlideOver = 1 << 13,
};
typedef NSUInteger YKSUIViewAnimationOptions;

@interface YKSUIView : YKUILayoutView {
  YKUINavigationBar *_navigationBar;
    
  YKUIViewStack *_stack;
  
  BOOL _visible;
  BOOL _needsRefresh;
  
  UIView *_view; // Optional content view
}

/*!
 Navigation bar.
 */
@property (readonly, nonatomic) YKUINavigationBar *navigationBar;

/*!
 View stack.
 */
@property (assign, nonatomic) YKUIViewStack *stack;

/*!
 @result YES if visible
 */
@property (readonly, nonatomic, getter=isVisible) BOOL visible;

/*!
 Set if needs refresh.
 If visible, will immediately trigger refresh. Otherwise will call refresh when becoming visible.
 */
@property (assign, nonatomic) BOOL needsRefresh;

/*!
 View (content). Optional.
 */
@property (retain, nonatomic) UIView *view;

/*!
 Create stack view with sub view.
 @param view
 @result View for stack
 */
+ (YKSUIView *)viewWithView:(UIView *)view;

/*!
 Create stack view with sub view.
 @param view
 @param title Navigation title
 @result View for stack
 */
+ (YKSUIView *)viewWithView:(UIView *)view title:(NSString *)title;

/*!
 Push view.
 @param view
 @param duration
 @param options
 */
- (void)pushView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options;

/*!
 Push view, sliding in.
 @param view
 @param animated
 */
- (void)pushView:(YKSUIView *)view animated:(BOOL)animated;

/*!
 Pop view, sliding out.
 @param animated
 */
- (void)popViewAnimated:(BOOL)animated;

/*!
 Set the main view.
 @param view
 @param duration
 @param options
 */
- (void)setView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options;

/*!
 Swap the current view with transition.
 @param view
 @param duration
 @param options
 */
- (void)swapView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options;

/*!
 Pop to view.
 @param view
 @param duration
 @param options
 */
- (void)popToView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options;

/*!
 Pop self.
 @param duration
 @param options
 */
- (void)popViewWithDuration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options;

/*!
 @result YES if root view
 */
- (BOOL)isRootView;

/*!
 @result YES if visible view
 */
- (BOOL)isVisibleView;

/*!
 Set navigation title.
 */
- (void)setNavigationTitle:(NSString *)title animated:(BOOL)animated;

/*!
 Set navigation button with title.
 @param title
 @param iconImage
 @param position
 @param style
 @param animated
 */
- (UIBarButtonItem *)setNavigationButtonWithTitle:(NSString *)title iconImage:(UIImage *)iconImage position:(YKUINavigationPosition)position style:(YKUINavigationButtonStyle)style animated:(BOOL)animated target:(id)target action:(SEL)action;

/*!
 Apply style for navigation button.
 Subclasses should override.
 */
- (void)applyStyleForNavigationButton:(YKUIButton *)button style:(YKUINavigationButtonStyle)style;

/*!
 Apply style for navigation bar.
 Subclasses should override.
 */
- (void)applyStyleForNavigationBar:(YKUINavigationBar *)navigationBar;

/*!
 View will appear.
 @param animated
 */
- (void)viewWillAppear:(BOOL)animated;

/*!
 View did appear.
 @param animated
 */
- (void)viewDidAppear:(BOOL)animated;

/*!
 View will disappear.
 @param animated
 */
- (void)viewWillDisappear:(BOOL)animated;

/*!
 View did disappear.
 @param animated
 */
- (void)viewDidDisappear:(BOOL)animated;

/*!
 Refresh. On success, you should call self.needsRefresh = NO;
 */
- (void)refresh;

/*!
 Set needs refresh. If visible, will call refresh.
 */
- (void)setNeedsRefresh;

#pragma mark Private

- (void)_viewWillAppear:(BOOL)animated;

- (void)_viewDidAppear:(BOOL)animated;

- (void)_viewWillDisappear:(BOOL)animated;

- (void)_viewDidDisappear:(BOOL)animated;

@end



