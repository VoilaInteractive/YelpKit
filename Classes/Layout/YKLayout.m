//
//  YKLayout.m
//  YelpIPhone
//
//  Created by Gabriel Handford on 1/31/11.
//  Copyright 2011 Yelp. All rights reserved.
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

#import "YKLayout.h"
#import "YKCGUtils.h"
#import "YKDefines.h"

static NSMutableDictionary *gDebugStats = NULL;

@implementation YKLayout

@synthesize sizeThatFits=_sizeThatFits, sizing=_sizing;

- (id)init {
  [NSException raise:NSDestinationInvalidException format:@"Layout must be associated with a view; Use initWithView:"];
  return nil;
}

- (id)initWithView:(UIView *)view {
  if ((self = [super init])) {
    
    if (![view respondsToSelector:@selector(layout:size:)]) {
      [NSException raise:NSObjectNotAvailableException format:@"Layout is not supported for this view. Implement layout:size:."];
      return nil;
    }
    
    _cachedSize = CGSizeZero;
    _accessibleElements = [[NSMutableArray alloc] init];
    _view = view;
    _sizeThatFits = CGSizeZero;
    _needsLayout = YES;
    _needsSizing = YES;
#if DEBUG
    YKLayoutStats *stats = [YKLayout statsForView:_view];
    stats->_createCount++;
#endif
  }
  return self;
}

- (void)dealloc {
  [_subviews release];
  [_accessibleElements release];
  [super dealloc];
}

- (NSArray *)accessibleElements {
  return _accessibleElements;
}

+ (YKLayout *)layoutForView:(UIView *)view {
  return [[[YKLayout alloc] initWithView:view] autorelease];
}

- (CGSize)_layout:(CGSize)size sizing:(BOOL)sizing {
  if (!_view) return size;
#if DEBUG
  YKLayoutStats *stats = [YKLayout statsForView:_view];
#endif
  
  if (YKCGSizeIsEqual(size, _cachedSize) && ((!_needsSizing && sizing) || (!_needsLayout && !sizing))) {
#if DEBUG
    stats->_cacheCount++;
#endif
    return _cachedLayoutSize;
  }
  
  _sizing = sizing;
  _cachedSize = size;
  if (!_sizing) {
    // Remove previous accessible elements before they're recreated in layout:size:()
    [_accessibleElements removeAllObjects];
  }
#if DEBUG
  NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
#endif
  CGSize layoutSize = [(id<YKLayoutView>)_view layout:self size:size];
#if DEBUG
  stats->_timing += [NSDate timeIntervalSinceReferenceDate] - time;
  stats->_layoutCount++;
#endif
  _cachedLayoutSize = layoutSize;
  if (!_sizing) {
    _needsLayout = NO;
  }
  _needsSizing = NO;
  _sizing = NO;    
  //[stats.log addObject:[NSString stringWithFormat:@"(%@)=>%@", NSStringFromCGSize(size), NSStringFromCGSize(layoutSize)]];
  return layoutSize;
}

- (void)setNeedsLayout {
  _needsLayout = YES;
  _needsSizing = YES;
  _cachedSize = CGSizeZero;
}

- (CGSize)layoutSubviews:(CGSize)size {
  CGSize layoutSize = [self _layout:size sizing:NO];  
  for (id view in _subviews) {
    if ([view respondsToSelector:@selector(layoutIfNeeded)]) [view layoutIfNeeded];
  }
  return layoutSize;
}

- (CGSize)sizeThatFits:(CGSize)size {
  if (_sizeThatFits.width > 0 && _sizeThatFits.height > 0) return _sizeThatFits;
  if (_sizeThatFits.width > 0) size = _sizeThatFits;
  return [self _layout:size sizing:YES];
}

- (CGRect)setFrame:(CGRect)frame view:(id)view sizeToFit:(BOOL)sizeToFit {
  return [self setFrame:frame view:view options:(sizeToFit ? YKLayoutOptionsSizeToFit : 0)];
}

- (CGRect)setFrame:(CGRect)frame view:(id)view options:(YKLayoutOptions)options {
  return [self setFrame:frame inRect:CGRectZero view:view options:options];
}

- (CGRect)setFrame:(CGRect)frame inRect:(CGRect)inRect view:(id)view options:(YKLayoutOptions)options {
  CGRect originalFrame = frame;
  BOOL sizeToFit = ((options & YKLayoutOptionsSizeToFit) == YKLayoutOptionsSizeToFit)
  || ((options & YKLayoutOptionsVariableWidth) == YKLayoutOptionsVariableWidth)
  || ((options & YKLayoutOptionsSizeToFitConstrainSizeMaintainAspectRatio) == YKLayoutOptionsSizeToFitConstrainSizeMaintainAspectRatio);

  CGSize sizeThatFits = CGSizeZero;
  if (sizeToFit) {
    sizeThatFits = [view sizeThatFits:frame.size];
    
    // If size that fits returns a larger width, then we'll need to constrain it.
    if (((options & YKLayoutOptionsSizeToFitConstraintWidth) == YKLayoutOptionsSizeToFitConstraintWidth) && sizeThatFits.width > frame.size.width) {
      sizeThatFits.width = frame.size.width;
    }

    // If size that fits returns a larger width or height, constrain it, but also maintain the aspect ratio from sizeThatFits
    if (((options & YKLayoutOptionsSizeToFitConstrainSizeMaintainAspectRatio) == YKLayoutOptionsSizeToFitConstrainSizeMaintainAspectRatio) && (sizeThatFits.height > frame.size.height || sizeThatFits.width > frame.size.width)) {
      CGFloat aspectRatio = sizeThatFits.width / sizeThatFits.height;
      // If we're going to constrain by width
      if (sizeThatFits.width / frame.size.width > sizeThatFits.height / frame.size.height) {
        sizeThatFits.width = frame.size.width;
        sizeThatFits.height = roundf(frame.size.width / aspectRatio);
      // If we're going to constrain by height
      } else {
        sizeThatFits.height = frame.size.height;
        sizeThatFits.width = roundf(frame.size.height * aspectRatio);
      }
    }

    if (sizeThatFits.width == 0 && ((options & YKLayoutOptionsSizeToFitDefaultSize) == YKLayoutOptionsSizeToFitDefaultSize)) {
      sizeThatFits.width = frame.size.width;
    }
    
    if (sizeThatFits.height == 0 && ((options & YKLayoutOptionsSizeToFitDefaultSize) == YKLayoutOptionsSizeToFitDefaultSize)) {
      sizeThatFits.height = frame.size.height;
    }

    if ((options & YKLayoutOptionsFixedWidth) == YKLayoutOptionsFixedWidth) {
      sizeThatFits.width = frame.size.width;
    }

    // If size that fits returns different width than passed in, it can cause weirdness when sizeToFit is called multiple times in succession.
    // Here we assert the size passed into sizeThatFits returns the same width, unless you explicitly override this behavior.
    // This is because most views are sized based on a width. If you had a view (a button, for example) with a variable width, then you should specify the
    // YKLayoutOptionsVariableWidth to override this check.
    // This check only applies to YKUIView subclasses.
    if (((options & YKLayoutOptionsVariableWidth) != YKLayoutOptionsVariableWidth)
        && ((options & YKLayoutOptionsSizeToFitConstrainSizeMaintainAspectRatio) != YKLayoutOptionsSizeToFitConstrainSizeMaintainAspectRatio)
        && ((options & YKLayoutOptionsFixedWidth) != YKLayoutOptionsFixedWidth)
        && sizeThatFits.width != frame.size.width && [view conformsToProtocol:@protocol(YKLayoutView)]) {
      YKAssert(NO, @"sizeThatFits: returned width different from passed in width. If you have a variable width view, you can pass in the option YKLayoutOptionsVariableWidth to avoid this check.");
    }
    
    if (frame.size.width > 0 && (options & YKLayoutOptionsVariableWidth) != YKLayoutOptionsVariableWidth) {
      YKAssert(sizeThatFits.width > 0, @"sizeThatFits: on view returned 0 width; Make sure that layout:size: doesn't return a zero width size");
    }
    
    frame.size = sizeThatFits;
  }
  
  CGSize sizeForAlign = frame.size;
  CGRect rect = originalFrame;
  if (!CGRectIsEmpty(inRect)) rect = inRect;

  if ((options & YKLayoutOptionsCenter) == YKLayoutOptionsCenter) {
    frame = YKCGRectToCenterInRect(sizeForAlign, rect);
  }
  
  if ((options & YKLayoutOptionsCenterVertical) == YKLayoutOptionsCenterVertical) {
    frame = YKCGRectToCenterYInRect(frame, originalFrame);
  }

  if ((options & YKLayoutOptionsRightAlign) == YKLayoutOptionsRightAlign) {
    frame = YKCGRectRightAlignWithRect(frame, rect);
  }

  [self setFrame:frame view:view];
  return frame;  
}

- (CGRect)setX:(CGFloat)x frame:(CGRect)frame view:(id)view {
  frame.origin.x = x;
  return [self setFrame:frame view:view needsLayout:NO];
}

- (CGRect)setY:(CGFloat)y frame:(CGRect)frame view:(id)view {
  frame.origin.y = y;
  return [self setFrame:frame view:view needsLayout:NO];
}

- (CGRect)setOrigin:(CGPoint)origin frame:(CGRect)frame view:(id)view {
  frame.origin = origin;
  if (YKCGRectIsEqual(frame, [view frame])) return frame;
  return [self setFrame:frame view:view needsLayout:NO];
}

- (CGRect)setOrigin:(CGPoint)origin view:(id)view {
  return [self setOrigin:origin frame:(view ? [view frame] : CGRectZero) view:view];
}

- (CGRect)setY:(CGFloat)y view:(id)view {
  return [self setY:y frame:(view ? [view frame] : CGRectZero) view:view];
}

- (CGRect)setFrame:(CGRect)frame view:(id)view {
  return [self setFrame:frame view:view needsLayout:YES];
}

- (CGRect)setFrame:(CGRect)frame view:(id)view needsLayout:(BOOL)needsLayout {
  if (!view) return CGRectZero;
  if (!_sizing) {
    [view setFrame:frame];
    if (view) {
      [_accessibleElements addObject:view];
    }
    // Since we are applying the frame, the subview will need to
    // apply their layout next at this frame
    if (needsLayout) [view setNeedsLayout];
  }
  // Some stupid views (cough UIPickerView cough) will snap to certain frame
  // values. This makes sure we return the actual frame of the view
  if (!_sizing) return [view frame];
  return frame;
}

- (void)addSubview:(id)view {
#if YP_DEBUG
  if (![view respondsToSelector:@selector(drawInRect:)]) {
    [NSException raise:NSInvalidArgumentException format:@"Subview should implement the method - (void)drawInRect:(CGRect)rect;"];
    return;
  }
  if (![view respondsToSelector:@selector(frame)]) {
    [NSException raise:NSInvalidArgumentException format:@"Subview should implement the method - (CGRect)frame;"];
    return;
  }
#endif
  if (!_subviews) _subviews = [[NSMutableArray alloc] init];
  [_subviews addObject:view];
}

- (void)clear {
  _view = nil;
  [_subviews removeAllObjects];
}

- (void)removeSubview:(id)view {
  [_subviews removeObject:view];
}

- (void)drawSubviewsInRect:(CGRect)rect {
  for (id view in _subviews) {
    BOOL isHidden = NO;
    if ([view respondsToSelector:@selector(isHidden)]) {
      isHidden = [view isHidden];
    }
    
    if (!isHidden) {
      [view drawInRect:CGRectOffset([view frame], rect.origin.x, rect.origin.y)];
    }
  }
}

void YKLayoutAssert(UIView *view, YKLayout *layout) {
#if DEBUG
  BOOL hasLayoutMethod = ([view respondsToSelector:@selector(layout:size:)]);
  
  if (hasLayoutMethod && !layout) {
    [NSException raise:NSObjectNotAvailableException format:@"Missing layout instance for %@", view];
  }
  if (!hasLayoutMethod && layout) {
    [NSException raise:NSObjectNotAvailableException format:@"Missing layout:size: for %@", view];
  }
#endif
}

+ (YKLayoutStats *)statsForView:(UIView *)view {
  NSString *name = NSStringFromClass([view class]);
  if (gDebugStats == NULL) gDebugStats = [[NSMutableDictionary alloc] init];
  YKLayoutStats *stats = gDebugStats[name];
  if (!stats) {
    stats = [[YKLayoutStats alloc] init];
    gDebugStats[name] = stats;
    [stats release];
  }
  return stats;
}

@end


@implementation YKLayoutStats

@synthesize log=_log;

- (id)init {
  if ((self = [super init])) {
    _log = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [_log release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"layoutCount=%d, cacheCount=%d, createCount=%d, timing=%0.3f, log=%@", _layoutCount, _cacheCount, _createCount, _timing, [_log componentsJoinedByString:@","]];
}

@end