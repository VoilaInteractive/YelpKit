//
//  YKURLRequest.m
//  YelpKit
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

#import "YKURLRequest.h"

#import "YKDefines.h"
#import <YelpKit/YKUtils.h>
#import "YKNSURLCache.h"

NSString *const kYKURLRequestDefaultMultipartBoundary = @"----------------314159265358979323846";
NSString *const kYKURLRequestDefaultContentType = @"application/octet-stream";

const double kYKURLRequestExpiresAgeMax = DBL_MAX;

#if DEBUG
static NSTimeInterval gYKURLRequestDefaultTimeout = 90.0;
#else
static NSTimeInterval gYKURLRequestDefaultTimeout = 25.0;
#endif


@interface YKURLRequest ()
@property (retain, nonatomic) NSData *responseData;
@property (copy, nonatomic) YKURLRequestFinishBlock finishBlock; 
@property (copy, nonatomic) YKURLRequestFailBlock failBlock;
@end

@implementation YKURLRequest

@synthesize connection=_connection, timeout=_timeout, request=_request, response=_response, delegate=__delegate, finishSelector=_finishSelector, failSelector=_failSelector, cancelSelector=_cancelSelector, URL=_URL, mockResponse=_mockResponse, mockResponseDelayInterval=_mockResponseDelayInterval, dataInterval=_dataInterval, totalInterval=_totalInterval, start=_start, downloadedData=_downloadedData, cacheHit=_cacheHit, inCache=_inCache, stopped=_stopped, error=_error, started=_started, runLoop=_runLoop, sentInterval=_sentInterval;
@synthesize responseData=_responseData, finishBlock=_finishBlock, failBlock=_failBlock; // Private properties


- (id)init {
  if ((self = [super init])) {
    _timeout = gYKURLRequestDefaultTimeout;
    _totalInterval = -1;
    _dataInterval = -1;
    _responseInterval = -1;
    _sentInterval = -1;
  }
  return self;
}

- (void)dealloc {
  [self _stop];
  [_timer invalidate];
  _timer = nil;
  [__delegate release];
  __delegate = nil;
  [_URL release];

  [_request release];
  [_connection release];
  [_downloadedData release];
  [_response release];  
  [_mockResponse release];
  [_error release];
  [_responseData release];
  Block_release(_finishBlock);
  Block_release(_failBlock);
  [_cachedResponse release];
  [super dealloc];
}

- (NSString *)description {
  NSInteger statusCode = 0;
  NSDictionary *headerFields = nil;
  if ([_response isKindOfClass:[NSHTTPURLResponse class]]) {
    statusCode = [(NSHTTPURLResponse *)_response statusCode];
    headerFields = [(NSHTTPURLResponse *)_response allHeaderFields];
  }
  
  return [NSString stringWithFormat:@"{\n\tURL = \"%@\";\n\tstatusCode: \"%d\";\n\theaderFields = \"%@\";\n}", _URL, statusCode, headerFields];
}

#pragma mark Caching

- (void)setCacheEnabled:(BOOL)cacheEnabled expiresAfter:(NSTimeInterval)expiresAfter {
  _cacheEnabled = cacheEnabled;
  _secondsCacheExpiresAfter = expiresAfter;
}

- (BOOL)shouldCacheData:(NSData *)data forKey:(id)key {
  return _cacheEnabled;
}

- (BOOL)_shouldAttemptCacheLoad {
  return _cacheEnabled;
}

- (void)requestWithURL:(YKURL *)URL cachedData:(NSData *)data response:(NSURLResponse *)response {
  _URL = [URL retain];
  _cacheHit = YES;
  [[self gh_proxyAfterDelay:0] didLoadData:data withResponse:response cacheKey:nil];
}

- (NSURLRequest *)URLRequestForCacheLookup {
  return [[[NSURLRequest alloc] initWithURL:[[self class] URLToCacheFromURL:[_URL NSURL]]] autorelease];
}

+ (NSURL *)URLToCacheFromURL:(NSURL *)URL {
  return URL;
}

+ (NSString *)cacheNameSpace {
  return NSStringFromClass([self class]);
}

+ (void)invalidateCacheNamespaceWithDate:(NSDate *)date {
  [[YKNSURLCache sharedURLCache] invalidateCacheNameSpace:[YKURLRequest cacheNameSpace] withDate:date];
}

#pragma mark -

- (BOOL)requestWithURL:(YKURL *)URL headers:(NSDictionary *)headers delegate:(id)delegate finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector cancelSelector:(SEL)cancelSelector {
  return [self requestWithURL:URL method:YPHTTPMethodGet headers:headers postParams:nil keyEnumerator:nil delegate:delegate finishSelector:finishSelector failSelector:failSelector cancelSelector:cancelSelector];
}

+ (id)requestWithURL:(YKURL *)URL finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock {
  YKURLRequest *request = [[[[self class] alloc] init] autorelease];
  if ([request requestWithURL:URL finishBlock:finishBlock failBlock:failBlock]) return request;
  return nil;
}

- (BOOL)requestWithURL:(YKURL *)URL finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock {
  return [self requestWithURL:URL method:YPHTTPMethodGet headers:nil postParams:nil keyEnumerator:nil finishBlock:finishBlock failBlock:failBlock];
}

+ (id)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method postParams:(NSDictionary *)postParams finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock {
  YKURLRequest *request = [[[[self class] alloc] init] autorelease];
  if ([request requestWithURL:URL method:method postParams:postParams finishBlock:finishBlock failBlock:failBlock]) return request;
  return nil;
}

+ (id)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method headers:(NSDictionary *)headers postParams:(NSDictionary *)postParams keyEnumerator:(NSEnumerator *)keyEnumerator finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock {
  YKURLRequest *request = [[[[self class] alloc] init] autorelease];
  if ([request requestWithURL:URL method:method headers:headers postParams:postParams keyEnumerator:keyEnumerator finishBlock:finishBlock failBlock:failBlock]) return request;
  return nil;
}
                
- (BOOL)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method headers:(NSDictionary *)headers postParams:(NSDictionary *)postParams keyEnumerator:(NSEnumerator *)keyEnumerator finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock {
  
  self.finishBlock = finishBlock;
  self.failBlock = failBlock;
  
  return [self _requestWithURL:URL method:method headers:headers postParams:postParams keyEnumerator:keyEnumerator];
}

- (BOOL)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method postParams:(NSDictionary *)postParams finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock {
  return [self requestWithURL:URL method:method headers:nil postParams:postParams keyEnumerator:nil finishBlock:finishBlock failBlock:failBlock];
}


- (BOOL)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method headers:(NSDictionary *)headers postParams:(NSDictionary *)postParams keyEnumerator:(NSEnumerator *)keyEnumerator delegate:(id)delegate finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector cancelSelector:(SEL)cancelSelector {
    
  self.delegate = delegate; // Retained only for life of connection
  _finishSelector = finishSelector;
  _failSelector = failSelector;
  _cancelSelector = cancelSelector;
 
  return [self _requestWithURL:URL method:method headers:headers postParams:postParams keyEnumerator:keyEnumerator];
}

- (BOOL)_requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method headers:(NSDictionary *)headers postParams:(NSDictionary *)postParams keyEnumerator:(NSEnumerator *)keyEnumerator {

  if (_started) [NSException raise:NSInternalInconsistencyException format:@"Re-using a request more than once is not supported."];
  _started = YES;
  
  _URL = [URL retain];
  _method = method;
  NSAssert(_method != YKHTTPMethodNone, @"Invalid method");
  
#if DEBUG
  // Check mock
  if (_mockResponse) {
    YKDebug(@"Mock response for: %@", _URL);
    // Manually create a cached response for the mock here
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[_URL NSURL] statusCode:200 HTTPVersion:nil headerFields:nil];
    [_cachedResponse release];
    _cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:_mockResponse];
    [response release];
    if (_mockResponseDelayInterval > 0) {
      [[self gh_proxyAfterDelay:_mockResponseDelayInterval] didLoadData:_mockResponse withResponse:nil cacheKey:nil];    
    } else {
      [self didLoadData:_mockResponse withResponse:nil cacheKey:nil];    
    }
    return YES;
  }
#endif
  
  // Check cache
  if ([self _shouldAttemptCacheLoad]) {
    BOOL stale = NO;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[self class] URLToCacheFromURL:[_URL NSURL]]];
    NSCachedURLResponse *cachedResponse = [[YKNSURLCache sharedURLCache] cachedResponseForRequest:request expirationInterval:_secondsCacheExpiresAfter stale:&stale];
    if (cachedResponse && !stale) {
      [self requestWithURL:(YKURL *)URL cachedData:cachedResponse.data response:cachedResponse.response];
      return YES;
    }
  }
  
  // Notify that we will request
  [self willRequestURL:_URL];
  
  [_request release];
  _request = [[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_URL URLString]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeout] retain];
  
  // TODO(gabe): Investigate If-Modified-Since header
//  NSDate *lastModifiedDate = [[self cache] lastModifiedDateForURLString:_URL.cacheableURLString];
//  if (lastModifiedDate) {
//    YKDebug(@"If modified since: %@", [lastModifiedDate gh_formatHTTP]);
//    [_request setValue:[lastModifiedDate gh_formatHTTP] forHTTPHeaderField:@"If-Modified-Since"];
//  }
  
  if (headers) {
    for(NSString *key in headers) {      
      [_request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
  }
  
  [_downloadedData release];
  _downloadedData = nil;
  _downloadedData = [[NSMutableData alloc] init];
  
  Class connectionClass = [[self class] connectionClass];
  
  BOOL useCustomTimer = NO;
  if (method == YPHTTPMethodPostMultipart) {
    [_request setHTTPMethod:@"POST"]; 
    [self setHTTPBodyMultipart:postParams keyEnumerator:keyEnumerator compress:NO];
    useCustomTimer = YES;
  } else if (method == YPHTTPMethodPostMultipartCompressed) {
    [_request setHTTPMethod:@"POST"]; 
    [self setHTTPBodyMultipart:postParams keyEnumerator:keyEnumerator compress:YES];
    useCustomTimer = YES;
  } else if (method == YPHTTPMethodPostForm) {
    [_request setHTTPMethod:@"POST"]; 
    [self setHTTPBodyFormData:postParams];
    useCustomTimer = YES;
  } else if (method == YPHTTPMethodHead) {
    [_request setHTTPMethod:@"HEAD"]; 
  }
  _start = [NSDate timeIntervalSinceReferenceDate];
  if (useCustomTimer) {
    _timer = [NSTimer scheduledTimerWithTimeInterval:_timeout target:self selector:@selector(_timeout) userInfo:nil repeats:NO];
  }
  _connection = [[connectionClass alloc] initWithRequest:_request delegate:self startImmediately:NO];   
  [self _start];
  return YES;
}

- (void)_timeout {
  if (_stopped) return;
  [_timer invalidate];
  _timer = nil;
  [self didError:[YKError errorWithKey:YKErrorCannotConnectToHost]];
}

- (void)_start {
  [_connection scheduleInRunLoop:(self.runLoop ? self.runLoop : [NSRunLoop mainRunLoop]) forMode:NSDefaultRunLoopMode];
  [_connection start];
}

- (void)cancel {
  [self cancel:YES];
}

- (void)cancel:(BOOL)notify {
  _cancelled = YES;
  if (_stopped) {
    return;
  } 
  [self didCancel];
  if (notify) {
    if (_cancelSelector != NULL) {
      [[__delegate gh_proxyOnMainThread:YES] performSelector:_cancelSelector withObject:self];
    }
    if (_failBlock != NULL) _failBlock(nil);
  }
  [self _stop];
}

- (void)close {
  [self _stop];
}

- (void)_stop {
  _stopped = YES;
  [_timer invalidate];
  _timer = nil;
  if (_connection) {
    // In case cancelling the connection calls this recursively (from dealloc), 
    // nil connection before releasing
    NSURLConnection *oldConnection = _connection;
    _connection = nil;
    
    // This may be called in a callback from the connection, so use autorelease
    [oldConnection cancel];
    [oldConnection unscheduleFromRunLoop:(self.runLoop ? self.runLoop : [NSRunLoop mainRunLoop]) forMode:NSDefaultRunLoopMode];
    [oldConnection autorelease];         
  }
  // Delegates are retained only for the life of the connection
  [__delegate release];
  __delegate = nil;
  self.finishBlock = nil;
  self.failBlock = nil;
}

- (void)setHTTPBodyFormData:(NSDictionary *)params {
  [_request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
  NSData *data = [[NSURL gh_dictionaryToQueryString:params] dataUsingEncoding:NSUTF8StringEncoding];
  YKDebug(@"Form data: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
  [_request setHTTPBody:data];
}

- (void)setHTTPBody:(NSData *)data compress:(BOOL)compress {
  if (compress) {
    id<YKCompressor> compressor = [[self class] compressor];
    if (!compressor) [NSException raise:NSDestinationInvalidException format:@"No compressor available. Set compressor at setCompressor:"];
    [_request setValue:[compressor contentEncoding] forHTTPHeaderField:@"Content-Encoding"];
    NSData *compressedData = [compressor compressData:data];
    [_request setHTTPBody:compressedData];
  } else {
    [_request setHTTPBody:data];
  }
}

- (NSDictionary *)responseHeaderFields {
  if ([_response isKindOfClass:[NSHTTPURLResponse class]])
    return [(NSHTTPURLResponse *)_response allHeaderFields];
  return nil;
}

- (NSDate *)responseDate {
  NSString *dateString = [[self responseHeaderFields] objectForKey:@"Date"];
  return [NSDate gh_parseHTTP:dateString];
}

#pragma mark -

- (void)willRequestURL:(YKURL *)URL { }

- (void)didLoadData:(NSData *)data withResponse:(NSURLResponse *)response cacheKey:(NSString *)cacheKey {   
  // Subclasses may do processing here
  [self didFinishWithData:data cacheKey:cacheKey];
}

- (void)didError:(YKHTTPError *)error { 
  YKErr(@"Error in response: %@", error);
  [error retain];
  [_error release];
  _error = error;
  if (_failSelector != NULL) {
    [[__delegate gh_proxyOnMainThread:YES] performSelector:_failSelector withObject:self withObject:error];
  }
  if (_failBlock != NULL) _failBlock(error);
  [self _stop];
}

- (id)objectForData:(NSData *)data error:(YKError **)error {
  return data;
}

- (void)didFinishWithData:(NSData *)data cacheKey:(NSString *)cacheKey {   
  self.responseData = data;
  // TODO(gabe): In experimental threaded request, caching isn't thread safe (so this call isn't completely safe)
  // NOTE(acheung): Switching over to NSURLCache which is also not thread safe
  if (_cachedResponse && [self shouldCacheData:data forKey:cacheKey]) {
    [[YKNSURLCache sharedURLCache] storeCachedResponse:_cachedResponse forRequest:[self URLRequestForCacheLookup] timestamp:[NSDate date] expirationInterval:_secondsCacheExpiresAfter nameSpace:[YKURLRequest cacheNameSpace]];
    _inCache = YES;
  }
  [_cachedResponse release];
  _cachedResponse = nil;
  
  if (_stopped) return;

  YKError *error = nil;
  id obj = [self objectForData:data error:&error];
  if (error) {
    [self didError:error];
    return;
  }  
  
  if (_finishSelector != NULL) {
    [[__delegate gh_proxyOnMainThread:YES] performSelector:_finishSelector withObject:self withObject:obj];
  }
  if (_finishBlock != NULL) _finishBlock(obj);
  [self _stop];
}

- (void)didCancel { }

#pragma mark Debug
 
- (NSString *)metricsDescription {
  NSMutableString *string = [NSMutableString string];
  [string appendFormat:@"Response: %0.3fs\n", _totalInterval];
  if (_dataInterval > 0) {
    [string appendFormat:@"Download: %0.3fs\n", _dataInterval];
  }
  return string;
}  

- (NSString *)downloadedDataAsString {
  if (!_downloadedData) return nil;
  return [[[NSString alloc] initWithData:_downloadedData encoding:NSUTF8StringEncoding] autorelease];
}

#pragma mark Multipart POST

- (void)setHTTPBodyMultipart:(NSDictionary *)multipart keyEnumerator:(NSEnumerator *)keyEnumerator compress:(BOOL)compress {
  [_request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kYKURLRequestDefaultMultipartBoundary] forHTTPHeaderField:@"Content-Type"];
  [self setHTTPBody:[[self class] HTTPBodyForMultipart:multipart keyEnumerator:keyEnumerator] compress:compress];
}

+ (NSData *)HTTPBodyForMultipart:(NSDictionary *)multipart {
  return [self HTTPBodyForMultipart:multipart keyEnumerator:nil];
}

+ (NSData *)HTTPBodyForMultipart:(NSDictionary *)multipart keyEnumerator:(NSEnumerator *)keyEnumerator {
  NSMutableData *postBody = [NSMutableData data];
  NSData *newLineData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
  if (!keyEnumerator) keyEnumerator = [multipart keyEnumerator];
  for (NSString *key in keyEnumerator) {
    id value = [multipart objectForKey:key];
    if (!value || value == [NSNull null]) continue;
    if ([value isKindOfClass:[NSNumber class]])
      value = [(NSNumber *)value stringValue];
    if ([value isKindOfClass:[NSString class]]) {
      [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", kYKURLRequestDefaultMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
      [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
      [postBody appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
      [postBody appendData:newLineData];
    } else {      
      if ([value isKindOfClass:[NSData class]]) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", kYKURLRequestDefaultMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, key] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", kYKURLRequestDefaultContentType] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:value];
      } else if ([value isKindOfClass:[YKURLRequestDataPart class]]) {
        YKURLRequestDataPart *part = (YKURLRequestDataPart *)value;
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", kYKURLRequestDefaultMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, key] dataUsingEncoding:NSUTF8StringEncoding]];       
        [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", part.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:part.data];
      } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Only supports NSString, NSNumber, and NSData but was %@", [value class]] userInfo:nil];
      }
      [postBody appendData:newLineData];
    }
  }
  [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", kYKURLRequestDefaultMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
  return postBody;
}

#pragma mark Connection Globals

static Class gYKURLRequestConnectionClass = NULL;

+ (Class)connectionClass {
  if (gYKURLRequestConnectionClass == NULL) {
    gYKURLRequestConnectionClass = [NSURLConnection class]; 
  }
  return gYKURLRequestConnectionClass; 
}

+ (void)setConnectionClass:(Class)theClass {
  gYKURLRequestConnectionClass = theClass;
}

#pragma mark Timeout Globals

+ (void)setConnectionTimeout:(NSTimeInterval)connectionTimeout {
  gYKURLRequestDefaultTimeout = connectionTimeout;
}

#pragma mark Compressor

static id<YKCompressor> gCompressor = NULL;

+ (id<YKCompressor>)compressor {
  return gCompressor;
}

+ (void)setCompressor:(id<YKCompressor>)compressor {
  gCompressor = [compressor retain];
}

#pragma mark -

- (NSInteger)responseStatusCode {
  NSInteger status = -1;
  if ([_response respondsToSelector:@selector(statusCode)])
    status = [(NSHTTPURLResponse *)_response statusCode];

  return status;
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
  if (bytesWritten >= totalBytesExpectedToWrite) {
    _bytesWritten = bytesWritten;
    _sentInterval = [NSDate timeIntervalSinceReferenceDate] - _start;
  }
}

// This method can be called multiple times (in case of redirect)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  if (_stopped) return;
  [_downloadedData setLength:0];
  
  _responseInterval = [NSDate timeIntervalSinceReferenceDate] - _start;
  
  // In <= 3.1.1 this was set in connection:didReceiveData: so interval_data may be inaccurate
  if (_startData == 0)
    _startData = [NSDate timeIntervalSinceReferenceDate];
  
  [response retain];
  [_response release];
  _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  if (_stopped) return;
  [_downloadedData appendData:data];
}

/*!
 If this method is unimplemented it is equivalent of just returning cachedResponse, which allows Foundation to handle caching the response.
 Overriding this method and returning nil causes UIKit to not cache the response, allowing the delegate to implement custom cache behavior.
 
 Custom behavior is used for the following:
 
 1.  NSURLCache will by default overwrite cached responses with the same URL but different query parameters.  This method stores the
 cached response with a custom URL key to work around this issue.
 
 2.  Query parameters may be unique over time (e.g. a time param), causing a cache miss for using the default cache implementation.
 These params can be stripped in a subclass implementation.
 
 3.  Custom cache implementation allows setting the cache expiration in the user info dictionary, if the Cache Control headers are not
 being used.
 
 Note: this method is called before connectionDidFinishLoading:  which is where the success / failure codes may be set.  The cached 
 resopnse is stored as an ivar and caching can be handled later in didFinishWithData:cacheKey:
 */
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  [cachedResponse retain];
  [_cachedResponse release];
  _cachedResponse = cachedResponse;
  return nil;
}

static BOOL gAuthProtectionDisabled = NO;
+ (void)setAuthProtectionDisabled:(BOOL)authProtectionDisabled {
  gAuthProtectionDisabled = authProtectionDisabled;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
  if (gAuthProtectionDisabled) {
    // Accept all secure connections if protection is disabled
    return YES;
  }
  return NO; // The default
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if (_stopped) return;

  if (gAuthProtectionDisabled) {
    // Accept all secure connections if protection is disabled
    YKDebug(@"Connecting to SSL host: %@", challenge.protectionSpace.host);
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
  } else {
    [self connection:connection didFailWithError:[YKError errorWithKey:YKErrorAuthChallenge]];
  }
}

- (YKHTTPError *)errorForHTTPStatus:(NSInteger)HTTPStatus data:(NSData *)data {
  return [YKHTTPError errorWithHTTPStatus:HTTPStatus data:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if (_stopped) {
    return;
  }
  
  _dataInterval = [NSDate timeIntervalSinceReferenceDate] - _startData;
  _totalInterval = [NSDate timeIntervalSinceReferenceDate] - _start;

  NSInteger status = [self responseStatusCode];
  if (status >= 300) {
    if (_downloadedData) {
      YKDebug(@"Error: %@", [self downloadedDataAsString]);
    }
    [self didError:[self errorForHTTPStatus:status data:_downloadedData]];
  } else {
    [self didLoadData:_downloadedData withResponse:_response cacheKey:nil];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if (_stopped) return;
  if ([error isKindOfClass:[YKError class]]) {
    [self didError:(YKError *)error];
    return;
  } else if ([error domain] == NSURLErrorDomain && [error code] == NSURLErrorNotConnectedToInternet) {
    [self didError:[YKError errorWithKey:YKErrorNotConnectedToInternet error:error]];
  } else if ([error domain] == NSURLErrorDomain && [error code] == NSURLErrorCannotConnectToHost) {
     [self didError:[YKError errorWithKey:YKErrorCannotConnectToHost error:error]];
  } else if([error code] == NSURLErrorCannotFindHost) {
    [self didError:[YKError errorWithKey:YKErrorCannotFindHost error:error]];
  } else {
    [self didError:[YKError errorWithError:error]];
  }
}

@end


@implementation YKURLRequestDataPart

- (id)init {
  if ((self = [super init])) {
    _contentType = [kYKURLRequestDefaultContentType copy];
  }
  return self;
}

- (void)dealloc {
  [_data release];
  [_contentType release];
  [super dealloc];
}

+ (YKURLRequestDataPart *)text:(NSString *)text {
  YKURLRequestDataPart *part = [[YKURLRequestDataPart alloc] init];
  part.contentType = @"text/plain";
  part.data = [text dataUsingEncoding:NSUTF8StringEncoding];
  return [part autorelease];
}

@end
