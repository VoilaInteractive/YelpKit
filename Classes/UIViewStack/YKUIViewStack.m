//
//  YKUIViewStack.m
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

#import "YKUIViewStack.h"
#import "YKCGUtils.h"
#import "YKSUIInternalView.h"

@implementation YKUIViewStack

@synthesize defaultOptions=_defaultOptions, defaultDuration=_defaultDuration;

- (id)init {
  if ((self = [super init])) {
    _stack = [[NSMutableArray alloc] init];
    _defaultOptions = YKSUIViewAnimationOptionTransitionSlide|YKSUIViewAnimationOptionCurveLinear;
    _defaultDuration = 0.25;
  }
  return self;
}

- (id)initWithParentView:(UIView *)parentView {
  if ((self = [self init])) {
    _parentView = parentView;
  }
  return self;
}

- (void)dealloc {
  [_stack release];
  [super dealloc];
}

- (void)pushView:(YKSUIView *)view animated:(BOOL)animated {
  [self pushView:view duration:(animated ? _defaultDuration : 0) options:(animated ? _defaultOptions : 0)];
}

- (void)popView:(YKSUIView *)view animated:(BOOL)animated {
  [self popView:view duration:(animated ? _defaultDuration : 0) options:(animated ? _defaultOptions : 0)];
}

- (void)pushView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  YKSUIInternalView *fromInternalView = [_stack lastObject];
  [self _addView:view fromInternalView:fromInternalView duration:duration options:options];
}

- (void)_removeInBetweenIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
  // Remove intermediate views
  // TODO(gabe): This seems out of order
  NSInteger intermediateCount = fromIndex - toIndex - 1;
  if (intermediateCount > 0) {
    NSArray *viewsToRemove = [_stack subarrayWithRange:NSMakeRange(toIndex + 1, intermediateCount)];
    for (YKSUIInternalView *viewToRemove in viewsToRemove) {
      [viewToRemove viewWillDisappear:YES];
      [viewToRemove viewDidDisappear:YES];
      viewToRemove.view.stack = nil;
      [_stack removeObject:viewToRemove];
    }
  }
}

- (void)popToView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  NSInteger toIndex = [self indexOfView:view];
  if (toIndex == NSNotFound) return;
  YKSUIInternalView *toInternalView = [_stack gh_objectAtIndex:toIndex];
  NSInteger fromIndex = [_stack count] - 1;
  YKSUIInternalView *fromInternalView = [_stack lastObject];
  [self _removeInBetweenIndex:fromIndex toIndex:toIndex];
  [self _removeInternalView:fromInternalView toInternalView:toInternalView duration:0 options:0 completion:NULL];
}

- (void)popView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  YKSUIInternalView *fromInternalView = [_stack lastObject];
  if (!fromInternalView || ![fromInternalView.view isEqual:view]) return;
  YKSUIInternalView *toInternalView = [_stack gh_objectAtIndex:[_stack count] - 2];
  [self _removeInternalView:fromInternalView toInternalView:toInternalView duration:duration options:options completion:NULL];  
}

- (void)swapView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  YKSUIInternalView *fromInternalView = [_stack lastObject];
  
  YKSUIInternalView *toInternalView = [[[YKSUIInternalView alloc] init] autorelease];
  [toInternalView setView:view];
  toInternalView.view.stack = self;
  [_stack addObject:toInternalView];
  
  [self _removeInternalView:fromInternalView toInternalView:toInternalView duration:duration options:options completion:NULL];
}

- (void)setView:(YKSUIView *)view duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {  
  if ([_stack count] == 0) {
    [self _addView:view fromInternalView:nil duration:duration options:options];
  } else {
    NSInteger toIndex = 0;
    YKSUIInternalView *toInternalView = [[[YKSUIInternalView alloc] init] autorelease];
    [toInternalView setView:view];
    toInternalView.view.stack = self;
    [_stack insertObject:toInternalView atIndex:0];
    
    NSInteger fromIndex = [_stack count] - 1;
    YKSUIInternalView *fromInternalView = [_stack lastObject];
    [self _removeInBetweenIndex:fromIndex toIndex:toIndex];
    [self _removeInternalView:fromInternalView toInternalView:toInternalView duration:duration options:options completion:NULL];  
  }
}

- (void)_removeAnimationsFromInternalView:(YKSUIInternalView *)fromInternalView toInternalView:(YKSUIInternalView *)toInternalView duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options animations:(void (^)())animations completion:(void (^)(BOOL finished))completion {
  [fromInternalView viewWillDisappear:YES];
  [toInternalView viewWillAppear:YES];
  if (![toInternalView superview]) [_parentView addSubview:toInternalView];
  [UIView animateWithDuration:duration delay:0 options:[self _animationOptions:options motion:NO] animations:animations completion:^(BOOL finished) {
    [fromInternalView removeFromSuperview];
    [fromInternalView viewDidDisappear:YES];
    [toInternalView viewDidAppear:YES];
    fromInternalView.view.stack = nil;
    if (completion) completion(finished);
    if (fromInternalView) [_stack removeObject:fromInternalView];
  }];
}

- (void)_setupToShowInternalView:(YKSUIInternalView *)internalView {
  internalView.frame = CGRectMake(_parentView.frame.size.width, 20, _parentView.frame.size.width, _parentView.frame.size.height - 20);
}

- (void)_showInternalView:(YKSUIInternalView *)internalView {
  internalView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
  internalView.frame = CGRectMake(0, 20, _parentView.frame.size.width, _parentView.frame.size.height - 20);
}

- (void)_removeInternalView:(YKSUIInternalView *)fromInternalView toInternalView:(YKSUIInternalView *)toInternalView duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion {
  
  if ((options & YKSUIViewAnimationOptionTransitionSlide) == YKSUIViewAnimationOptionTransitionSlide) {
    [self _removeAnimationsFromInternalView:fromInternalView toInternalView:toInternalView duration:duration options:options animations:^{
      fromInternalView.frame = CGRectMake(_parentView.frame.size.width, 20, _parentView.frame.size.width, _parentView.frame.size.height - 20);
      [self _showInternalView:toInternalView];
    } completion:completion];
  } else if ((options & YKSUIViewAnimationOptionTransitionSlideOver) == YKSUIViewAnimationOptionTransitionSlideOver) {
    [self _removeAnimationsFromInternalView:fromInternalView toInternalView:toInternalView duration:duration options:options animations:^{
      fromInternalView.frame = CGRectMake(_parentView.frame.size.width, 20, _parentView.frame.size.width, _parentView.frame.size.height - 20);                  
      [self _showInternalView:toInternalView];
    } completion:completion];
  } else if (fromInternalView && toInternalView) {    
    [self _showInternalView:toInternalView];
    [toInternalView viewWillAppear:YES];
    [fromInternalView viewWillDisappear:YES];
    if (duration > 0) {
      [UIView transitionFromView:fromInternalView toView:toInternalView duration:duration options:[self _animationOptions:options motion:YES] completion:^(BOOL finished) {      
        [fromInternalView viewDidDisappear:YES];
        fromInternalView.view.stack = nil;
        [toInternalView viewDidAppear:YES];
        if (completion) completion(YES);
        [_stack removeObject:fromInternalView];
      }];
    } else {
      [_parentView addSubview:toInternalView];
      [fromInternalView viewDidDisappear:YES];
      fromInternalView.view.stack = nil;
      [toInternalView viewDidAppear:YES];
      if (completion) completion(YES);
      [_stack removeObject:fromInternalView];
    }
  } else if (fromInternalView) {
    [fromInternalView viewWillDisappear:YES];
    [fromInternalView removeFromSuperview];
    [fromInternalView viewDidDisappear:YES];
    fromInternalView.view.stack = nil;
    if (completion) completion(YES);
    [_stack removeObject:fromInternalView];
  }
}

                                                                                                                                                                                                                            
- (void)_addAnimationsForView:(YKSUIView *)view fromInternalView:(YKSUIInternalView *)fromInternalView toInternalView:(YKSUIInternalView *)toInternalView duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options animations:(void (^)())animations {
  
  [self _setupToShowInternalView:toInternalView];
  [toInternalView viewWillAppear:YES];
  [_parentView addSubview:toInternalView];
  [fromInternalView viewWillDisappear:YES];
  [UIView animateWithDuration:duration delay:0 options:[self _animationOptions:options motion:NO] animations:animations completion:^(BOOL finished) {
    [fromInternalView viewDidDisappear:YES];
    [toInternalView viewDidAppear:YES];  
  }];
}
                                                                                                                                                                                                                            
- (void)_addView:(YKSUIView *)view fromInternalView:(YKSUIInternalView *)fromInternalView duration:(NSTimeInterval)duration options:(YKSUIViewAnimationOptions)options {
  YKSUIInternalView *toInternalView = [[[YKSUIInternalView alloc] init] autorelease];
  [toInternalView setView:view];
  toInternalView.view.stack = self;
  [_stack addObject:toInternalView];
  
  if ((options & YKSUIViewAnimationOptionTransitionSlide) == YKSUIViewAnimationOptionTransitionSlide) {
    [self _setupToShowInternalView:toInternalView];
    [self _addAnimationsForView:view fromInternalView:fromInternalView toInternalView:toInternalView duration:duration options:options animations:^{
      fromInternalView.frame = CGRectMake(-_parentView.frame.size.width, 20, _parentView.frame.size.width, _parentView.frame.size.height - 20);
      [self _showInternalView:toInternalView];      
    }];
  } else if ((options & YKSUIViewAnimationOptionTransitionSlideOver) == YKSUIViewAnimationOptionTransitionSlideOver) {
    [self _setupToShowInternalView:toInternalView];
    [self _addAnimationsForView:view fromInternalView:fromInternalView toInternalView:toInternalView duration:duration options:options animations:^{
      if (CATransform3DIsIdentity(fromInternalView.layer.transform)) {
        fromInternalView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
      }
      [self _showInternalView:toInternalView];
    }];
  } else {
    toInternalView.frame = CGRectMake(0, 20, _parentView.frame.size.width, _parentView.frame.size.height - 20);
    [toInternalView viewWillAppear:YES];
    [fromInternalView viewWillDisappear:YES];
    [UIView transitionWithView:_parentView duration:duration options:[self _animationOptions:options motion:YES] animations:^{
      [_parentView addSubview:toInternalView];
    } completion:^(BOOL finished) {
      [fromInternalView viewDidDisappear:YES];
      [toInternalView viewDidAppear:YES];      
    }];
  }
}

- (NSInteger)indexOfView:(YKSUIView *)view {
  for (NSInteger i = 0, count = [_stack count]; i < count; i++) {
    YKSUIInternalView *internalView = _stack[i];
    if ([internalView.view isEqual:view]) return i;
  }
  return NSNotFound;
}

- (BOOL)isVisibleView:(YKSUIView *)view {
  return [view isEqual:[self visibleView]];
}

- (BOOL)isRootView:(YKSUIView *)view {
  return [view isEqual:[self rootView]];
}

- (YKSUIView *)visibleView {
  YKSUIInternalView *internalView = [_stack lastObject];
  return internalView.view;
}

- (YKSUIView *)rootView {
  YKSUIInternalView *internalView = [_stack gh_firstObject];
  return internalView.view;
}

#define ConvertAnimationOption(__OPTIONS__, __OPTION__, __ANIMATION_OPTIONS__, __ANIMATION_OPTION__) do {\
if ((__OPTIONS__ & __OPTION__) == __OPTION__) { \
  __ANIMATION_OPTIONS__ |= __ANIMATION_OPTION__; \
} \
} while (0)

- (UIViewAnimationOptions)_animationOptions:(YKSUIViewAnimationOptions)options motion:(BOOL)motion {
  UIViewAnimationOptions animationOptions = 0;
  ConvertAnimationOption(options, YKSUIViewAnimationOptionCurveEaseInOut, animationOptions, UIViewAnimationOptionCurveEaseInOut);
  ConvertAnimationOption(options, YKSUIViewAnimationOptionCurveEaseIn, animationOptions, UIViewAnimationOptionCurveEaseIn);
  ConvertAnimationOption(options, YKSUIViewAnimationOptionCurveEaseOut, animationOptions, UIViewAnimationOptionCurveEaseOut);
  ConvertAnimationOption(options, YKSUIViewAnimationOptionCurveLinear, animationOptions, UIViewAnimationOptionCurveLinear);
  
  if (motion) {
    ConvertAnimationOption(options, YKSUIViewAnimationOptionTransitionFlipFromLeft, animationOptions, UIViewAnimationOptionTransitionFlipFromLeft);
    ConvertAnimationOption(options, YKSUIViewAnimationOptionTransitionFlipFromRight, animationOptions, UIViewAnimationOptionTransitionFlipFromRight);
    ConvertAnimationOption(options, YKSUIViewAnimationOptionTransitionCurlUp, animationOptions, UIViewAnimationOptionTransitionCurlUp);
    ConvertAnimationOption(options, YKSUIViewAnimationOptionTransitionCurlDown, animationOptions, UIViewAnimationOptionTransitionCurlDown);
    ConvertAnimationOption(options, YKSUIViewAnimationOptionTransitionCrossDissolve, animationOptions, UIViewAnimationOptionTransitionCrossDissolve);
    ConvertAnimationOption(options, YKSUIViewAnimationOptionTransitionFlipFromTop, animationOptions, UIViewAnimationOptionTransitionFlipFromTop);
    ConvertAnimationOption(options, YKSUIViewAnimationOptionTransitionFlipFromBottom, animationOptions, UIViewAnimationOptionTransitionFlipFromBottom);    
  }
  return animationOptions;
}

@end
