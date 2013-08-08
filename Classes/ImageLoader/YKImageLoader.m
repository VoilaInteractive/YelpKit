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
#import "YKImageLoaderQueue.h"
#import "YKURLRequest.h"

@interface YKImageLoader ()
@property (retain, nonatomic) YKURL *URL;
- (void)setImage:(UIImage *)image status:(YKImageLoaderStatus)status;
@end

#define kExpiresAge YKTimeIntervalWeek

static UIImage *gYKImageLoaderMockImage = NULL;
static dispatch_queue_t gYKImageLoaderDiskCacheQueue = NULL;

@implementation YKImageLoader

@synthesize URL=_URL, image=_image, loadingImage=_loadingImage, defaultImage=_defaultImage, errorImage=_errorImage, delegate=_delegate, queue=_queue;

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
  if (!gYKImageLoaderDiskCacheQueue) {
    gYKImageLoaderDiskCacheQueue = dispatch_queue_create("com.YelpKit.YKImageLoader.diskCacheQueue", 0);
  }
  return gYKImageLoaderDiskCacheQueue;
}

- (id)initWithLoadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage delegate:(id<YKImageLoaderDelegate>)delegate {
  return [self initWithLoadingImage:loadingImage defaultImage:defaultImage errorImage:nil delegate:delegate];
}

- (id)initWithLoadingImage:(UIImage *)loadingImage defaultImage:(UIImage *)defaultImage errorImage:(UIImage *)errorImage delegate:(id<YKImageLoaderDelegate>)delegate {
  if ((self = [self init])) {
    _loadingImage = [loadingImage retain];
    _defaultImage = [defaultImage retain];
    _errorImage = [errorImage retain];
    _delegate = delegate;
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
  // Use queue by default
  [self setURL:URL queue:[YKImageLoaderQueue sharedQueue]];
}

- (void)setURL:(YKURL *)URL queue:(YKImageLoaderQueue *)queue {  
  if (![NSThread isMainThread]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _setURL:URL queue:queue];
    });
  } else {
    [self _setURL:URL queue:queue];
  }
}
  
- (void)_setURL:(YKURL *)URL queue:(YKImageLoaderQueue *)queue {  
  YKAssertMainThread();
  [self cancel];
  [URL retain];
  [_URL release];
  _URL = URL;  
  [_image release];
  _image = nil;
  _queue = queue;
   
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

  [self _loadImageForURL:URL];
}

- (void)_loadImageForURL:(YKURL *)URL {
  // Put the loading image in place while waiting for the request to load
  [self setImage:_loadingImage status:YKImageLoaderStatusLoading];
  
  if (_queue) {
    [_queue enqueue:self];
  } else {
    [self load];
  }
}

- (void)load {
  YKURLRequestRelease(_request);
  
  _request = [[YKURLRequest alloc] init];
  [_request setCacheEnabled:YES expiresAfter:kExpiresAge];
  
  static NSDictionary *headers = nil;
  if (!headers) {
    // Set the x-screen-scale header
    CGFloat scale = [[UIScreen mainScreen] scale];
    headers = [@{@"x-screen-scale": [NSString stringWithFormat:@"%0.1f", scale]} retain];
  }

  [_request requestWithURL:_URL headers:headers delegate:self
            finishSelector:@selector(requestDidFinish:)
              failSelector:@selector(request:failedWithError:)
            cancelSelector:@selector(requestDidCancel:)];  
  
  if ([_delegate respondsToSelector:@selector(imageLoaderDidStart:)])
    [_delegate imageLoaderDidStart:self];
}

- (void)setImage:(UIImage *)image status:(YKImageLoaderStatus)status {
  //if (image == _image) return;
  [image retain];
  [_image release];
  _image = image;  
  YKAssertMainThread();
  [_delegate imageLoader:self didUpdateStatus:status image:image];
}

- (void)cancel {
  [_queue dequeue:self];
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
      [_queue imageLoaderDidEnd:self];
    });
  });
}

- (void)request:(YKURLRequest *)request failedWithError:(NSError *)error {
  [self setImage:_errorImage status:YKImageLoaderStatusErrored];
  if ([_delegate respondsToSelector:@selector(imageLoader:didError:)])
    [_delegate imageLoader:self didError:[YKError errorWithKey:YKErrorRequest error:error]];
  [_queue imageLoaderDidEnd:self];
}

- (void)requestDidCancel:(YKURLRequest *)request {
  if ([_delegate respondsToSelector:@selector(imageLoaderDidCancel:)])
    [_delegate imageLoaderDidCancel:self];
  [_queue imageLoaderDidEnd:self];
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