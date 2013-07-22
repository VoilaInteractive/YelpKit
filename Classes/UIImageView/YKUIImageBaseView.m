//
//  YKUIImageBaseView.m
//  YelpKit
//
//  Created by Benjamin Asher on 7/18/13.
//  Copyright (c) 2013 Yelp. All rights reserved.
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

#import "YKUIImageBaseView.h"
#import "UIImage+YKUtils.h"
#import "YKCGUtils.h"
#import <GHKit/GHNSData+Base64.h>
#import "YKDefines.h"

@interface YKUIImageBaseView ()

@property (assign, atomic) NSUInteger counter;
@property (assign, nonatomic) BOOL imageWillRenderSoon;
@property (readwrite, retain, nonatomic) UIImage *renderedImage;
@property (retain, nonatomic) UIImageView *renderedImageView;
@property (assign, nonatomic) BOOL requiresSpecialRendering;

@end

static BOOL gYKUIImageViewDisableRenderInBackground = NO;
static BOOL gYKUIImageViewAlwaysRenderImmediately = NO;

@implementation YKUIImageBaseView

#pragma mark - Class Methods

+ (void)setDisableRenderInBackground:(BOOL)disableRenderInBackground {
  gYKUIImageViewDisableRenderInBackground = disableRenderInBackground;
}

+ (dispatch_queue_t)backgroundRenderQueue {
  static dispatch_queue_t backgroundRenderQueue = NULL;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    backgroundRenderQueue = dispatch_queue_create("com.YelpKit.YKUIImageBaseView.backgroundRenderQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t highPrioQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_set_target_queue(backgroundRenderQueue, highPrioQueue);
  });
  return backgroundRenderQueue;
}

#pragma mark - Init

- (void)sharedInit {
  [super sharedInit];
  self.opaque = NO;
  self.backgroundColor = [UIColor whiteColor];
  self.contentMode = UIViewContentModeScaleAspectFit;
  self.imageWillRenderSoon = NO;
  self.renderInBackground = NO;
  self.requiresSpecialRendering = YES;
  self.counter = 0;
  self.renderedImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
  self.renderedImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [self addSubview:self.renderedImageView];
  
  
  [self setIsAccessibilityElement:YES];
  [self setAccessibilityTraits:UIAccessibilityTraitImage];
  
  for (NSString *key in [self keysToForceRender]) {
    [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
  }
}

- (id)initWithFrame:(CGRect)frame requiresSpecialRendering:(BOOL)requiresSpecialRendering {
  if ((self = [super initWithFrame:frame])) {
    self.requiresSpecialRendering = requiresSpecialRendering;
  }
  return self;
}

- (id)initWithImage:(UIImage *)image {
  if ((self = [self initWithImage:image requiresSpecialRendering:YES])) {
  }
  return self;
}

- (id)initWithImage:(UIImage *)image requiresSpecialRendering:(BOOL)requiresSpecialRendering {
  if ((self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)])) {
    self.requiresSpecialRendering = requiresSpecialRendering;
    self.image = image;
    self.bounds = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
  }
  return self;
}


- (void)dealloc {
  for (NSString *key in [self keysToForceRender]) {
    [self removeObserver:self forKeyPath:key context:NULL];
  }
  
  [_image release];
  [_renderedImage release];
  [_renderedImageView release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@\n Base64 Image: %@\n Base64 Rendered Image: %@", [super description],
          [UIImagePNGRepresentation(self.image) gh_base64],
          [UIImagePNGRepresentation(self.renderedImage) gh_base64]];
}

#pragma mark - Sizing

- (CGSize)size {
  if (!self.renderedImage) return CGSizeZero;
  return self.renderedImage.size;
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize sizeThatFits = [self size];
  if (sizeThatFits.width > size.width || sizeThatFits.height > size.height) {
    CGRect scale = YKCGRectScaleAspectAndCenter(sizeThatFits, size, YES);
    sizeThatFits.width = scale.size.width;
    sizeThatFits.height = scale.size.height;
  }
  return sizeThatFits;
}

#pragma mark - Rendering

- (void)setImage:(UIImage *)image {
  [image retain];
  [_image release];
  _image = image;
  
  if (_image != nil && [self _hasZeroSize]) {
    self.bounds = CGRectMake(0.0f, 0.0f, _image.size.width, _image.size.height);
  }
  
  [self _renderSoon];
}

- (BOOL)_hasZeroSize
{
  return (self.bounds.size.width == 0.0f || self.bounds.size.height == 0.0f);
}

- (void)_render {
  // Cant't draw without a size
  if ([self _hasZeroSize]) {
    return;
  }
  
  if (_requiresSpecialRendering) {
    if (_renderInBackground && !gYKUIImageViewDisableRenderInBackground) {
      NSDictionary *contextDictionary = [self renderContextDictionary];
      UIImage *image = self.image;
      dispatch_async([[self class] backgroundRenderQueue], ^{
        UIImage *finalImage = [[self class] renderImage:image withContextDictionary:contextDictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
          self.renderedImage = finalImage;
          [self _renderFinal:YES];
        });
      });
      // render an empty image while we wait, if there's not already a rendered image
      if (self.image && !self.renderedImage) {
        self.renderedImage = [[self class] renderImage:nil withContextDictionary:[self renderContextDictionary]];
        [self _renderFinal:NO];
      }
    } else {
      self.renderedImage = [[self class] renderImage:self.image withContextDictionary:[self renderContextDictionary]];
      [self _renderFinal:YES];
    }
  } else {
    self.renderedImage = [[self.image copy] autorelease];
    [self _renderFinal:YES];
  }
  
}

- (void)_renderFinal:(BOOL)notify {
  
  self.renderedImageView.image = self.renderedImage;
  
  if (notify) {
    [self didRenderImage:self.renderedImage];
  }
}

- (void)forceRender {
  [self _render];
}

- (void)_renderSoon {
  if (![self imageWillRenderSoon] && !gYKUIImageViewAlwaysRenderImmediately) {
    self.imageWillRenderSoon = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
      self.imageWillRenderSoon = NO;
      [self forceRender];
    });
  } else if (gYKUIImageViewAlwaysRenderImmediately) {
    [self forceRender];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if ([[self keysToForceRender] containsObject:keyPath]) {
    if ([keyPath isEqualToString:@"frame"] || [keyPath isEqualToString:@"bounds"]) {
      CGRect oldRect = [change[NSKeyValueChangeOldKey] CGRectValue];
      CGRect newRect = [change[NSKeyValueChangeNewKey] CGRectValue];
      if (!CGSizeEqualToSize(oldRect.size, newRect.size)) {
        [self _renderSoon];
      }
    } else {
      [self _renderSoon];
    }
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

#pragma mark - Subclass Stubs

+ (UIImage *)renderImage:(UIImage *)image withContextDictionary:(NSDictionary *)contextDictionary {
  if (image) {
    return [[image copy] autorelease];
  } else {
    CGRect bounds = [contextDictionary[@"bounds"] CGRectValue];
    UIColor *backgroundColor = contextDictionary[@"backgroundColor"];
    return [UIImage imageFromDrawOperations:^(CGContextRef context) {
      CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
      CGContextFillRect(context, bounds);
    } size:bounds.size opaque:CGColorGetAlpha(backgroundColor.CGColor) == 1.0f];
  }
}

- (NSArray *)keysToForceRender { return @[@"bounds", @"frame", @"opaque"]; }

- (NSDictionary *)renderContextDictionary {
  return @{
           @"bounds" : [NSValue valueWithCGRect:self.bounds],
           @"backgroundColor" : self.backgroundColor,
           };
}

- (void)didRenderImage:(UIImage *)image {}

@end

