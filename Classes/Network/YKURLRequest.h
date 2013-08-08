//
//  YKURLRequest.h
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

#import "YKError.h"
#import "YKURL.h"
#import "YKCompressor.h"

// Supported HTTP methods
typedef enum {
  YKHTTPMethodNone = 0,
  YKHTTPMethodGet,
  YKHTTPMethodPostMultipart,
  YKHTTPMethodPostMultipartCompressed,
  YKHTTPMethodPostForm,
  YKHTTPMethodHead,
} YKHTTPMethod;

// Deprecated; TODO(gabe): Remove after search/replace
typedef enum {
  YPHTTPMethodGet = 1,
  YPHTTPMethodPostMultipart,
  YPHTTPMethodPostMultipartCompressed,
  YPHTTPMethodPostForm,
  YPHTTPMethodHead,
} YPHTTPMethod;

typedef enum {
  YKURLRequestCachePolicyDisabled = 0,
  YKURLRequestCachePolicyEnabled, // Default
  YKURLRequestCachePolicyIfModifiedSince, // Currently not implemented
} YKURLRequestCachePolicy;


extern NSString *const kYKURLRequestDefaultContentType;
extern const double kYKURLRequestExpiresAgeMax;

@class YKURLRequest;

/*!
 Request finished block. Object will be NSData or object if a YKJSONRequest.
 */
typedef void (^YKURLRequestFinishBlock)(id obj);

/*!
 Fail block. If error is nil, it means the request was cancelled.
 */
typedef void (^YKURLRequestFailBlock)(YKHTTPError *error);

/*!
 URL request.
 
 To disable cache through user defaults, set NSUserDefaults#boolForKey:@"YKURLRequestCacheDisabled".
 */
@interface YKURLRequest : NSObject {
  
  id __delegate; // weak; Retained while connection is active; Prefixed with __ so subclasses aren't encouraged to access directly
  SEL _finishSelector;
  SEL _failSelector;
  SEL _cancelSelector;
  
  YKURLRequestFinishBlock _finishBlock; 
  YKURLRequestFailBlock _failBlock;
  
  YKURL *_URL;
  YPHTTPMethod _method;
  
  NSTimeInterval _timeout;
  
  NSMutableURLRequest *_request;
  NSURLConnection *_connection; 
  NSMutableData *_downloadedData;
  NSURLResponse *_response;
  
  BOOL _started;
  BOOL _stopped;
  BOOL _cancelled;
  BOOL _cacheHit;
  BOOL _inCache;
  
  NSRunLoop *_runLoop;
  
  // For caching
  NSCachedURLResponse *_cachedResponse;
  BOOL _cacheEnabled;
  NSTimeInterval _secondsCacheExpiresAfter;

  // For mocking
  NSData *_mockResponse;
  NSTimeInterval _mockResponseDelayInterval;
  
  // If errored 
  YKError *_error;  

  // For metrics (intervals from reference date)
  NSTimeInterval _startData;
  
  NSUInteger _bytesWritten;
  
  NSTimer *_timer;
}

@property (readonly, nonatomic) NSURLConnection *connection;
@property (readonly, nonatomic) NSMutableURLRequest *request;
@property (readonly, nonatomic) NSURLResponse *response;
@property (retain, nonatomic) id delegate;
@property (assign, nonatomic) NSTimeInterval timeout;
@property (readonly, nonatomic) NSMutableData *downloadedData;
@property (readonly, nonatomic, getter=isCacheHit) BOOL cacheHit; // YES if there was a cache hit for request
@property (readonly, nonatomic, getter=isInCache) BOOL inCache; // YES if this request was cached (after valid response)
@property (readonly, nonatomic, getter=isStopped) BOOL stopped; // YES if request has cancelled or finished
@property (readonly, nonatomic) BOOL started;

@property (readonly, nonatomic) SEL finishSelector;
@property (readonly, nonatomic) SEL failSelector;
@property (readonly, nonatomic) SEL cancelSelector;

@property (readonly, nonatomic) YKError *error;

@property (readonly, nonatomic) YKURL *URL;

@property (retain, nonatomic) NSData *mockResponse;
@property (assign, nonatomic) NSTimeInterval mockResponseDelayInterval;

@property (readonly, nonatomic) NSTimeInterval start; // When request started
@property (readonly, nonatomic) NSTimeInterval dataInterval; // Time for receiving data  
@property (readonly, nonatomic) NSTimeInterval totalInterval; // Total time for request
@property (readonly, nonatomic) NSTimeInterval sentInterval; // From start to end of sent data
@property (readonly, nonatomic) NSTimeInterval responseInterval; // Time to receive the response (header)
@property (readonly, nonatomic) NSUInteger bytesWritten;

// Response data
@property (readonly, retain, nonatomic) NSData *responseData;

@property (retain, nonatomic) NSRunLoop *runLoop;

/*!
 Enable caching for the API request with expiration interval from current time.  Typically called by subclasses in init.
 @param cacheEnabled Caching will be enabled for this API request if passed YES
 @param expiresAfter Time interval from current time at which to expire the cache
 */
- (void)setCacheEnabled:(BOOL)cacheEnabled expiresAfter:(NSTimeInterval)expiresAfter;

- (BOOL)shouldCacheData:(NSData *)data forKey:(id)key;

- (NSURL *)URLToCacheFromURL:(NSURL *)URL;

+ (void)invalidateCacheNamespaceWithDate:(NSDate *)date;

/*!
 Request using already loaded cached data.
 @param URL URL
 @param cachedData Cached data for URL request
 @param response Response to URL request
 */
- (void)requestWithURL:(YKURL *)URL cachedData:(NSData *)data response:(NSURLResponse *)response;

/*!
 GET request. 
 @param URL URL
 @param finishBlock 
 @param failBlock
 @result NO if we were unable to make the request with the parameters
 
 Server errors (status >= 300) are reported as the code of the error object.
 */
- (BOOL)requestWithURL:(YKURL *)URL finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock;

/*!
 GET request. 
 @param URL URL
 @param finishBlock 
 @param failBlock
 @result Request, or nil if we were unable to make the request with the parameters
 
 Server errors (status >= 300) are reported as the code of the error object.
 */
+ (id)requestWithURL:(YKURL *)URL finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock;

/*!
 GET the URL.
 The delegate is retained for the duration of the connection.
 
 The delegate must provide and implement the finished and failed selectors.
 
 @param URL URL
 @param headers Headers to include in request
 @param delegate Delegate
 @param finishSelector Finished selector, with a signature like:
      
      - (void)requestDidFinish:(YKURLRequest *)request object:(id)object;

 @param failSelector Failure selector, with a signature like:

      - (void)request:(YKURLRequest *)request failedWithError:(YKError *)error;

 @param cancelSelector Cancel selector, with a signature like:

      - (void)requestDidCancel:(YKURLRequest *)request;

 @result NO if we were unable to make the request with the parameters
 
 Server errors (status >= 300) are reported as the code of the error object.
 */
- (BOOL)requestWithURL:(YKURL *)URL headers:(NSDictionary *)headers delegate:(id)delegate finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector cancelSelector:(SEL)cancelSelector;

/*!
 Request URL with method.
 
 @param URL URL
 @param method Method
 @param headers Headers to include in request
 @param postParams Post data
 @param keyEnumerator Enumerator for ordering post data
 @param finishBlock 
 @param failBlock
 @result NO if we were unable to make the request with the parameters
 
 Server errors (status >= 300) are reported as the code of the error object.
 */
- (BOOL)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method headers:(NSDictionary *)headers postParams:(NSDictionary *)postParams keyEnumerator:(NSEnumerator *)keyEnumerator finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock;

/*!
 Request URL with method.
 
 @param URL URL
 @param method Method
 @param headers Headers to include in request
 @param postParams Post data
 @param keyEnumerator Enumerator for ordering post data
 @param finishBlock 
 @param failBlock
 @result Request, or nil if we were unable to make the request with the parameters
 
 Server errors (status >= 300) are reported as the code of the error object.
 */
+ (id)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method headers:(NSDictionary *)headers postParams:(NSDictionary *)postParams keyEnumerator:(NSEnumerator *)keyEnumerator finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock;

/*!
 Request URL with method.
 
 @param URL URL
 @param method Method
 @param postParams Post data
 @param finishBlock 
 @param failBlock
 @result NO if we were unable to make the request with the parameters
 
 Server errors (status >= 300) are reported as the code of the error object.
 */
- (BOOL)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method postParams:(NSDictionary *)postParams finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock;

/*!
 Request URL with method.
 
 @param URL URL
 @param method Method
 @param postParams Post data
 @param finishBlock 
 @param failBlock
 @result Request, or nil if we were unable to make the request with the parameters
 
 Server errors (status >= 300) are reported as the code of the error object.
 */
+ (id)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method postParams:(NSDictionary *)postParams finishBlock:(YKURLRequestFinishBlock)finishBlock failBlock:(YKURLRequestFailBlock)failBlock;

/*!
 Request the URL.
 The delegate is retained for the duration of the connection.
 
 The delegate must provide and implement the finished and failed selectors.
 
 @param URL URL
 @param method Method
 @param headers Headers to include in request
 @param postParams Post data
 @param keyEnumerator Enumerator for ordering post data
 @param delegate Delegate
 @param finishSelector Finished selector, with a signature like:

      - (void)requestDidFinish:(YKURLRequest *)request object:(id)object;

 @param failSelector Failure selector, with a signature like:

      - (void)request:(YKURLRequest *)request failedWithError:(YKError *)error;

 @param cancelSelector Cancel selector, with a signature like:

      - (void)requestDidCancel:(YKURLRequest *)request;

 @result NO if we were unable to make the request with the parameters
 
 Server errors (status >= 300) are reported as the code of the error object.
 */
- (BOOL)requestWithURL:(YKURL *)URL method:(YPHTTPMethod)method headers:(NSDictionary *)headers postParams:(NSDictionary *)postParams keyEnumerator:(NSEnumerator *)keyEnumerator delegate:(id)delegate finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector cancelSelector:(SEL)cancelSelector;

/*!
 Cancel request. 
 Issues a cancelled notification to the delegate's cancelSelector, or call failBlock with a NULL error.
 */
- (void)cancel;

/*!
 Cancel request. 
 @param notify If notify, issues a cancelled notification to the delegate's cancelSelector, or call failBlock with a NULL error.
 */
- (void)cancel:(BOOL)notify;

/*!
 Close request. Releases connection and delegate.
 */
- (void)close;

- (void)setHTTPBodyFormData:(NSDictionary *)form;

/*!
 Set the HTTP multipart data.

 @param multipart Dictionary where key is name and value can be NSNumber, NSString, NSData or YKURLRequestDataPart
 @param keyEnumerator The ordering of the multipart data
 @param compress If YES, will apply the compressor
 */
- (void)setHTTPBodyMultipart:(NSDictionary *)multipart keyEnumerator:(NSEnumerator *)keyEnumerator compress:(BOOL)compress;

/*!
 Set whether to ignore auth errors. Useful for testing in debug environments with self signed certs.
 @param authProtectionDisabled Whether to disable protection
 */
+ (void)setAuthProtectionDisabled:(BOOL)authProtectionDisabled;

/*!
 Set the HTTP body data.

 @param data Data
 @param compress If specified, will apply the compressor
 */
- (void)setHTTPBody:(NSData *)data compress:(BOOL)compress;

+ (NSData *)HTTPBodyForMultipart:(NSDictionary *)multipart;

+ (NSData *)HTTPBodyForMultipart:(NSDictionary *)multipart keyEnumerator:(NSEnumerator *)keyEnumerator;

/*!
 @result the compressor used for request compression.
 */
+ (id<YKCompressor>)compressor;

/*!
 Set the compressor used for request compression.
 A compressor for gzip with GTM would look like:
 
     #import "GTMNSData+zlib.h"

     @implementation YPGZipCompressor
     
     + (YPGZipCompressor *)compressor {
      return [[[YPGZipCompressor alloc] init] autorelease];
     }
     
     - (NSData *)compressData:(NSData *)data {
      return [NSData gtm_dataByGzippingData:data];
     }
     
     - (NSString *)contentEncoding {
      return @"gzip";
     } 
     @end

 @param compressor Compressor to use
 */
+ (void)setCompressor:(id<YKCompressor>)compressor;

/*!
 Connection class (for mocking).

 @result Connection class
 */
+ (Class)connectionClass;

/*!
 Override connection class.

 @param theClass Class to use for connection
 */
+ (void)setConnectionClass:(Class)theClass;

/*!
 Set gloval connection timeout.
 
 @param connectionTimeout
 */
+ (void)setConnectionTimeout:(NSTimeInterval)connectionTimeout;

/*!
 Response status code (If HTTP response, the HTTP response code.)
 */
- (NSInteger)responseStatusCode;

/*!
 Response headers.
 */
- (NSDictionary *)responseHeaderFields;

/*!
 Date from response header, if any.
 */
- (NSDate *)responseDate;

/*!
 Get downloaded data as string (UTF-8).
 */
- (NSString *)downloadedDataAsString;

/*!
 Object for data. 

 By default this returns the same data object passed in.
 
 Subclasses can override to create an object from the data.
 For example, a JSON request might implement this method to parse the 
 NSData and return an NSArray or NSDictionary.
 */
- (id)objectForData:(NSData *)data error:(YKError **)error;

/*!
 Error for status and response data.
 
 By default this returns a YKHTTPError instance.
 
 @param HTTPStatus HTTP status
 @param data Data
 */
- (YKHTTPError *)errorForHTTPStatus:(NSInteger)HTTPStatus data:(NSData *)data;

/*!
 Description of request metrics.
 */
- (NSString *)metricsDescription;


- (void)willRequestURL:(YKURL *)URL;
- (void)didLoadData:(NSData *)data withResponse:(NSURLResponse *)response cacheKey:(NSString *)cacheKey;

// Notifies of didError OR didFinish OR didCancel
- (void)didError:(YKError *)error;
- (void)didFinishWithData:(NSData *)data cacheKey:(NSString *)cacheKey;
- (void)didCancel;


@end


#define YKURLRequestRelease(__REQUEST__) \
do { \
__REQUEST__.delegate = nil; \
[__REQUEST__ cancel]; \
[__REQUEST__ release]; \
__REQUEST__ = nil; \
} while (0)


#define YKURLRequestCancel(__REQUEST__, __NOTIFY__) \
do { \
__REQUEST__.delegate = nil; \
[__REQUEST__ cancel:__NOTIFY__]; \
} while (0)



/*!
 YKURLRequest data part.
 */
@interface YKURLRequestDataPart : NSObject

@property (retain, nonatomic) NSString *contentType;
@property (retain, nonatomic) NSData *data;

+ (YKURLRequestDataPart *)text:(NSString *)text;

@end
