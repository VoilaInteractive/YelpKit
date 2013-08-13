//
//  YKUIAlertView.m
//  YelpKit
//
//  Created by Gabriel Handford on 7/16/09.
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

#import "YKUIAlertView.h"
#import "YKLocalized.h"
#import "YKDefines.h"

@implementation YKUIAlertView

- (id)initWithBlock:(YKUIAlertViewBlock)block {
  if ((self = [super init])) {
    _block = Block_copy(block);
  }
  return self;
}

- (id)initWithTarget:(id)target action:(SEL)action context:(id)context {
  if ((self = [super init])) {
    YKAssertSelectorImplemented(target, action);
    __block YKUIAlertView *blockSelf = self;
    _block = Block_copy(^(NSInteger index) {
      [[target gh_argumentProxy:action] alertView:(id)blockSelf clickedButtonAtIndex:index context:context];
    });
  }
  return self;
}

- (void)dealloc {
  Block_release(_block);
  [super dealloc];
}

+ (void)showAlertWithBlock:(YKUIAlertViewBlock)block title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle, ... {
  va_list args;
  va_start(args, otherButtonTitle);
  [self showAlertWithBlock:block title:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitle args:args];
  va_end(args);
}

+ (void)showAlertWithBlock:(YKUIAlertViewBlock)block title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle args:(va_list)args {
  
  YKUIAlertView *delegate = [[YKUIAlertView alloc] initWithBlock:block]; // Released in alertView:clickedButtonAtIndex: ([self autorelease])
  
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
  
  while(otherButtonTitle) {
    [alertView addButtonWithTitle:otherButtonTitle];
    otherButtonTitle = va_arg(args, id);
  }
  
  [alertView show];
  [alertView release];
}

+ (void)showAlertWithTarget:(id)target action:(SEL)action context:(id)context title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle, ... {  
  va_list args;
  va_start(args, otherButtonTitle);
  [self showAlertWithTarget:target action:action context:context title:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitle args:args];
  va_end(args);
}

+ (void)showAlertWithTarget:(id)target action:(SEL)action context:(id)context title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle args:(va_list)args {
  
  YKUIAlertView *delegate = [[YKUIAlertView alloc] initWithTarget:target action:action context:context]; // Released in alertView:clickedButtonAtIndex: ([self autorelease])
  
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
  
  while(otherButtonTitle) {
    [alertView addButtonWithTitle:otherButtonTitle];
    otherButtonTitle = va_arg(args, id);
  }
  
  [alertView show];
  [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (!_block) return;
  _block(buttonIndex);
  Block_release(_block);
  _block = NULL;
  [self autorelease];
}

+ (UIAlertView *)showAlertWithMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
  [alert show];
  [alert release];
  return alert;
}

+ (UIAlertView *)showOKAlertWithMessage:(NSString *)message title:(NSString *)title {
  return [self showAlertWithMessage:message title:title cancelButtonTitle:YKLocalizedString(@"OK")];
}

@end


@implementation YKUIAlertViewTarget

- (id)initWithTarget:(id)target action:(SEL)action {
  if ((self = [super init])) {
    YKAssertSelectorImplemented(target, action);
    _target = [target retain];
    _action = action;
  }
  return self;
}

- (void)dealloc {
  [_target release];
  [super dealloc];
}

+ (YKUIAlertViewTarget *)target:(id)target action:(SEL)action {
  return [[[YKUIAlertViewTarget alloc] initWithTarget:target action:action] autorelease];
}

- (void)perform {
  [_target performSelector:_action];
}

@end
