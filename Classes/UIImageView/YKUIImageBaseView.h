//
//  YKUIImageBaseView.h
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

#import "YKUILayoutView.h"

/*!
 Image base view. Doesn't draw contents. See YKUIImageView.
 */
@interface YKUIImageBaseView : YKUILayoutView

/*!
 Original, unprocessed image. Setting this property will cause YKUIImageView will re-render.
 */
@property (retain, nonatomic) UIImage *image;

/*!
 Displayed image.
 */
@property (readonly, nonatomic) UIImage *renderedImage;


/*!
 If set to YES, the initial image will be processed and rendered on a background thread before being displayed
 */
@property (assign, nonatomic) BOOL renderInBackground;

/*!
 Image size.
 @result Image size or CGSizeZero if no image set
 */
@property (readonly, nonatomic) CGSize size;


+ (void)setDisableRenderInBackground:(BOOL)disableRenderInBackground;


/*!
 Init
 @param frame Initial frame of the view
 @param requiresSpecialRendering If this flag is set to NO, then the image will be displayed as is without being processed (fast)
 @result YKUIImageView
 */
- (id)initWithFrame:(CGRect)frame requiresSpecialRendering:(BOOL)requiresSpecialRendering;

/*!
 Init
 @param image Image to be processed and displayed by YKUImageView
 @result YKUIImageView
 */
- (id)initWithImage:(UIImage *)image;

/*!
 Init
 @param image Image to be processed and displayed by YKUImageView
 @param requiresSpecialRendering If this flag is set to NO, then the image will be displayed as is without being processed (fast)
 @result YKUIImageView
 */
- (id)initWithImage:(UIImage *)image requiresSpecialRendering:(BOOL)requiresSpecialRendering;

/*!
 Force image to be re-rendered
 */
- (void)forceRender;

@end

@interface YKUIImageBaseView (SubclassingHooks)

// class method so that it's thread safe (can't access ivars)
+ (UIImage *)renderImage:(UIImage *)image withContextDictionary:(NSDictionary *)contextDictionary;
- (NSDictionary *)renderContextDictionary;
- (NSArray *)keysToForceRender;
- (void)didRenderImage:(UIImage *)image;

@end

