//
//  YKImageMemoryCache.m
//  YelpKit
//
//  Created by Amir Haghighat  on 5/16/12.
//  Copyright 2012 Yelp. All rights reserved.
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

#import "YKImageMemoryCache.h"
#import "YKURLCache.h"
#import "YKDefines.h"

@implementation YKImageMemoryCache

@synthesize maxPixelCount=_maxPixelCount;

- (id)init {
  if ((self = [super init])) {
    _maxPixelCount = 262144; // ~1 MB
    
    if ([YKURLCache totalMemory] > (220 * 1000 * 1000)) { // 256 MB Device
      _maxPixelCount *= 4; // ~4 MB
    }
    
    if ([YKURLCache totalMemory] > (500 * 1000 * 1000)) { // 512 MB Device
      _maxPixelCount *= 8; // ~8 MB
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

+ (YKImageMemoryCache *)sharedCache {
  static dispatch_once_t predicate;
  static YKImageMemoryCache *gSharedImageCacheMemory = nil;

  dispatch_once(&predicate, ^{
    gSharedImageCacheMemory = [[self alloc] init];
  });
  return gSharedImageCacheMemory;
}

- (void)didReceiveMemoryWarning:(void *)object {
  // Empty the memory cache when memory is low
  [self clearCache];
}

- (void)clearCache {
  _totalPixelCount = 0;
  [_imageCache release];
  _imageCache = nil;
  [_imageSortedList release];
  _imageSortedList = nil;
}

- (void)_expireImagesFromMemory {
  while (_imageSortedList.count) {
    NSString *key = _imageSortedList[0];
    UIImage *image = _imageCache[key];
    
    YKDebug(@"Expiring image, key=%@, pixels=%.0f", key, (image.size.width * image.size.height));
    _totalPixelCount -= image.size.width * image.size.height;
    [_imageCache removeObjectForKey:key];
    [_imageSortedList removeObjectAtIndex:0];
    
    if (_totalPixelCount <= _maxPixelCount) {
      break;
    }
  }
  if (_totalPixelCount < 0) _totalPixelCount = 0;
}

- (BOOL)cacheImage:(UIImage *)image forKey:(NSString *)key {
  YKParameterAssert(image);
  YKParameterAssert(key);
  if (!image || !key) return NO;
  
  // Already in cache (We don't bump it forward)
  if (_imageCache[key]) return NO;

  int pixelCount = image.size.width * image.size.height;
  
  static const CGFloat kLargeImageSize = 600 * 400;
  
  if (pixelCount >= kLargeImageSize) {
    YKDebug(@"NOT caching image in in memory (too large, pixelCount=%d > %.0f)", pixelCount, kLargeImageSize);
    return NO;
  }
  
  _totalPixelCount += pixelCount;
  
  if (_totalPixelCount > _maxPixelCount && _maxPixelCount) {
    [self _expireImagesFromMemory];
  }
  
  if (!_imageCache) {
    _imageCache = [[NSMutableDictionary alloc] init];
  }
  
  if (!_imageSortedList) {
    _imageSortedList = [[NSMutableArray alloc] init];
  }
  
  [_imageSortedList addObject:key];
  _imageCache[key] = image;
  return YES;
}

- (UIImage *)memoryCachedImageForKey:(NSString *)key {
  if (!key) return nil;
  UIImage *image = _imageCache[key];
  return image;
}

@end
