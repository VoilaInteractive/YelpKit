//
//  YKCatalogButtons.m
//  YelpKit
//
//  Created by Gabriel Handford on 8/2/12.
//  Copyright (c) 2012 Yelp. All rights reserved.
//

#import "YKCatalogButtons.h"

@implementation YKCatalogButtons

- (void)sharedInit {
  [super sharedInit];
  self.layout = [YKLayout layoutForView:self];
  self.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
  
  _listView = [[YKUIListView alloc] init];
  _listView.insets = UIEdgeInsetsMake(10, 10, 10, 10);
  
  //
  // Roughly in the style of twitter bootstrap buttons
  // http://twitter.github.com/bootstrap/base-css.html#buttons
  //
  
  YKUIButton *defaultButton = [self button];
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
  [_listView addView:defaultButton];
  [defaultButton release];
  
  YKUIButton *primaryButton = [self button];
  primaryButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  primaryButton.titleShadowOffset = CGSizeMake(0, -1);
  primaryButton.title = @"Primary";
  primaryButton.titleColor = [UIColor whiteColor];
  primaryButton.color = [UIColor colorWithRed:0.0f/255.0f green:133.0f/255.0f blue:204.0f/255.0f alpha:1.0];
  primaryButton.color2 = [UIColor colorWithRed:0.0f/255.0f green:69.0f/255.0f blue:204.0f/255.0f alpha:1.0];
  primaryButton.borderColor = [UIColor colorWithRed:1.0f/255.0f green:82.0f/255.0f blue:154.0f/255.0f alpha:1.0];
  primaryButton.highlightedColor = [UIColor colorWithRed:0.0f/255.0f green:60.0f/255.0f blue:180.0f/255.0f alpha:1.0];
  primaryButton.highlightedColor2 = [UIColor colorWithRed:0.0f/255.0f green:68.0f/255.0f blue:204.0f/255.0f alpha:1.0];
  [_listView addView:primaryButton];
  [primaryButton release];
  
  YKUIButton *primaryDisabledButton = [self button];
  primaryDisabledButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  primaryDisabledButton.titleShadowOffset = CGSizeMake(0, -1);
  primaryDisabledButton.title = @"Primary (Disabled)";
  primaryDisabledButton.titleColor = [UIColor whiteColor];
  primaryDisabledButton.color = [UIColor colorWithRed:0.0f/255.0f green:133.0f/255.0f blue:204.0f/255.0f alpha:1.0];
  primaryDisabledButton.color2 = [UIColor colorWithRed:0.0f/255.0f green:69.0f/255.0f blue:204.0f/255.0f alpha:1.0];
  primaryDisabledButton.borderColor = [UIColor colorWithRed:1.0f/255.0f green:82.0f/255.0f blue:154.0f/255.0f alpha:1.0];
  primaryDisabledButton.highlightedColor = [UIColor colorWithRed:0.0f/255.0f green:60.0f/255.0f blue:180.0f/255.0f alpha:1.0];
  primaryDisabledButton.highlightedColor2 = [UIColor colorWithRed:0.0f/255.0f green:68.0f/255.0f blue:204.0f/255.0f alpha:1.0];
  primaryDisabledButton.enabled = NO;
  [_listView addView:primaryDisabledButton];
  [primaryDisabledButton release];
  
  YKUIButton *infoButton = [self button];
  infoButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  infoButton.titleShadowOffset = CGSizeMake(0, -1);
  infoButton.title = @"Info";
  infoButton.titleColor = [UIColor whiteColor];
  infoButton.color = [UIColor colorWithRed:89.0f/255.0f green:190.0f/255.0f blue:220.0f/255.0f alpha:1.0];
  infoButton.color2 = [UIColor colorWithRed:48.0f/255.0f green:151.0f/255.0f blue:181.0f/255.0f alpha:1.0];
  infoButton.borderColor = [UIColor colorWithRed:55.0f/255.0f green:132.0f/255.0f blue:154.0f/255.0f alpha:1.0];
  infoButton.highlightedColor = [UIColor colorWithRed:41.0f/255.0f green:132.0f/255.0f blue:158.0f/255.0f alpha:1.0];
  infoButton.highlightedColor2 = [UIColor colorWithRed:47.0f/255.0f green:150.0f/255.0f blue:180.0f/255.0f alpha:1.0];
  [_listView addView:infoButton];
  [infoButton release];
  
  YKUIButton *successButton = [self button];
  successButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  successButton.titleShadowOffset = CGSizeMake(0, -1);
  successButton.title = @"Success";
  successButton.titleColor = [UIColor whiteColor];
  successButton.color = [UIColor colorWithRed:97.0f/255.0f green:194.0f/255.0f blue:97.0f/255.0f alpha:1.0];
  successButton.color2 = [UIColor colorWithRed:81.0f/255.0f green:164.0f/255.0f blue:81.0f/255.0f alpha:1.0];
  successButton.borderColor = [UIColor colorWithRed:69.0f/255.0f green:138.0f/255.0f blue:69.0f/255.0f alpha:1.0];
  successButton.highlightedColor = [UIColor colorWithRed:71.0f/255.0f green:143.0f/255.0f blue:71.0f/255.0f alpha:1.0];
  successButton.highlightedColor2 = [UIColor colorWithRed:81.0f/255.0f green:163.0f/255.0f blue:81.0f/255.0f alpha:1.0];
  [_listView addView:successButton];
  [successButton release];
  
  YKUIButton *warningButton = [self button];
  warningButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  warningButton.titleShadowOffset = CGSizeMake(0, -1);
  warningButton.title = @"Warning";
  warningButton.titleColor = [UIColor whiteColor];
  warningButton.color = [UIColor colorWithRed:251.0f/255.0f green:178.0f/255.0f blue:76.0f/255.0f alpha:1.0];
  warningButton.color2 = [UIColor colorWithRed:248.0f/255.0f green:149.0f/255.0f blue:7.0f/255.0f alpha:1.0];
  warningButton.borderColor = [UIColor colorWithRed:188.0f/255.0f green:126.0f/255.0f blue:38.0f/255.0f alpha:1.0];
  warningButton.highlightedColor = [UIColor colorWithRed:218.0f/255.0f green:130.0f/255.0f blue:5.0f/255.0f alpha:1.0];
  warningButton.highlightedColor2 = [UIColor colorWithRed:248.0f/255.0f green:148.0f/255.0f blue:6.0f/255.0f alpha:1.0];
  [_listView addView:warningButton];
  [warningButton release];
  
  YKUIButton *dangerButton = [self button];
  dangerButton.titleShadowColor = [UIColor colorWithWhite:0.4 alpha:0.5];
  dangerButton.titleShadowOffset = CGSizeMake(0, -1);
  dangerButton.title = @"Danger";
  dangerButton.titleColor = [UIColor whiteColor];
  dangerButton.color = [UIColor colorWithRed:236.0f/255.0f green:93.0f/255.0f blue:89.0f/255.0f alpha:1.0];
  dangerButton.color2 = [UIColor colorWithRed:190.0f/255.0f green:55.0f/255.0f blue:48.0f/255.0f alpha:1.0];
  dangerButton.borderColor = [UIColor colorWithRed:164.0f/255.0f green:60.0f/255.0f blue:55.0f/255.0f alpha:1.0];
  dangerButton.highlightedColor = [UIColor colorWithRed:166.0f/255.0f green:47.0f/255.0f blue:41.0f/255.0f alpha:1.0];
  dangerButton.highlightedColor2 = [UIColor colorWithRed:189.0f/255.0f green:54.0f/255.0f blue:47.0f/255.0f alpha:1.0];
  [_listView addView:dangerButton];
  [dangerButton release];
  
  YKUIButton *inverseButton = [self button];
  inverseButton.titleShadowColor = [UIColor colorWithWhite:0.2 alpha:0.5];
  inverseButton.titleShadowOffset = CGSizeMake(0, -1);
  inverseButton.title = @"Inverse";
  inverseButton.titleColor = [UIColor whiteColor];
  inverseButton.color = [UIColor colorWithWhite:66.0f/255.0f alpha:1.0];
  inverseButton.color2 = [UIColor colorWithWhite:35.0f/255.0f alpha:1.0];
  inverseButton.borderColor = [UIColor colorWithWhite:48.0f/255.0f alpha:1.0];
  inverseButton.highlightedColor = [UIColor colorWithWhite:30.0f/255.0f alpha:1.0];
  inverseButton.highlightedColor2 = [UIColor colorWithWhite:34.0f/255.0f alpha:1.0];
  [_listView addView:inverseButton];
  [inverseButton release];
  
  YKUIButton *disabledButton = [self button];
  disabledButton.title = @"Disabled";
  disabledButton.enabled = NO;
  [_listView addView:disabledButton];
  [disabledButton release];
  
  //
  // Facebook button
  //
  
  YKUIButton *fbButton = [self button];
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
  [_listView addView:fbButton];
  [fbButton release];
  
  //
  // Other examples with icons, accessoryImages, borders
  //
  
  YKUIButton *button1 = [self button];
  button1.title = @"Button (icon, accessory, center, wrapping text)";
  button1.titleAlignment = NSTextAlignmentCenter;
  button1.titleInsets = UIEdgeInsetsMake(0, 10, 0, 0);
  button1.accessoryImage = [UIImage imageNamed:@"button_accessory_image.png"];
  button1.highlightedAccessoryImage = [UIImage imageNamed:@"button_accessory_image_selected.png"];
  button1.iconImage = [UIImage imageNamed:@"button_icon.png"];
  [_listView addView:button1];
  [button1 release];
  
  YKUIButton *button2 = [self button];
  button2.title = @"Button (Rounded top)";
  button2.borderStyle = YKUIBorderStyleRoundedTop;
  button2.cornerRadius = 6.0f;
  button2.borderWidth = 1.0f;
  [_listView addView:button2];
  
  YKUIButton *button3 = [self button];
  button3.title = @"Button (Top left right)";
  button3.borderStyle = YKUIBorderStyleTopLeftRight;
  button3.cornerRadius = 6.0f;
  button3.borderWidth = 1.0f;
  [_listView addView:button3];
  
  YKUIButton *button4 = [self button];
  button4.title = @"Button (Rounded bottom)";
  button4.borderStyle = YKUIBorderStyleRoundedBottom;
  button4.cornerRadius = 6.0f;
  button4.borderWidth = 1.0f;
  [_listView addView:button4];
  
  YKUIButton *button5 = [self button];
  button5.title = @"Button";
  button5.secondaryTitle = @"Secondary text, centered, multiline will not ellipsis";
  button5.secondaryTitlePosition = YKUIButtonSecondaryTitlePositionBottom;
  button5.secondaryTitleFont = [UIFont systemFontOfSize:13];
  button5.secondaryTitleColor = [UIColor grayColor];
  [_listView addView:button5];
  
  YKUIButton *button6 = [self button];
  button6.secondaryTitle = @" Secondary text";
  // TODO(gabe): This does nothing for secondary text, using space
  button6.titleInsets = UIEdgeInsetsMake(0, 0, 0, 6);
  button6.secondaryTitlePosition = YKUIButtonSecondaryTitlePositionDefault;
  button6.secondaryTitleFont = [UIFont systemFontOfSize:14];
  button6.secondaryTitleColor = [UIColor grayColor];
  [_listView addView:button6];
  
  YKUIButton *button7 = [self button];
  button7.secondaryTitle = @"Secondary text, bottom left align single line, will ellipsis";
  button7.titleAlignment = NSTextAlignmentLeft;
  button7.secondaryTitlePosition = YKUIButtonSecondaryTitlePositionBottom;
  button7.secondaryTitleFont = [UIFont systemFontOfSize:14];
  button7.secondaryTitleColor = [UIColor grayColor];
  [_listView addView:button7];
  
  YKUIButton *button8 = [self button];
  button8.secondaryTitle = @"Secondary text, right align";
  button8.secondaryTitlePosition = YKUIButtonSecondaryTitlePositionRightAlign;
  button8.secondaryTitleFont = [UIFont systemFontOfSize:14];
  button8.secondaryTitleColor = [UIColor grayColor];
  [_listView addView:button8];
  
  
  _scrollView = [[YKUIScrollView alloc] init];
  _scrollView.backgroundColor = [UIColor whiteColor];
  [self addSubview:_scrollView];
  [_scrollView release];
  
  [_scrollView addSubview:_listView];
  [_listView release];
  
  /*
   _buttons = [[YKUIButtons alloc] initWithButtons:buttons style:YKUIButtonsStyleVertical apply:^(YKUIButton *button, NSInteger index) {
   
   }];
   _buttons.insets = UIEdgeInsetsMake(0, 0, 20, 0);
   _buttons.backgroundColor = [UIColor clearColor];
   [self addSubview:_buttons];
   [_buttons release];
   [buttons release];
   */
}

- (YKUIButton *)button {
  YKUIButton *button = [[YKUIButton alloc] init];
  button.title = @"Button";
  button.titleColor = [UIColor darkGrayColor];
  button.titleFont = [UIFont boldSystemFontOfSize:15];
  button.color = [UIColor whiteColor];
  button.borderColor = [UIColor darkGrayColor];
  button.insets = UIEdgeInsetsMake(10, 10, 10, 10);
  button.borderStyle = YKUIBorderStyleRounded;
  button.cornerRadius = 10.0f;
  button.borderWidth = 1.0f;
  button.highlightedColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
  button.shadingType = YKUIShadingTypeLinear;
  button.highlightedShadingType = YKUIShadingTypeLinear;
  button.disabledShadingType = YKUIShadingTypeNone;
  button.disabledTitleShadowColor = [UIColor colorWithWhite:0 alpha:0]; // Disables title shadow if set
  button.disabledColor = [UIColor colorWithWhite:239.0f/255.0f alpha:1.0f];
  button.disabledTitleColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
  button.disabledBorderColor = [UIColor colorWithWhite:216.0f/255.0f alpha:1.0f];
  [button setTarget:self action:@selector(_buttonSelected:)];
  return button;
}

- (CGSize)layout:(id<YKLayout>)layout size:(CGSize)size {
  [layout setFrame:CGRectMake(0, 0, size.width, size.height) view:_scrollView];
  
  CGFloat y = 0;
  CGRect listViewFrame = [layout setFrame:CGRectMake(0, y, size.width, 0) view:_listView sizeToFit:YES];
  y += listViewFrame.size.height;
  
  if (![layout isSizing]) {
    [_scrollView setContentSize:CGSizeMake(size.width, y)];
  }
  
  return CGSizeMake(size.width, size.height);
}

- (void)_buttonSelected:(id)sender {
  
}

@end
