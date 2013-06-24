//
//  YKUIButtonViewTest_CategoryButtons.m
//  YelpKit
//
//  Created by Allen Cheung on 6/19/13.
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

#import "YKUIButtonViewTest.h"

@interface YKUIButtonViewTest_CategoryButtons : YKUIButtonViewTest
@end

@implementation YKUIButtonViewTest_CategoryButtons

- (YKUIButton *)_facebookButtonPressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *fbButton = [self buttonPressed:pressed enabled:enabled];
  fbButton.titleShadowColor = [UIColor colorWithWhite:0.2 alpha:0.5];
  fbButton.titleShadowOffset = CGSizeMake(0, -1);
  fbButton.title = @"Facebook";
  fbButton.cornerRadius = 6.0;
  fbButton.titleColor = [UIColor whiteColor];
  fbButton.color = [UIColor colorWithRed:98.0f/255.0f green:120.0f/255.0f blue:170.0f/255.0f alpha:1.0];
  fbButton.color2 = [UIColor colorWithRed:44.0f/255.0f green:70.0f/255.0f blue:126.0f/255.0f alpha:1.0];
  fbButton.highlightedTitleColor = [UIColor whiteColor];
  fbButton.highlightedColor = [UIColor colorWithRed:70.0f/255.0f green:92.0f/255.0f blue:138.0f/255.0f alpha:1.0];
  fbButton.highlightedColor2 = [UIColor colorWithRed:44.0f/255.0f green:70.0f/255.0f blue:126.0f/255.0f alpha:1.0];
  fbButton.disabledColor = [UIColor colorWithWhite:0.6 alpha:1.0];
  fbButton.disabledColor2 = [UIColor colorWithWhite:0.7 alpha:1.0];
  fbButton.disabledBorderColor = [UIColor grayColor];
  return fbButton;
}

- (void)testFacebookButton {
  [_listView addView:[self _facebookButtonPressed:NO enabled:YES]];
  [_pressedListView addView:[self _facebookButtonPressed:YES enabled:YES]];
  [_disabledListView addView:[self _facebookButtonPressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (YKUIButton *)_inverseButtonPressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *inverseButton = [self buttonPressed:pressed enabled:enabled];
  inverseButton.titleShadowColor = [UIColor colorWithWhite:0.2 alpha:0.5];
  inverseButton.titleShadowOffset = CGSizeMake(0, -1);
  inverseButton.title = @"Inverse";
  inverseButton.titleColor = [UIColor whiteColor];
  inverseButton.color = [UIColor colorWithWhite:66.0f/255.0f alpha:1.0];
  inverseButton.color2 = [UIColor colorWithWhite:35.0f/255.0f alpha:1.0];
  inverseButton.borderColor = [UIColor colorWithWhite:48.0f/255.0f alpha:1.0];
  inverseButton.highlightedColor = [UIColor colorWithWhite:30.0f/255.0f alpha:1.0];
  inverseButton.highlightedColor2 = [UIColor colorWithWhite:34.0f/255.0f alpha:1.0];
  return inverseButton;
}

- (void)testInverseButton {
  [_listView addView:[self _inverseButtonPressed:NO enabled:YES]];
  [_pressedListView addView:[self _inverseButtonPressed:YES enabled:YES]];
  [_disabledListView addView:[self _inverseButtonPressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (YKUIButton *)_defaultButtonPressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *defaultButton = [self buttonPressed:pressed enabled:enabled];
  defaultButton.titleShadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
  defaultButton.titleShadowOffset = CGSizeMake(0, -1);
  defaultButton.title = @"Default";
  defaultButton.titleColor = [UIColor colorWithWhite:51.0f/255.0f alpha:1.0];
  defaultButton.color = [UIColor whiteColor];
  defaultButton.color2 = [UIColor colorWithWhite:0.9 alpha:1.0];
  defaultButton.titleColor = [UIColor colorWithWhite:51.0f/255.0f alpha:1.0];
  defaultButton.borderColor = [UIColor colorWithWhite:184.0f/255.0f alpha:1.0];
  defaultButton.highlightedColor = [UIColor colorWithWhite:203.0f/255.0f alpha:1.0];
  defaultButton.highlightedColor2 = [UIColor colorWithWhite:230.0f/255.0f alpha:1.0];
  return defaultButton;
}

- (void)testDefaultButton {
  [_listView addView:[self _defaultButtonPressed:NO enabled:YES]];
  [_pressedListView addView:[self _defaultButtonPressed:YES enabled:YES]];
  [_disabledListView addView:[self _defaultButtonPressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (YKUIButton *)_primaryButtonPressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *primaryButton = [self buttonPressed:pressed enabled:enabled];
  primaryButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  primaryButton.titleShadowOffset = CGSizeMake(0, -1);
  primaryButton.title = @"Primary";
  primaryButton.titleColor = [UIColor whiteColor];
  primaryButton.color = [UIColor colorWithRed:0.0f/255.0f green:133.0f/255.0f blue:204.0f/255.0f alpha:1.0];
  primaryButton.color2 = [UIColor colorWithRed:0.0f/255.0f green:69.0f/255.0f blue:204.0f/255.0f alpha:1.0];
  primaryButton.borderColor = [UIColor colorWithRed:1.0f/255.0f green:82.0f/255.0f blue:154.0f/255.0f alpha:1.0];
  primaryButton.highlightedColor = [UIColor colorWithRed:0.0f/255.0f green:60.0f/255.0f blue:180.0f/255.0f alpha:1.0];
  primaryButton.highlightedColor2 = [UIColor colorWithRed:0.0f/255.0f green:68.0f/255.0f blue:204.0f/255.0f alpha:1.0];
  return primaryButton;
}

- (void)testPrimaryButton {
  [_listView addView:[self _primaryButtonPressed:NO enabled:YES]];
  [_pressedListView addView:[self _primaryButtonPressed:YES enabled:YES]];
  [_disabledListView addView:[self _primaryButtonPressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (YKUIButton *)_infoButtonPressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *infoButton = [self buttonPressed:pressed enabled:enabled];
  infoButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  infoButton.titleShadowOffset = CGSizeMake(0, -1);
  infoButton.title = @"Info";
  infoButton.titleColor = [UIColor whiteColor];
  infoButton.color = [UIColor colorWithRed:89.0f/255.0f green:190.0f/255.0f blue:220.0f/255.0f alpha:1.0];
  infoButton.color2 = [UIColor colorWithRed:48.0f/255.0f green:151.0f/255.0f blue:181.0f/255.0f alpha:1.0];
  infoButton.borderColor = [UIColor colorWithRed:55.0f/255.0f green:132.0f/255.0f blue:154.0f/255.0f alpha:1.0];
  infoButton.highlightedColor = [UIColor colorWithRed:41.0f/255.0f green:132.0f/255.0f blue:158.0f/255.0f alpha:1.0];
  infoButton.highlightedColor2 = [UIColor colorWithRed:47.0f/255.0f green:150.0f/255.0f blue:180.0f/255.0f alpha:1.0];
  return infoButton;
}

- (void)testInfoButton {
  [_listView addView:[self _infoButtonPressed:NO enabled:YES]];
  [_pressedListView addView:[self _infoButtonPressed:YES enabled:YES]];
  [_disabledListView addView:[self _infoButtonPressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (YKUIButton *)_successButtonPressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *successButton = [self buttonPressed:pressed enabled:enabled];
  successButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  successButton.titleShadowOffset = CGSizeMake(0, -1);
  successButton.title = @"Success";
  successButton.titleColor = [UIColor whiteColor];
  successButton.color = [UIColor colorWithRed:97.0f/255.0f green:194.0f/255.0f blue:97.0f/255.0f alpha:1.0];
  successButton.color2 = [UIColor colorWithRed:81.0f/255.0f green:164.0f/255.0f blue:81.0f/255.0f alpha:1.0];
  successButton.borderColor = [UIColor colorWithRed:69.0f/255.0f green:138.0f/255.0f blue:69.0f/255.0f alpha:1.0];
  successButton.highlightedColor = [UIColor colorWithRed:71.0f/255.0f green:143.0f/255.0f blue:71.0f/255.0f alpha:1.0];
  successButton.highlightedColor2 = [UIColor colorWithRed:81.0f/255.0f green:163.0f/255.0f blue:81.0f/255.0f alpha:1.0];
  return successButton;
}

- (void)testSuccessButton {
  [_listView addView:[self _successButtonPressed:NO enabled:YES]];
  [_pressedListView addView:[self _successButtonPressed:YES enabled:YES]];
  [_disabledListView addView:[self _successButtonPressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (YKUIButton *)_warningButtonPressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *warningButton = [self buttonPressed:pressed enabled:enabled];
  warningButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  warningButton.titleShadowOffset = CGSizeMake(0, -1);
  warningButton.title = @"Warning";
  warningButton.titleColor = [UIColor whiteColor];
  warningButton.color = [UIColor colorWithRed:251.0f/255.0f green:178.0f/255.0f blue:76.0f/255.0f alpha:1.0];
  warningButton.color2 = [UIColor colorWithRed:248.0f/255.0f green:149.0f/255.0f blue:7.0f/255.0f alpha:1.0];
  warningButton.borderColor = [UIColor colorWithRed:188.0f/255.0f green:126.0f/255.0f blue:38.0f/255.0f alpha:1.0];
  warningButton.highlightedColor = [UIColor colorWithRed:218.0f/255.0f green:130.0f/255.0f blue:5.0f/255.0f alpha:1.0];
  warningButton.highlightedColor2 = [UIColor colorWithRed:248.0f/255.0f green:148.0f/255.0f blue:6.0f/255.0f alpha:1.0];
  return warningButton;
}

- (void)testWarningButton {
  [_listView addView:[self _warningButtonPressed:NO enabled:YES]];
  [_pressedListView addView:[self _warningButtonPressed:YES enabled:YES]];
  [_disabledListView addView:[self _warningButtonPressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

- (YKUIButton *)_dangerButtonPressed:(BOOL)pressed enabled:(BOOL)enabled {
  YKUIButton *dangerButton = [self buttonPressed:pressed enabled:enabled];
  dangerButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  dangerButton.titleShadowOffset = CGSizeMake(0, -1);
  dangerButton.title = @"Danger";
  dangerButton.titleColor = [UIColor whiteColor];
  dangerButton.color = [UIColor colorWithRed:236.0f/255.0f green:93.0f/255.0f blue:89.0f/255.0f alpha:1.0];
  dangerButton.color2 = [UIColor colorWithRed:190.0f/255.0f green:55.0f/255.0f blue:48.0f/255.0f alpha:1.0];
  dangerButton.borderColor = [UIColor colorWithRed:164.0f/255.0f green:60.0f/255.0f blue:55.0f/255.0f alpha:1.0];
  dangerButton.highlightedColor = [UIColor colorWithRed:166.0f/255.0f green:47.0f/255.0f blue:41.0f/255.0f alpha:1.0];
  dangerButton.highlightedColor2 = [UIColor colorWithRed:189.0f/255.0f green:54.0f/255.0f blue:47.0f/255.0f alpha:1.0];
  return dangerButton;
}

- (void)testDangerButton {
  [_listView addView:[self _dangerButtonPressed:NO enabled:YES]];
  [_pressedListView addView:[self _dangerButtonPressed:YES enabled:YES]];
  [_disabledListView addView:[self _dangerButtonPressed:NO enabled:NO]];
  GHVerifyView(_superView);
}

@end
