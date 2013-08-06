//
//  NSObject+YKCompatibility.h
//  YelpKit
//
//  Created by Allen Cheung on 8/6/13.
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

/*!
 Wraps around gh_performIfRespondsToSelector and respondsToSelector.  
 Adds no additional functionality.  The sole purpose of this class is
 to explicitly name the iOS SDK a method is first available in, in 
 order to support multiple iOS versions at runtime.
 
 Once backward compatibility is no longer needed, methods here can be
 removed / commented, and the compiler will flag all instances where
 this is used.
 */

@interface NSObject (YKCompatibility)

- (id)yk_performIfRespondsToOS7Selector:(SEL)selector;

- (BOOL)yk_respondsToOS7Selector:(SEL)selector;

@end
