//
//  YKImageLoader.m
//  YelpIPhone
//
//  Created by Gabriel Handford on 4/14/09.
//  Copyright 2009 Yelp. All rights reserved.
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

#import "YKImageLoader.h"

#import "YKImageMemoryCache.h"
#import "YKResource.h"
#import "YKDefines.h"

@interface YKImageLoader ()

@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) YKURLRequest *request;
@property (retain, nonatomic) YKURL *URL;

- (void)setImage:(UIImage *)image status:(YKImageLoaderStatus)status;

@end

#define kExpiresAge YKTimeIntervalWeek

static UIImage *gYKImageLoaderMockImage = NULL;

@implementation YKImageLoader

+ (YKImageLoader *)imageLoaderWithURLString:(NSString *)URLString loadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage errorImage:(UIImage *)errorImage delegate:(id<YKImageLoaderDelegate>)delegate {
  YKImageLoader *imageLoader = [[YKImageLoader alloc] initWithLoadingImage:loadingImage defaultImage:defaultImage errorImage:errorImage delegate:delegate];
  [imageLoader setURLString:URLString];
  return [imageLoader autorelease]; 
}

+ (void)setMockImage:(UIImage *)mockImage {
  [mockImage retain];
  [gYKImageLoaderMockImage release];
  gYKImageLoaderMockImage = mockImage;
}

+ (dispatch_queue_t)diskCacheQueue {
  // We assert main thread as a way to ensure this is thread safe
  YKAssertMainThread();
  static dispatch_once_t onceToken;
  static dispatch_queue_t imageLoaderDiskCacheQueue = nil;
  dispatch_once(&onceToken, ^{
    imageLoaderDiskCacheQueue = dispatch_queue_create("com.YelpKit.YKImageLoader.diskCacheQueue", DISPATCH_QUEUE_SERIAL);
  });
  return imageLoaderDiskCacheQueue;
}

- (id)initWithLoadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage delegate:(id<YKImageLoaderDelegate>)delegate {
  return [self initWithLoadingImage:loadingImage defaultImage:defaultImage errorImage:nil delegate:delegate];
}

- (id)initWithLoadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage errorImage:(UIImage *)errorImage delegate:(id<YKImageLoaderDelegate>)delegate {
  if ((self = [self init])) {
    self.loadingImage = loadingImage;
    self.defaultImage = defaultImage;
    self.errorImage = errorImage;
    self.delegate = delegate;
  }
  return self;
}

- (void)dealloc {
  YKURLRequestRelease(_request);
  [_URL release];
  [_image release];
  [_defaultImage release];
  [_loadingImage release];
  [_errorImage release];
  [super dealloc];
}

- (void)setURLString:(NSString *)URLString {
  if (URLString) {
    YKURL *URL = [YKURL URLWithURLString:URLString];
    self.URL = URL;
  } else {
    self.URL = nil;
  }
}

+ (void)preloadImageWithURLString:(NSString *)URLString {
  YKImageLoader *imageLoader = [[YKImageLoader alloc] init];
  [imageLoader setURLString:URLString];
  [[YKImageLoaders shared] add:imageLoader];
  [imageLoader autorelease];
}

- (void)setURL:(YKURL *)URL {
  if (![NSThread isMainThread]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _setURL:URL];
    });
  } else {
    [self _setURL:URL];
  }
}
  
- (void)_setURL:(YKURL *)URL {
  YKAssertMainThread();
  [self cancel];
  [URL retain];
  [_URL release];
  _URL = URL;
  self.image = nil;
   
#if YP_DEBUG
  self.URL.cacheDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"YKImageLoaderCacheDisabled"];
#endif
  
  if (!URL) {
    [self setImage:_defaultImage status:YKImageLoaderStatusNone];    
    return;
  }

  // Check to see if we're using a mock image
  if (gYKImageLoaderMockImage && ![URL.URLString hasPrefix:@"bundle:"]) {
    [self setImage:gYKImageLoaderMockImage status:YKImageLoaderStatusLoaded];
    return;
  }

  // Check for cached image in memory, and set immediately if available
  UIImage *memoryCachedImage = [[YKImageMemoryCache sharedCache] memoryCachedImageForKey:URL.cacheableURLString];
  if (memoryCachedImage) {
    [self setImage:memoryCachedImage status:YKImageLoaderStatusLoaded];
    return;
  }

  // Check for resource in bundle
  NSString *resourceName = [YKResource pathForBundleURL:[NSURL URLWithString:URL.URLString]];
  if (resourceName) {
    [self setImage:[UIImage imageNamed:resourceName] status:YKImageLoaderStatusLoaded];
    return;
  }

  // Check for cached image on disk, load asynchronously if available
  // NOTE(johnb): Checking if the URL is in the disk cache takes around 0.4 ms
  //NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
  BOOL inDiskCache = [[YKURLCache sharedCache] hasDataForURLString:URL.cacheableURLString];
  //YKDebug(@"Checking if URL is in disk cache took: %0.5f", ([NSDate timeIntervalSinceReferenceDate] - start));
  if (inDiskCache) {
    // Notify the delegate that we're loading the image
    if ([_delegate respondsToSelector:@selector(imageLoaderDidStart:)])
      [_delegate imageLoaderDidStart:self];
    dispatch_async([[self class] diskCacheQueue], ^{
      UIImage *cachedImage = [[YKURLCache sharedCache] diskCachedImageForURLString:URL.cacheableURLString expires:kExpiresAge];
      if (cachedImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
          // Cache the image. Cache it real good.
          YKImageMemoryCache *imageCache = [YKImageMemoryCache sharedCache];
          [imageCache cacheImage:cachedImage forKey:URL.URLString];

          [self setImage:cachedImage status:YKImageLoaderStatusLoaded];
        });
      } else {
        // Load from the URL
        YKErr(@"We thought we had cached image data but it was invalid!");
        dispatch_async(dispatch_get_main_queue(), ^{
          [self _loadImageForURL:URL];
        });
      }
    });
    return;
  }

  [self _loadImageForURL:URL];
}

- (void)_loadImageForURL:(YKURL *)URL {
  // Put the loading image in place while waiting for the request to load
  [self setImage:_loadingImage status:YKImageLoaderStatusLoading];
  [self load];
}

- (void)load {
  YKURLRequestRelease(_request);
  
  _request = [[YKURLRequest alloc] init];
  _request.expiresAge = kExpiresAge;

  static NSDictionary *headers = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Set the x-screen-scale header
    CGFloat scale = [[UIScreen mainScreen] scale];
    headers = [@{@"x-screen-scale": [NSString stringWithFormat:@"%0.1f", scale]} retain];
  });

  [_request requestWithURL:_URL headers:headers delegate:self
            finishSelector:@selector(requestDidFinish:)
              failSelector:@selector(request:failedWithError:)
            cancelSelector:@selector(requestDidCancel:)];  
  
  if ([_delegate respondsToSelector:@selector(imageLoaderDidStart:)])
    [_delegate imageLoaderDidStart:self];
}

- (void)setImage:(UIImage *)image status:(YKImageLoaderStatus)status {
  self.image = image;
  //YKDebug(@"Update image for %@", _URL);
  YKAssertMainThread();
  [_delegate imageLoader:self didUpdateStatus:status image:image];
}

- (void)cancel {
  [_request cancel];
}

- (void)setError:(YKError *)error {
  [self setImage:_errorImage status:YKImageLoaderStatusErrored];
  if ([_delegate respondsToSelector:@selector(imageLoader:didError:)])
    [_delegate imageLoader:self didError:error];  
}

#pragma mark YKURLRequestDelegate

- (void)requestDidFinish:(YKURLRequest *)request {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    UIImage *image = [UIImage imageWithData:request.responseData];
    
    dispatch_async(dispatch_get_main_queue(), ^{  
      if (!image) {
        // Image data was not recognized or was invalid, we'll error
        [self setError:[YKError errorWithKey:YKErrorRequest]];
      } else {
        if (image && request.URL.cacheableURLString) {
          [[YKImageMemoryCache sharedCache] cacheImage:image forKey:request.URL.cacheableURLString];
        }
        [self setImage:image status:YKImageLoaderStatusLoaded];
      }
    });
  });
}

- (void)request:(YKURLRequest *)request failedWithError:(NSError *)error {
  [self setImage:_errorImage status:YKImageLoaderStatusErrored];
  if ([_delegate respondsToSelector:@selector(imageLoader:didError:)])
    [_delegate imageLoader:self didError:[YKError errorWithKey:YKErrorRequest error:error]];
}

- (void)requestDidCancel:(YKURLRequest *)request {
  if ([_delegate respondsToSelector:@selector(imageLoaderDidCancel:)])
    [_delegate imageLoaderDidCancel:self];
}

@end

@implementation YKImageLoaders

- (void)dealloc {
  [_imageLoaders release];
  [super dealloc];
}

+ (YKImageLoaders *)shared {
  static dispatch_once_t predicate;
  static YKImageLoaders *gShared = nil;
  
  dispatch_once(&predicate, ^{
    gShared = [[self alloc] init];
  });
  return gShared;
}

- (void)add:(YKImageLoader *)imageLoader {
  YKAssert(!imageLoader.delegate, @"Delegate shouldn't be set already");
  if (!_imageLoaders) _imageLoaders = [[NSMutableArray alloc] init];
  [_imageLoaders addObject:imageLoader];
  imageLoader.delegate = self;
}

- (void)remove:(YKImageLoader *)imageLoader {
  imageLoader.delegate = nil;
  [imageLoader retain];
  [_imageLoaders removeObject:imageLoader];
  [imageLoader autorelease];
}

- (void)imageLoader:(YKImageLoader *)imageLoader didUpdateStatus:(YKImageLoaderStatus)status image:(UIImage *)image {
  switch (status) {
    case YKImageLoaderStatusLoaded:
    case YKImageLoaderStatusErrored:
      [self remove:imageLoader];
      break;
    default:
      break;
  }
}

@end