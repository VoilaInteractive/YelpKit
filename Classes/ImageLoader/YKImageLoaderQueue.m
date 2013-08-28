//
//  YKImageLoaderQueue.m
//  YelpKit
//
//  Created by Gabriel Handford on 6/21/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YKImageLoaderQueue.h"
#import "YKDefines.h"


@implementation YKImageLoaderQueue

- (id)init {
  if ((self = [super init])) {
    _waitingQueue = [[NSMutableArray alloc] initWithCapacity:40];
    _loadingQueue = [[NSMutableArray alloc] initWithCapacity:40];
    _maxLoadingCount = 2;
  }
  return self;
}

- (void)dealloc {  
  for (YKImageLoader *imageLoader in _waitingQueue)
    imageLoader.queue = nil;
  
  for (YKImageLoader *imageLoader in _loadingQueue)
    imageLoader.queue = nil;
  
  [_waitingQueue release];
  [_loadingQueue release];  
  [super dealloc];
}

+ (YKImageLoaderQueue *)sharedQueue {
  static dispatch_once_t predicate;
  static YKImageLoaderQueue *gSharedQueue = nil;
  
  dispatch_once(&predicate, ^{
    gSharedQueue = [[self alloc] init];
  });
  return gSharedQueue;
}

- (void)_updateIndicator {
  if ([_waitingQueue count] == 0 && [_loadingQueue count] == 0) [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  else [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)enqueue:(YKImageLoader *)imageLoader {
  YKAssertMainThread();
  if (![_waitingQueue containsObject:imageLoader]) {
    [_waitingQueue addObject:imageLoader];
    [self check];
    [self _updateIndicator];
  }
}

- (void)dequeue:(YKImageLoader *)imageLoader {
  YKAssertMainThread();  
  imageLoader.queue = nil;
  [_waitingQueue removeObject:imageLoader];
  [_loadingQueue removeObject:imageLoader];
  [self _updateIndicator];
}

- (void)check {
  if ([_loadingQueue count] < _maxLoadingCount && [_waitingQueue count] > 0) {    
    YKImageLoader *imageLoader = _waitingQueue[0];
    [_loadingQueue addObject:imageLoader];
    [_waitingQueue removeObjectAtIndex:0];
    imageLoader.queue = self;
    [imageLoader load];
    [self _updateIndicator];
  }
}

- (void)imageLoaderDidEnd:(YKImageLoader *)imageLoader {
  imageLoader.queue = nil;
  [_loadingQueue removeObject:imageLoader];
  [self _updateIndicator];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
    [self check];
  });
}

@end

