//
//  YKUIImageView.m
//  YelpKit
//
//  Created by Gabriel Handford on 12/30/08.
//  Copyright 2008 Yelp. All rights reserved.
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

#import "YKUIImageView.h"
#import "YKCGUtils.h"
#import "YKLocalized.h"
#import "YKDefines.h"
#import "UIImage+YKUtils.h"
#import "YKImageMemoryCache.h"
#import <GHKit/GH_MAZeroingWeakRef.h>

static BOOL gYKUIImageViewDebugRender = NO;

@interface YKUIImageView ()

@property (retain, nonatomic) YKImageLoader *imageLoader;
@property (assign, nonatomic) BOOL imageLoaderDidLoadImage;
@property (readwrite, assign, nonatomic) YKUIImageViewStatus status;

@end

@implementation YKUIImageView

- (void)sharedInit {
  [super sharedInit];
  self.imageLoaderDidLoadImage = NO;
  self.imageContentMode = NSUIntegerMax;
}

- (id)initWithURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage {
  if ((self = [self initWithURLString:URLString loadingImage:loadingImage defaultImage:defaultImage requiresSpecialRendering:YES])) {
  }
  return self;
}

- (id)initWithURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage requiresSpecialRendering:(BOOL)requiresSpecialRendering {
  if ((self = [super initWithFrame:CGRectZero requiresSpecialRendering:requiresSpecialRendering])) {
    [self setURLString:URLString loadingImage:loadingImage defaultImage:defaultImage];
  }
  return self;
}

- (void)dealloc {
  _imageLoader.delegate = nil;
  [_imageLoader cancel];
  [_imageLoader release];
  Block_release(_statusBlock);
  [_strokeColor release];
  [_color release];
  [_color2 release];
  [_overlayColor release];
  [_shadowColor release];
  [super dealloc];
}

#pragma mark - Accessors

- (UIViewContentMode)imageContentMode {
  if (_imageContentMode == NSUIntegerMax) return self.contentMode;
  return _imageContentMode;
}

- (UIImage *)loadingImage {
  return self.imageLoader.loadingImage;
}

- (void)setURLString:(NSString *)URLString {
  [self setURLString:URLString defaultImage:nil];
}

- (NSString *)URLString {
  return self.imageLoader.URL.URLString;
}


#pragma mark - Overides

+ (UIImage *)renderImage:(UIImage *)image withContextDictionary:(NSDictionary *)contextDictionary {
  
  CGRect bounds = [contextDictionary[@"bounds"] CGRectValue];
  BOOL opaque = [contextDictionary[@"opaque"] boolValue];
  UIViewContentMode imageContentMode = [contextDictionary[@"imageContentMode"] integerValue];
  
  UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 0);
  
  [self _renderImage:image withContextDictionary:contextDictionary inRect:bounds contentMode:imageContentMode];
  UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return renderedImage;
}

- (NSArray *)keysToForceRender
{
  NSArray *keys = @[@"strokeColor",
                    @"strokeWidth",
                    @"cornerRadius",
                    @"cornerRadiusRatio",
                    @"color",
                    @"color2",
                    @"overlayColor",
                    @"shadowColor",
                    @"shadowBlur",
                    @"imageContentMode"
                    ];
  return [keys arrayByAddingObjectsFromArray:[super keysToForceRender]];
}

- (NSDictionary *)renderContextDictionary {
  
  NSDictionary *initialContextDictionary = @{@"bounds" : [NSValue valueWithCGRect:self.bounds],
                                             @"cornerRadius" : @(self.cornerRadius),
                                             @"cornerRadiusRatio" : @(self.cornerRadiusRatio),
                                             @"opaque" : @(self.opaque),
                                             @"imageContentMode" : @(self.imageContentMode),
                                             @"shadowBlur" : @(self.shadowBlur),
                                             @"strokeWidth" : @(self.strokeWidth),
                                             };
  
  NSMutableDictionary *contextDictionary = [[NSMutableDictionary alloc] initWithDictionary:initialContextDictionary];
  
  if (self.backgroundColor) {
    contextDictionary[@"backgroundColor"] = self.backgroundColor;
  }
  
  if (self.color) {
    contextDictionary[@"color"] = self.color;
  }
  
  if (self.color2) {
    contextDictionary[@"color2"] = self.color2;
  }
  
  if (self.overlayColor) {
    contextDictionary[@"overlayColor"] = self.overlayColor;
  }
  
  if (self.shadowColor) {
    contextDictionary[@"shadowColor"] = self.shadowColor;
  }
  
  if (self.strokeColor) {
    contextDictionary[@"strokeColor"] = self.strokeColor;
  }
  
  return [contextDictionary autorelease];
}

- (void)didRenderImage:(UIImage *)image {
  if (image && self.imageLoaderDidLoadImage) {
    self.status = YKUIImageViewStatusLoaded;
  } else {
    self.status = YKUIImageViewStatusNone;
  }
  [self _notifyListeners];
}

#pragma mark - Drawing

+ (void)_renderImage:(UIImage *)image withContextDictionary:(NSDictionary *)contextDictionary inRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (gYKUIImageViewDebugRender) {
    
    CGContextSaveGState(context);
    // Flip coordinate system, otherwise image will be drawn upside down
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM (context, 1.0, -1.0);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextRestoreGState(context);
    
  } else {
    
    // unpack
    UIColor *backgroundColor = contextDictionary[@"backgroundColor"];
    UIColor *color = contextDictionary[@"color"];
    UIColor *color2 = contextDictionary[@"color2"];
    CGFloat cornerRadius = [contextDictionary[@"cornerRadius"] floatValue];
    CGFloat cornerRadiusRatio = [contextDictionary[@"cornerRadiusRatio"] floatValue];
    UIColor *overlayColor = contextDictionary[@"overlayColor"];
    UIColor *shadowColor = contextDictionary[@"shadowColor"];
    CGFloat shadowBlur = [contextDictionary[@"shadowBlur"] floatValue];
    UIColor *strokeColor = contextDictionary[@"strokeColor"];
    CGFloat strokeWidth = [contextDictionary[@"strokeWidth"] floatValue];
    
    if (backgroundColor) {
      YKCGContextDrawRect(context, rect, backgroundColor.CGColor, NULL, 0);
    }
    
    if (cornerRadiusRatio > 0.0f) {
      cornerRadius = roundf(rect.size.height/2.0f) * cornerRadiusRatio;
    }
    
    if (!color) color = backgroundColor;
    
    if (color && color2) {
      CGContextSaveGState(context);
      YKCGContextAddStyledRect(context, rect, YKUIBorderStyleRounded, strokeWidth, cornerRadius);
      CGContextClip(context);
      YKCGContextDrawShading(context, color.CGColor, color2.CGColor, NULL, NULL, rect.origin, CGPointMake(rect.origin.x, CGRectGetMaxY(rect)), YKUIShadingTypeLinear, NO, NO);
      CGContextRestoreGState(context);
      color = nil;
    }
    
    
    YKCGContextDrawRoundedRectImageWithShadow(context, image.CGImage, image.size, rect, strokeColor.CGColor, strokeWidth, cornerRadius, contentMode, color.CGColor, shadowColor.CGColor, shadowBlur);
    
    
    if (overlayColor) {
      YKCGContextDrawRoundedRect(context, rect, overlayColor.CGColor, NULL, strokeWidth, cornerRadius);
    }
    
  }
  
}

- (void)drawInRect:(CGRect)rect
{
  self.renderInBackground = NO;
  [[self class] _renderImage:self.image withContextDictionary:[self renderContextDictionary] inRect:rect contentMode:self.imageContentMode];
}

- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode;
{
  self.renderInBackground = NO;
  [[self class] _renderImage:self.image withContextDictionary:[self renderContextDictionary] inRect:rect contentMode:contentMode];
}

#pragma mark - URL Loading

- (void)cancel {
  [self.imageLoader cancel];
}

- (void)reload {
  [self setURLString:self.imageLoader.URL.URLString loadingImage:self.imageLoader.loadingImage defaultImage:self.imageLoader.defaultImage];
}

- (void)reset {
  [self.imageLoader cancel];
  self.imageLoader.delegate = nil;
  self.imageLoader = nil;
  self.image = nil;
}

- (void)setURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage errorImage:(UIImage *)errorImage {
  if ([URLString isEqual:[NSNull null]]) URLString = nil;
  
  if (loadingImage) {
    self.image = loadingImage;
  }
  
  [self reset];
  if (URLString) {
    self.imageLoaderDidLoadImage = NO;
    self.imageLoader = [[[YKImageLoader alloc] initWithLoadingImage:loadingImage defaultImage:defaultImage errorImage:errorImage delegate:self] autorelease];
    [self.imageLoader setURL:[YKURL URLWithURLString:URLString]];
    
  } else if (defaultImage) {
    self.image = defaultImage;
  }
}

- (void)setURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage {
  [self setURLString:URLString loadingImage:loadingImage defaultImage:defaultImage errorImage:nil];
}

- (void)setURLString:(NSString *)URLString defaultImage:(UIImage *)defaultImage {
  [self setURLString:URLString loadingImage:nil defaultImage:defaultImage];
}

- (void)_notifyListeners {
  if (self.statusBlock) {
    self.statusBlock(self, self.status, self.renderedImage);
  }
  
  if (self.status == YKUIImageViewStatusLoaded && [self.delegate respondsToSelector:@selector(imageView:didLoadImage:)]) {
    [self.delegate imageView:self didLoadImage:self.renderedImage];
  }
}

#pragma mark - YKImageLoaderDelegate

- (void)imageLoaderDidStart:(YKImageLoader *)imageLoader {
  if ([self.delegate respondsToSelector:@selector(imageViewDidStart:)])
    [self.delegate imageViewDidStart:self];
}

- (void)imageLoader:(YKImageLoader *)imageLoader didUpdateStatus:(YKImageLoaderStatus)status image:(UIImage *)image {
  switch (status) {
    case YKImageLoaderStatusNone: self.status = YKUIImageViewStatusNone; break;
    case YKImageLoaderStatusLoading: self.status = YKUIImageViewStatusLoading; break;
    case YKImageLoaderStatusLoaded: self.status = YKUIImageViewStatusLoaded; break;
    default:
      break;
  }
  
  if (status == YKImageLoaderStatusLoaded && image) {
    self.imageLoaderDidLoadImage = YES;
    self.image = image;
  } else if (status != YKUIImageViewStatusLoaded) {
    [self _notifyListeners];
  }
}

- (void)imageLoader:(YKImageLoader *)imageLoader didError:(YKError *)error {
  self.status = YKUIImageViewStatusErrored;
  
  if ([self.delegate respondsToSelector:@selector(imageView:didError:)])
    [self.delegate imageView:self didError:error];
  if (self.statusBlock) self.statusBlock(self, self.status, nil);
}

- (void)imageLoaderDidCancel:(YKImageLoader *)imageLoader {
  self.status = YKUIImageViewStatusNone;
  if ([self.delegate respondsToSelector:@selector(imageViewDidCancel:)])
    [self.delegate imageViewDidCancel:self];
}


@end
