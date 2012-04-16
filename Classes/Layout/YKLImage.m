//
//  YKLImage.m
//  YelpKit
//
//  Created by Gabriel Handford on 4/11/12.
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

#import "YKLImage.h"

@implementation YKLImage

@synthesize image=_image;

- (id)initWithImage:(UIImage *)image {
  if ((self = [super init])) {
    _image = [image retain];
  }
  return self;
}

- (void)dealloc {
  [_image release];
  [super dealloc];
}

+ (YKLImage *)imageWithImage:(UIImage *)image {
  return [[[YKLImage alloc] initWithImage:image] autorelease];
}

- (CGSize)sizeThatFits:(CGSize)size {
  return _image.size;
}

- (void)draw {
  [_image drawAtPoint:_frame.origin];
}

@end