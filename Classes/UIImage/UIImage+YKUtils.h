//
//  UIImage+YKUtils.h
//  YelpKit
//
//  Created by John Boiles on 5/9/12.
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

@interface UIImage (YKUtils)

/*!
 Renders an image from Core Graphics rendering operations that are passed in via a block.

 @param drawOperations Block containing core graphics calls to be drawn to the image
 @param size Size of the output image
 @param opaque Whether the image should render as opaque
 @result UIImage containing any of the drawing that occurred in drawOperations
 */
+ (UIImage *)imageFromDrawOperations:(void(^)(CGContextRef context))drawOperations size:(CGSize)size opaque:(BOOL)opaque;

/*!
 Renders an image from a UIView subclass.

 @param view View to render to an image
 @result UIImage containing the contents of view
 */
+ (UIImage *)imageFromView:(UIView *)view;


/*!
 Crops a new image from the given image
 @param image Image to crop
 @param frame Rect to constrain the new image cropped out of image
 @result UIImage that is cropped from the original image
 */
- (UIImage *)croppedImageFromFrame:(CGRect)frame;

/*!
 Resizes an image based on a given content mode

 @param size Size of the returned image
 @param contentMode Content mode with which to size the image
 @param opaque Whether the image should render as opaque
 @result UIImage that has been resized to size based on the contentMode
 */
- (UIImage *)resizedImageInSize:(CGSize)size contentMode:(UIViewContentMode)contentMode opaque:(BOOL)opaque;

/*!
 Returns a UIImage that is rotated based on this image's imageOrientation. This can be used to rotate images so that they display correctly in views that don't respect imageOrientation.

 @result UIImage that has been rotated based on self's imageOrientation.
 */
- (UIImage *)yk_imageByRotatingImageUpright;

@end

UIImage *YKRotateImage(UIImage *image, UIImageOrientation imageOrientation);
