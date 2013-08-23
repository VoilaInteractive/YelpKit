//
//  YKUISwipeView.h
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

@class YKUISwipeView;

/*!
 Block to be called when the currently visible view of a YKUISwipeView changes.

 @param swipeView YKUISwipeView whose currently visible view changed
 @param swiped Whether the change was caused by the user swiping
 */
typedef void (^YKUISwipeViewDidChangeBlock)(YKUISwipeView *swipeView, BOOL swiped);

/*!
 Swipe view.
 */
@interface YKUISwipeView : UIView <UIScrollViewDelegate> {
  YKUISwipeViewDidChangeBlock _changeBlock;
}

@property (readonly, nonatomic) UIScrollView *scrollView;

/*!
 Amount of space to make the next view visible.
 */
@property (assign, nonatomic) CGFloat peekWidth;

/*!
 Whether to peek part of the previous view as well.
 */
@property (assign, nonatomic) BOOL peekPrevious;

/*!
 Amount of space in between views.
 */
@property (assign, nonatomic) UIEdgeInsets insets;

/*!
 Subviews.
 */
@property (retain, nonatomic) NSArray *views;

/*!
 Currently visible subview.
 */
@property (readonly, nonatomic) UIView *currentView;

/*!
 Block to be called when the currently visible subview changes.
 */
@property (copy, nonatomic) YKUISwipeViewDidChangeBlock currentViewDidChangeBlock;

/*!
 Index of the currently visible subview in the views array.
 */
@property (assign, nonatomic) NSUInteger currentViewIndex;

/*!
 Sets the currently visible subview.

 @param index Index of the view in the views array
 @param animated Whether to animate the transition
 */
- (void)setCurrentViewIndex:(NSUInteger)index animated:(BOOL)animated;

/*!
 Called when the currently visible subview changes.

 Subclasses can override this method to perform custom tasks when the change occurs.
 If you override this method, you must call super at some point in your implementation.

 @param swiped Whether the change was caused by the user swiping
 */
- (void)currentViewDidChangeSwiped:(BOOL)swiped;

@end
